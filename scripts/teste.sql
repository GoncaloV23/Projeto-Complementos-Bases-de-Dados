use WWIGlobal
GO

insert into users.wwiuser(wwiuser_email,wwiuser_password,wwiuser_customer_id)
values('teste@gmail.com', 'password', 1)
EXEC sp_new_password_token_generator 1

select * from users.wwiuser
select * from users.token

DECLARE @isCorrect bit

EXEC sp_check_password 'teste@gmail.com', 'password', @isCorrect OUT
PRINT @isCorrect

EXEC sp_check_password 'teste@gmail.com', 'errada', @isCorrect OUT
PRINT @isCorrect



DECLARE @sale_id int
EXEC sp_create_sale '2023-2-5', '2023-2-6', 1, @sale_id OUT
select @sale_id
GO

DECLARE @price float
DECLARE @encryptad_price varbinary(MAX)
SET @encryptad_price = (select sale_encrypted_price from sales.stock where stock_id = 1)
EXEC sp_decrypt_price 'nossa_password', @encryptad_price ,	@price out

DECLARE @sale_stock_id int
EXEC sp_insert_product_to_sale 70510, 1, 1,1, 'Teste', 5, @price, 14, @sale_stock_id out
select * from sales.sale_stock where sale_stock_id = @sale_stock_id

EXEC sp_alter_sale_stock_quantity @sale_stock_id, 10
select * from sales.sale_stock where sale_stock_id = @sale_stock_id

EXEC sp_sale_stock_remove_product @sale_stock_id, 0
select * from sales.sale_stock where sale_stock_id = @sale_stock_id

DECLARE @isInTime bit
EXEC sp_check_business_rule 70510, @isInTime out
PRINT @isInTime


select * from sales.sale
select * from users.employee
