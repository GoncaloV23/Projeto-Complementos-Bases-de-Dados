use WWIGlobal

CREATE ROLE Admin;
CREATE ROLE EmployeeSalesPerson;
CREATE ROLE SalesTerritory;

CREATE USER AdminUser Without LOGIN;
CREATE USER EmployeeSalesPersonUser Without LOGIN;
CREATE USER SalesTerritoryUser Without LOGIN;

ALTER ROLE Admin ADD MEMBER AdminUser;
ALTER ROLE EmployeeSalesPerson ADD MEMBER EmployeeSalesPersonUser;
ALTER ROLE SalesTerritory ADD MEMBER SalesTerritoryUser;

GRANT SELECT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION, ALTER, CONTROL, TAKE OWNERSHIP TO Admin;

GRANT SELECT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION, ALTER, CONTROL, TAKE OWNERSHIP ON SCHEMA::sales TO EmployeeSalesPerson;

GRANT SELECT ON coreData.color TO EmployeeSalesPerson;
GRANT SELECT ON coreData.package TO EmployeeSalesPerson;
GRANT SELECT ON coreData.category TO EmployeeSalesPerson;
GRANT SELECT ON coreData.continent TO EmployeeSalesPerson;
GRANT SELECT ON coreData.country TO EmployeeSalesPerson;
GRANT SELECT ON coreData.state TO EmployeeSalesPerson;
GRANT SELECT ON coreData.salesterritory TO EmployeeSalesPerson;
GRANT SELECT ON coreData.city TO EmployeeSalesPerson;
GRANT SELECT ON users.company TO EmployeeSalesPerson;
GRANT SELECT ON users.employee TO EmployeeSalesPerson;
GRANT SELECT ON users.customer TO EmployeeSalesPerson;
GRANT SELECT ON users.wwiuser TO EmployeeSalesPerson;
GRANT SELECT ON users.token TO EmployeeSalesPerson;
GRANT SELECT ON logs.error_log TO EmployeeSalesPerson;
GRANT SELECT ON logs.TableStats TO EmployeeSalesPerson;
GRANT SELECT ON logs.table_info TO EmployeeSalesPerson;

go
DROP VIEW IF EXISTS viewAux
go
CREATE VIEW viewAux AS
SELECT salesterritory_name
FROM coreData.salesterritory
WHERE salesterritory_name = 'Rocky Mountain';
go

GRANT SELECT ON viewAux TO SalesTerritory;
