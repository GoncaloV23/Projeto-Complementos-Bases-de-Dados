/*
• Adicionar Produto a uma Venda;
• Atualizar preço de um produto, garantindo que o preço do produto nas vendas por finalizar 
não é alterado;
• Calcular o total da venda e/ou a quantidade de produtos na venda sem permitir adição ou 
remoção de produtos na venda.
*/
USE WWIGlobal

GO
DROP PROCEDURE IF EXISTS add_stock_sale_transaction
GO
CREATE PROCEDURE add_stock_sale_transaction
@stock_id int, @sale_id int, @sale_city_id int, @sale_description varchar(200), @sale_quantity int, @sale_tax_rate int
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    BEGIN TRANSACTION;
	BEGIN TRY
		INSERT INTO sales.sale_stock(sale_id, sale_city_id, stockItem_id, sale_description, sale_quantity, sale_unit_price, sale_tax_rate)
		VALUES (@sale_id, @sale_city_id, @stock_id, @sale_description, @sale_quantity, (select stock_unitprice from sales.stock where stock_id = @stock_id), @sale_tax_rate);
	END TRY
	BEGIN CATCH
		PRINT 'ERRO na inseção do produto na venda!';
	END CATCH
    IF @@ERROR != 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Transaction Rolled Back';
    END;

    COMMIT TRANSACTION;
    PRINT 'Transaction Committed';
END;
GO
DROP PROCEDURE IF EXISTS update_stock_price_transaction
GO
CREATE PROCEDURE update_stock_price_transaction
@stock_id int, @new_price int
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE sales.stock
		SET stock_unitprice = @new_price
		WHERE stock_id = @stock_id;
	END TRY
	BEGIN CATCH
		PRINT 'ERRO na atualização do produto!';
	END CATCH
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Transaction Rolled Back';
    END;

    COMMIT TRANSACTION;
    PRINT 'Transaction Committed';
END;
GO
DROP PROCEDURE IF EXISTS query_sale_transaction
GO
CREATE PROCEDURE query_sale_transaction
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

	select sale_id, sum(sale_unit_price*sale_quantity) as Valor, count(*) as 'Nº de produtos' from sales.sale_stock group by sale_id
    

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Transaction Rolled Back';
    END;

    COMMIT TRANSACTION;
    PRINT 'Transaction Committed';
END;