/*Implemente o código necessário à encriptação, chaves ou hashing, do campo relativo à password dos 
utilizadores do sistema e dos campos relativos ao preço dos produtos. Justifique a escolha da 
metodologia escolhida para cada um dos campos.*/
USE WWIGlobal

ALTER TABLE users.wwiuser
ADD wwiuser_encrypted_password varbinary(max);

GO
DROP TRIGGER IF EXISTS tr_password_hash
GO
CREATE TRIGGER tr_password_hash
ON users.wwiuser
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @pass VARCHAR(80);
    SELECT @pass = wwiuser_password FROM inserted;

	IF @pass != 'encrypted'
	BEGIN
		UPDATE wwiuser
		SET wwiuser_encrypted_password = HASHBYTES('SHA2_256', @pass), wwiuser_password = 'encrypted'
		WHERE wwiuser_password IS NOT NULL AND wwiuser_password = @pass;
	END
END;
GO
DROP PROCEDURE IF EXISTS sp_check_password
GO
CREATE PROCEDURE sp_check_password
@email varchar(100), @password varchar(80), @isCorret bit OUT
AS BEGIN
	DECLARE @hash  VARCHAR(100)

    SELECT  @hash = wwiuser_encrypted_password FROM users.wwiuser where wwiuser_email = @email;

	IF @hash = HASHBYTES('SHA2_256', @password)
		BEGIN
			SET @isCorret = 1
		END
	ELSE
		BEGIN
			SET @isCorret = 0
		END
END;
GO


ALTER TABLE sales.stock
ADD sale_encrypted_price varbinary(max);

ALTER TABLE sales.sale_stock
ADD sale_stock_encrypted_price varbinary(max);
GO

-- Criação da chave simétrica
CREATE SYMMETRIC KEY simetric_key
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'nossa_password';
GO


	 -- Abertura da chave simétrica
	OPEN SYMMETRIC KEY simetric_key
	DECRYPTION BY PASSWORD = 'nossa_password';

	UPDATE sales.stock SET sale_encrypted_price = EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX), stock_unitprice)), stock_unitprice = 0
	UPDATE sales.sale_stock SET sale_stock_encrypted_price = EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX), sale_unit_price)), sale_unit_price = 0

	-- Fechamento da chave simétrica
	CLOSE SYMMETRIC KEY simetric_key;
GO
DROP PROCEDURE IF EXISTS sp_decrypt_price
GO
CREATE PROCEDURE sp_decrypt_price
	@key_password varchar(100),
	@encrypted_price varbinary(MAX),
	@price float out
AS BEGIN
	DECLARE @decrypted_value nvarchar(100)
	IF @key_password = 'nossa_password'
	BEGIN
		-- Abertura da chave simétrica
		OPEN SYMMETRIC KEY simetric_key
		DECRYPTION BY PASSWORD = 'nossa_password'

		SET @decrypted_value = CONVERT(nvarchar(100), DecryptByKey(@encrypted_price));
		SET @price = CONVERT(float, @decrypted_value);

		-- Fechamento da chave simétrica
		CLOSE SYMMETRIC KEY simetric_key;

		return @price
	END
	ELSE PRINT 'Password de Chave Errada!'
END
GO
DROP TRIGGER IF EXISTS tr_stock_price
GO
CREATE TRIGGER tr_stock_price
ON sales.stock
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @stock_id int;
    SELECT @stock_id = stock_id FROM inserted;

	-- Abertura da chave simétrica
	OPEN SYMMETRIC KEY simetric_key
	DECRYPTION BY PASSWORD = 'nossa_password';

	UPDATE sales.stock SET sale_encrypted_price = EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX), stock_unitprice)), stock_unitprice = 0
	 WHERE  stock_id = @stock_id;
	

	-- Fechamento da chave simétrica
	CLOSE SYMMETRIC KEY simetric_key;
END;
GO
DROP TRIGGER IF EXISTS tr_sale_stock_price
GO
CREATE TRIGGER tr_sale_stock_price
ON sales.sale_stock
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @sale_stock_id int;
    SELECT @sale_stock_id = stockItem_id FROM inserted;

	-- Abertura da chave simétrica
	OPEN SYMMETRIC KEY simetric_key
	DECRYPTION BY PASSWORD = 'nossa_password';

	UPDATE sales.sale_stock SET sale_stock_encrypted_price = EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX), sale_unit_price)), sale_unit_price = 0
	 WHERE  stockItem_id = @sale_stock_id;
	

	-- Fechamento da chave simétrica
	CLOSE SYMMETRIC KEY simetric_key;
END;
