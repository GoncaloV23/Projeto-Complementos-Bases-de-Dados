
-- category
INSERT INTO WWIGlobal.coreData.category(category_name)
SELECT Name
FROM WWI_DS.dbo.Category;

-- continent
INSERT INTO WWIGlobal.coreData.continent(continent_name)
SELECT Continent
FROM WWI_DS.dbo.City
group by Continent;

-- country
INSERT INTO WWIGlobal.coreData.country(country_name, country_continent_name)
SELECT Country, Continent
FROM WWI_DS.dbo.City
group by Country, Continent;

-- State
INSERT INTO WWIGlobal.coreData.state(state_code, state_name, state_country_name)
SELECT Code, Name, 'United States'as country
FROM WWI_DS.dbo.States;

-- SalesTerritory
INSERT INTO WWIGlobal.coreData.salesterritory(salesterritory_name)
select [Sales Territory] from WWI_DS.dbo.City
group by [Sales Territory];

-- City
INSERT INTO WWIGlobal.coreData.city(city_name, city_postal_code, city_state_code, city_last_recorded_population, city_salesterritory_id)
select City, [City Key], state_code, [Latest Recorded Population], salesterritory_id 
from WWIGlobal.coreData.state
inner join WWI_DS.dbo.City on state_name COLLATE Latin1_General_CI_AS = [State Province] COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.salesterritory on [Sales Territory] COLLATE Latin1_General_CI_AS = salesterritory_name COLLATE Latin1_General_CI_AS;

INSERT INTO WWIGlobal.coreData.city(city_name, city_postal_code, city_state_code, city_last_recorded_population, city_salesterritory_id)
select City, [City Key], state_code, [Latest Recorded Population], salesterritory_id 
from WWI_DS.dbo.City
inner join WWIGlobal.coreData.state on state_name COLLATE Latin1_General_CI_AS = 'Massachusetts' COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.salesterritory on [Sales Territory] COLLATE Latin1_General_CI_AS = salesterritory_name COLLATE Latin1_General_CI_AS
where [State Province] = 'Massachusetts[E]';

INSERT INTO WWIGlobal.coreData.city(city_name, city_postal_code, city_state_code, city_last_recorded_population, city_salesterritory_id)
select City, [City Key], state_code, [Latest Recorded Population], salesterritory_id 
from WWI_DS.dbo.City
inner join WWIGlobal.coreData.state on state_name COLLATE Latin1_General_CI_AS = 'Virgin Islands, U.S.' COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.salesterritory on [Sales Territory] COLLATE Latin1_General_CI_AS = salesterritory_name COLLATE Latin1_General_CI_AS
where [State Province] = 'Virgin Islands (US Territory)';

INSERT INTO WWIGlobal.coreData.city(city_name, city_postal_code, city_state_code, city_last_recorded_population, city_salesterritory_id)
select City, [City Key], state_code, [Latest Recorded Population], salesterritory_id 
from WWI_DS.dbo.City
inner join WWIGlobal.coreData.state on state_name COLLATE Latin1_General_CI_AS = 'Puerto Rico' COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.salesterritory on [Sales Territory] COLLATE Latin1_General_CI_AS = salesterritory_name COLLATE Latin1_General_CI_AS
where [State Province] = 'Puerto Rico (US Territory)';


-- Color
INSERT INTO WWIGlobal.coreData.color(color_name)
select Color  from WWI_DS.dbo.Color;

-- Package
INSERT INTO WWIGlobal.coreData.package(package_name)
select Package from WWI_DS.dbo.Package;

-- Company
INSERT INTO WWIGlobal.users.company(company_name)
select [Buying Group] from WWI_DS.dbo.Customer group by [Buying Group];

-- Customer
SET IDENTITY_INSERT WWIGlobal.users.customer ON;


INSERT INTO WWIGlobal.users.customer(customer_WWI_id, customer_name, customer_category_id, customer_company_id, customer_primary_contact, customer_city_id)
select [WWI Customer ID], Customer, category_id, company_id, [Primary Contact], city_id from WWI_DS.dbo.Customer 
inner join WWIGlobal.coreData.category on Category COLLATE Latin1_General_CI_AS = category_name COLLATE Latin1_General_CI_AS
inner join WWIGlobal.users.company on [Buying Group] COLLATE Latin1_General_CI_AS = company_name COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.city on [Postal Code] COLLATE Latin1_General_CI_AS = city_postal_code COLLATE Latin1_General_CI_AS;
go

INSERT INTO WWIGlobal.users.customer(customer_WWI_id, customer_name, customer_category_id, customer_company_id, customer_primary_contact, customer_city_id)
select [WWI Customer ID], Customer, (select category_id from WWIGlobal.coreData.category where category_name = 'Kiosk '), company_id, [Primary Contact], city_id from WWI_DS.dbo.Customer
inner join WWIGlobal.users.company on [Buying Group] COLLATE Latin1_General_CI_AS = company_name COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.city on [Postal Code] COLLATE Latin1_General_CI_AS = city_postal_code COLLATE Latin1_General_CI_AS
where Category = 'Quiosk';
go

INSERT INTO WWIGlobal.users.customer(customer_WWI_id, customer_name, customer_category_id, customer_company_id, customer_primary_contact, customer_city_id)
select [WWI Customer ID], Customer, (select category_id from WWIGlobal.coreData.category where category_name = 'Gift Shop '), company_id, [Primary Contact], city_id from WWI_DS.dbo.Customer
inner join WWIGlobal.users.company on [Buying Group] COLLATE Latin1_General_CI_AS = company_name COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.city on [Postal Code] COLLATE Latin1_General_CI_AS = city_postal_code COLLATE Latin1_General_CI_AS
where Category = 'GiftShop';
go

SET IDENTITY_INSERT WWIGlobal.users.customer OFF;
go
-- customer_bill
UPDATE WWIGlobal.users.customer 
SET customer_bill_to_id = (select newC.customer_WWI_id 
							from WWIGlobal.users.customer as newC
							inner join WWI_DS.dbo.Customer as oldC  on
							oldC.[Bill To Customer] COLLATE Latin1_General_CI_AS =
							newC.customer_name COLLATE Latin1_General_CI_AS
							where oldC.[WWI Customer ID] = main.customer_WWI_id)
FROM WWIGlobal.users.customer as main;

-- Employee
INSERT INTO WWIGlobal.users.employee(employee_name, employee_isSalesperson, employee_photo)
select Employee, [Is Salesperson], Photo from WWI_DS.dbo.Employee;

-- Sale
SET IDENTITY_INSERT WWIGlobal.sales.sale ON;
go

INSERT INTO WWIGlobal.sales.sale(sale_id,  sale_invoice_date, sale_delivery_date, sale_salesperson_id)
select [WWI Invoice ID], [Invoice Date Key], [Delivery Date Key], [Salesperson Key] 
from WWI_DS.dbo.Sale 
group by [WWI Invoice ID], [Invoice Date Key], [Delivery Date Key], [Salesperson Key];

SET IDENTITY_INSERT WWIGlobal.sales.sale OFF;
go

-- Stock
INSERT INTO WWIGlobal.sales.stock(stock_item, stock_color_id, stock_selling_package_id, stock_buying_package_id, stock_brand, 
stock_size, stock_lead_time_days, stock_per_outer, stock_isChiller, stock_barcode, stock_tax_rate, stock_unitprice, 
stock_recommended_retail_price, stock_weight_per_unit)
select [Stock Item], color_id, p1.package_id, p2.package_id, Brand, Size, [Lead Time Days], [Quantity Per Outer], [Is Chiller Stock], Barcode, [Tax Rate], [Unit Price], 
[Recommended Retail Price], [Typical Weight Per Unit] from WWI_DS.dbo.[Stock Item]
inner join WWIGlobal.coreData.color on color_name COLLATE Latin1_General_CI_AS = Color COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.package as p1 on p1.package_name COLLATE Latin1_General_CI_AS = [Selling Package] COLLATE Latin1_General_CI_AS
inner join WWIGlobal.coreData.package as p2 on p2.package_name COLLATE Latin1_General_CI_AS = [Buying Package] COLLATE Latin1_General_CI_AS;

-- Sale Stock
INSERT INTO WWIGlobal.sales.sale_stock(sale_id, sale_city_id, sale_customer_id, stockItem_id, sale_description, sale_quantity, sale_unit_price, sale_tax_rate)
select [WWI Invoice ID], city_id, c.[WWI Customer ID], [Stock Item Key], Description, Quantity, [Unit Price], [Tax Rate] from WWI_DS.dbo.Sale as s
inner join WWIGlobal.coreData.city on [City Key]  = city_postal_code
inner join WWI_DS.dbo.Customer as c on c.[Customer Key] = s.[Customer Key];