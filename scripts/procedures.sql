use WWIGlobal
go

DROP TRIGGER if exists trigger_check_promotion_is_active 
GO
CREATE TRIGGER trigger_check_promotion_is_active
ON sales.stock_promotion
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @new_promotion_id int

    SELECT @new_promotion_id = promotion_id
    FROM INSERTED;

    IF DATEDIFF(day, GETDATE(), (select promotion_inicial_date from promotion where promotion_id = @new_promotion_id)) >0
	OR DATEDIFF(day, GETDATE(), (select promotion_end_date from promotion where promotion_id = @new_promotion_id)) <0
    BEGIN
        RAISERROR ('Uma Promoção tem que estar ativa para poder ser adicionada a 1 produto.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

DROP PROCEDURE if exists sp_new_password_token_generator 
GO
CREATE PROCEDURE sp_new_password_token_generator
@id int
AS BEGIN

	DECLARE @result varchar(100)
	DECLARE @charpool char(62)
	DECLARE @token varchar(9)
	DECLARE @email varchar(80)
	SET @charpool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; 
	SET @result = 'Send token: '
	SET @token = ''

	SET @email = (select wwiuser_email from WWIGlobal.users.wwiuser where wwiuser_id = @id)
	IF @email is NULL BEGIN select 'Erro no parametro de entrada @id user não existente'as Menssagem, @id as parametro END
	ELSE BEGIN
		WHILE LEN(@token)<9 BEGIN
			SET @token = CONCAT( @token ,SUBSTRING(@charpool, CONVERT(INT, FLOOR(1 + RAND() * (62 - 1))), 1))
		END


		insert into WWIGlobal.users.token(token, token_creation_date, token_user_id) values (@token, GETDATE(), @id)

		select CONCAT(@result, @token, ' to ', @email)
	END
END 
GO

-- Criar uma venda;
DROP PROCEDURE if exists sp_create_sale
GO
CREATE PROCEDURE sp_create_sale
@invoice_date date, @delivarie_date date, @employee_id int, @sale_id int OUT AS BEGIN
	BEGIN TRY
		INSERT INTO WWIGlobal.sales.sale(sale_invoice_date, sale_delivery_date, sale_salesperson_id)
		values (@invoice_date, @delivarie_date, @employee_id);

		set @sale_id = (select top 1 sale_id from WWIGlobal.sales.sale order by sale_id desc);
	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 
GO

-- Adicionar um produto a uma venda;
DROP PROCEDURE if exists sp_insert_product_to_sale 
GO
CREATE PROCEDURE sp_insert_product_to_sale
@sale_id int, @sale_city_id int, @sale_customer varchar(50), @stockItem_id int, @sale_description varchar(150), @sale_quantity int, @sale_unit_price float, @sale_tax_rate float,
@sale_stock_id int out AS BEGIN
	
	declare @customer_id int;
	set @customer_id = (select customer_WWI_id from WWIGlobal.users.customer where customer_name = @sale_customer);

	BEGIN TRY  
		INSERT INTO WWIGlobal.sales.sale_stock(sale_id, sale_city_id, sale_customer_id, stockItem_id, sale_description, sale_quantity, sale_unit_price, sale_tax_rate)
		values (@sale_id, @sale_city_id, @sale_customer, @stockItem_id, @sale_description, @sale_quantity, @sale_unit_price, @sale_tax_rate);
	

		set @sale_stock_id = (select top 1 sale_stock_id from WWIGlobal.sales.sale_stock order by sale_stock_id desc);
	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 
GO

-- Alterar a quantidade de um produto numa venda;
DROP PROCEDURE if exists sp_alter_sale_stock_quantity
GO
CREATE PROCEDURE sp_alter_sale_stock_quantity
@id int, @new_quantity int AS BEGIN
	BEGIN TRY
		UPDATE sales.sale_stock
		SET sale_quantity = @new_quantity
		WHERE sale_stock_id = @id;

	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 
GO

-- Remover um produto de uma venda. Recebe um parâmetro que indica se a venda é removida 
-- no caso de não ter mais produtos associados;
DROP PROCEDURE if exists sp_sale_stock_remove_product
GO
CREATE PROCEDURE sp_sale_stock_remove_product
@id int, @removeSale bit AS BEGIN
	DECLARE @sale_id int;
	BEGIN TRY
		DELETE FROM sales.sale_stock
		WHERE sale_stock_id = @id;

		IF @removeSale = 1 and (select sale_stock_id from sales.sale_stock where sale_id = @sale_id) is null BEGIN
			SET @sale_id = (select sale_id from sales.sale_stock where sale_stock_id = @id);
			
			DELETE FROM sales.sale
			WHERE sale_id = @sale_id;
		END
	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 
GO


-- Calcular o preço total de uma venda;
DROP PROCEDURE if exists sp_calc_total_price
GO
CREATE PROCEDURE sp_calc_total_price
@sale_id int AS BEGIN
	BEGIN TRY
		SELECT sale_id as 'ID de Venda', SUM(sale_quantity * sale_unit_price)as Total FROM sales.sale_stock WHERE sale_id = @sale_id GROUP BY sale_id;
	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 

EXEC sp_calc_total_price 70510
GO

-- Implementar a regra de negócio que verifique se a data de entrega está de acordo com o 
-- tempo previsto de entrega de um produto (“Lead Time Days”);
DROP PROCEDURE if exists sp_check_business_rule 
GO
CREATE PROCEDURE sp_check_business_rule
@sale_id int, @isInTime bit out AS BEGIN
	
	DECLARE @invoice_date date, @delieverie_date date, @lead_time int;

	SET @isInTime = 0;
	BEGIN TRY
		SET @invoice_date = (select sale_invoice_date from sales.sale where sale_id = @sale_id);
		SET @delieverie_date = (select sale_delivery_date from sales.sale where sale_id = @sale_id);
		SET @lead_time = (select MAX(stock_lead_time_days) 
						from sales.stock 
						inner join sales.sale_stock on stockItem_id = stock_id
						where sale_id = @sale_id
						group by sale_id);

		IF @lead_time >= DATEDIFF(day, @invoice_date, @delieverie_date) BEGIN 
			SET @isInTime = 1;
		END

		
	END TRY
	BEGIN CATCH
		INSERT INTO WWIGlobal.logs.error_log(error_log_error, error_log_sql_user, error_log_date)
		values (ERROR_NUMBER(), SYSTEM_USER, GETDATE());

		PRINT 'Error Message: ' + ERROR_MESSAGE();
	END CATCH
END 
GO
-- Não permitir uma venda conter produtos com e sem “Chiller Stock”.
DROP TRIGGER if exists trigger_check_sale_stock_chiller 
GO
CREATE TRIGGER tr_check_sale_stock_chiller
ON sales.sale_stock
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @new_sale_id int

    SELECT @new_sale_id = sale_id
    FROM INSERTED;

    IF 0 = any (select stock_isChiller from sales.sale_stock inner join stock on stockItem_id = stock_id where sale_id = @new_sale_id)
	and 1 = any (select stock_isChiller from sales.sale_stock inner join stock on stockItem_id = stock_id where sale_id = @new_sale_id)
    BEGIN
        RAISERROR ('Uma venda não pode conter produtos com e sem “Chiller Stock”.', 16, 1)
        ROLLBACK TRANSACTION
    END
END



use WWIGlobal
go

