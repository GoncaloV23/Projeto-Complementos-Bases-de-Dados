drop procedure if exists insertData
go
create procedure insertData
AS BEGIN
	Declare @count int;
	SET @count = 0;
	WHILE @count < 100
	BEGIN
		insert into WWIGlobal.sales.sale(sale_invoice_date, sale_delivery_date, sale_salesperson_id)
		values('2023-01-01',	'2023-01-02',	15)

		insert into WWIGlobal.users.customer(customer_name, customer_category_id, customer_company_id, customer_primary_contact, customer_city_id, customer_bill_to_id)
		values('Teste',	1,	1,	'Teste',	87823,	1)

		SET @count = @count + 1;
	END
END
go

-- BACKUP
-- Backup completo:
BACKUP DATABASE WWIGlobal
TO DISK =  'C:\sql_data\backups\completo.bak'
WITH INIT;

exec insertData

-- Backup diferencial:
BACKUP DATABASE WWIGlobal
TO DISK =  'C:\sql_data\backups\diferencial.bak'
WITH DIFFERENTIAL;

exec insertData

-- Backup transacional:
BACKUP LOG WWIGlobal
TO DISK =  'C:\sql_data\backups\transacional.trn'
WITH NO_TRUNCATE;

exec insertData

select count(*)as 'Nº de Registos'  from WWIGlobal.users.customer where customer_name = 'Teste'
select count(*)as 'Nº de Registos'  from WWIGlobal.sales.sale where sale_invoice_date = '2023-01-01'


-- SIMULAR CRASH


select count(*)as 'Nº de Registos'  from WWIGlobal.users.customer where customer_name = 'Teste'
select count(*)as 'Nº de Registos'  from WWIGlobal.sales.sale where sale_invoice_date = '2023-01-01'


-- Backup do tail
BACKUP LOG WWIGlobal
TO DISK =  'C:\sql_data\backups\tail.trn'
WITH  NORECOVERY, NO_TRUNCATE;


-- Restauração de backup completa
RESTORE DATABASE WWIGlobal
FROM DISK = 'C:\sql_data\backups\completo.bak'
WITH NORECOVERY

-- Restauração de backup diferencial
RESTORE DATABASE WWIGlobal
FROM DISK = 'C:\sql_data\backups\diferencial.bak'
WITH NORECOVERY

-- Restauração de backup de transacional
RESTORE LOG WWIGlobal
FROM DISK = 'C:\sql_data\backups\transacional.trn'
WITH NORECOVERY

RESTORE LOG WWIGlobal
FROM DISK = 'C:\sql_data\backups\tail.trn'
WITH RECOVERY

select count(*)as 'Nº de Registos'  from WWIGlobal.users.customer where customer_name = 'Teste'
select count(*)as 'Nº de Registos'  from WWIGlobal.sales.sale where sale_invoice_date = '2023-01-01'


RESTORE DATABASE WWIGlobal
FROM DISK = 'C:\sql_data\backups\completo.bak'
WITH REPLACE