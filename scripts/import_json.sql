
DROP TABLE IF EXISTS WWIGlobal.sales.transport
DROP TABLE IF EXISTS WWIGlobal.sales.logistic


CREATE TABLE WWIGlobal.sales.logistic(
	logistic_id int IDENTITY(1,1) PRIMARY KEY,
	logistic_name char(3)
) on intensive_filegroup

CREATE TABLE WWIGlobal.sales.transport(
	transport_id int IDENTITY(1,1) PRIMARY KEY,
	transport_logistic_id int,
	transport_sale_id bigint,
    transport_shippingDate date,
    transport_deliveryDate date,
    transport_trackingNumber varchar(100),
	transport_encrypted_trackingNumber varbinary(max)
	FOREIGN KEY (transport_logistic_id) REFERENCES WWIGlobal.sales.logistic (logistic_id),
	FOREIGN KEY (transport_sale_id) REFERENCES WWIGlobal.sales.sale (sale_id)
) on intensive_filegroup


DECLARE @json NVARCHAR(MAX);

set @json = (SELECT * FROM OPENROWSET (BULK 'C:\sql_data\WWIWeb.transports.json', SINGLE_CLOB) as j);


INSERT INTO WWIGlobal.sales.logistic (logistic_name)
SELECT distinct name
FROM OPENJSON (@json)

WITH (
  name char(3) '$.name'
)

DECLARE @data TABLE (
	name char(3), 
	saleid INT,
	shippingDate NVARCHAR(10),
	deliveryDate NVARCHAR(10),
	trackingNumber NVARCHAR(36)
);
INSERT INTO @data(name, saleid, shippingDate,deliveryDate,trackingNumber)
SELECT *
FROM OPENJSON (@json)
WITH ( 
	name char(3) '$.name',
	saleid bigint '$.saleid',
	shippingDate date '$.shippingDate',
	deliveryDate date '$.deliveryDate',
	trackingNumber varchar(100)  '$.trackingNumber'
)



INSERT INTO WWIGlobal.sales.transport(transport_logistic_id, transport_sale_id, transport_shippingDate,transport_deliveryDate,transport_trackingNumber)
select logistic_id,  saleid, shippingDate, deliveryDate, trackingNumber from @data
inner join WWIGlobal.sales.logistic on logistic_name = name

select * from WWIGlobal.sales.logistic
select * from WWIGlobal.sales.transport


use WWIGlobal

go
DROP VIEW IF EXISTS v_transports
go
CREATE VIEW v_transports AS
SELECT logistic_name, sum(DATEDIFF(day, transport_shippingDate, transport_deliveryDate))/count(*) as 'Media de dias' from WWIGlobal.sales.transport
inner join WWIGlobal.sales.logistic on logistic_id = transport_logistic_id
group by logistic_name
go

DROP INDEX IF EXISTS logistics_index ON WWiGlobal.sales.logistic
CREATE INDEX logistics_index
ON WWiGlobal.sales.logistic (logistic_name);

CREATE ROLE Transports_logistic;

CREATE USER LogisticUser Without LOGIN;

ALTER ROLE Transports_logistic ADD MEMBER LogisticUser;

GRANT SELECT ON SCHEMA::sales TO LogisticUser;

GRANT UPDATE, DELETE, VIEW DEFINITION, ALTER, CONTROL, TAKE OWNERSHIP ON WWIGlobal.sales.logistic TO LogisticUser;
GRANT UPDATE, DELETE, VIEW DEFINITION, ALTER, CONTROL, TAKE OWNERSHIP ON WWIGlobal.sales.transport TO LogisticUser;
GRANT SELECT, UPDATE, DELETE, VIEW DEFINITION, ALTER, CONTROL, TAKE OWNERSHIP ON v_transports TO LogisticUser;


go
	 -- Abertura da chave simétrica
	OPEN SYMMETRIC KEY simetric_key
	DECRYPTION BY PASSWORD = 'nossa_password';

	
	UPDATE sales.transport SET transport_encrypted_trackingNumber = EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX), transport_trackingNumber))

	ALTER TABLE sales.transport DROP COLUMN transport_trackingNumber

GO
DROP PROCEDURE IF EXISTS sp_decrypt_transport_trackingNumber
GO
CREATE PROCEDURE sp_decrypt_transport_trackingNumber
	@key_password varchar(100),
	@encryptedsp_transport_trackingNumber varbinary(MAX),
	@transport_trackingNumber varchar(100) out
AS BEGIN
	IF @key_password = 'nossa_password'
	BEGIN
		-- Abertura da chave simétrica
		OPEN SYMMETRIC KEY simetric_key
		DECRYPTION BY PASSWORD = 'nossa_password'

		SET @transport_trackingNumber = CONVERT(varchar(100), DecryptByKey(@encryptedsp_transport_trackingNumber));

		-- Fechamento da chave simétrica
		CLOSE SYMMETRIC KEY simetric_key;

		return @encryptedsp_transport_trackingNumber
	END
	ELSE PRINT 'Password de Chave Errada!'
END
GO
DROP PROCEDURE IF EXISTS sp_transport_trackingNumber
GO
CREATE PROCEDURE sp_transport_trackingNumber
@transport_logistic_id int, @transport_sale_id int, @transport_shippingDate date, @transport_deliveryDate date, @transport_trackingNumber varchar(max)
As BEGIN
	-- Abertura da chave simétrica
	OPEN SYMMETRIC KEY simetric_key
	DECRYPTION BY PASSWORD = 'nossa_password';
	
	INSERT INTO sales.transport(transport_logistic_id, transport_sale_id, transport_shippingDate, transport_deliveryDate, transport_encrypted_trackingNumber)
	VALUES(@transport_logistic_id, @transport_sale_id, @transport_shippingDate, @transport_deliveryDate, EncryptByKey(Key_GUID('simetric_key'), CONVERT(NVARCHAR(MAX),@transport_trackingNumber)))

	-- Fechamento da chave simétrica
	CLOSE SYMMETRIC KEY simetric_key;
END;
