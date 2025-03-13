use WWIGlobal;
/*
• Pesquisa de vendas por cidade. Deve ser retornado o nome da cidade, o nome do vendedor, 
o total de vendas (nota: cidades com o mesmo nome mas de diferentes estão deverão ser 
consideradas distintas);
• Para as vendas calcular a taxa de crescimento de cada ano, face ao ano anterior, por categoria 
de cliente;
• Nº de produtos (stockItem) nas vendas por cor.
- 2 -
Notas: 
• A taxa de crescimento calcula-se com a seguinte fórmula (?????? ?????????? ? ?????? ??????????????)/ano anterior
*/
go
create schema views
go
drop view  if exists views.v_sale_quantity_by_year_and_category
go
create view views.v_sale_quantity_by_year_and_category 
as
select year(sale_invoice_date) as Year, customer_category_id as category, sum(sale_quantity * sale_unit_price) as 'Sales Value'
from WWIGlobal.sales.sale_stock st 
inner join WWIGlobal.sales.sale s on st.sale_id = s.sale_id
inner join WWIGlobal.users.customer on customer_WWI_id = st.sale_customer_id
group by year(sale_invoice_date), customer_category_id
go
drop view  if exists v_sale_quantity_by_year_and_category_old
go
create view v_sale_quantity_by_year_and_category_old
as
select year(s.[Invoice Date Key])as Year, c.Category as category, sum(s.Quantity * s.[Unit Price]) as 'Sales Value'
from WWI_DS.dbo.sale s  inner join WWI_DS.dbo.Customer c 
on c.[Customer Key] = s.[Customer Key]
group by year(s.[Invoice Date Key]), c.Category
go

DROP PROCEDURE IF EXISTS sp_number_of_sales_per_city_employee
GO
CREATE PROCEDURE sp_number_of_sales_per_city_employee
@city varchar(100), @stateCode char(2)
AS BEGIN
-- new
	select city_name, employee_name, count(*) as 'Number of sales'
	from WWIGlobal.sales.sale st inner join WWIGlobal.sales.sale_stock s on st.sale_id = s.sale_id
	inner join WWIGlobal.coreData.city on city_id = sale_city_id
	inner join WWIGlobal.users.employee on employee_id = sale_salesperson_id
	where city_name = @city and city_state_code = @stateCode
	group by city_id, city_name, employee_name
	order by city_id, employee_name;

	-- old
	select c.City, Employee, count(*) as 'Number of sales'
	from WWI_DS.dbo.[Stock Item] st inner join WWI_DS.dbo.sale s 
	on st.[Stock Item Key] = s.[Stock Item Key]
	inner join WWI_DS.dbo.City as c on c.[City Key] = s.[City Key]
	inner join WWI_DS.dbo.Employee on [Employee Key] = [Salesperson Key]
	where c.City = @city
	group by c.[City Key], c.City, Employee
	order by c.[City Key], Employee;

END
GO

DROP PROCEDURE IF EXISTS sp_growth_rate_per_category
GO
CREATE PROCEDURE sp_growth_rate_per_category
AS BEGIN
-- new
select cur.Year, cur.category, ISNULL((cur.[Sales Value] - 
		(select [Sales Value]
		from views.v_sale_quantity_by_year_and_category
		where Year + 1 = cur.Year and category = cur.category))
	/
		(select [Sales Value]
		from views.v_sale_quantity_by_year_and_category
		where Year + 1 = cur.Year and category = cur.category), 0) as 'Taxa de crescimento'
from views.v_sale_quantity_by_year_and_category as cur
order by cur.Year, category;

-- old
select cur.Year, cur.category, ISNULL((cur.[Sales Value] - 
		(select [Sales Value]
		from v_sale_quantity_by_year_and_category_old
		where Year + 1 = cur.Year and category = cur.category))
	/
		(select [Sales Value]
		from v_sale_quantity_by_year_and_category_old
		where Year + 1 = cur.Year and category = cur.category), 0) as 'Taxa de crescimento'
from v_sale_quantity_by_year_and_category_old as cur
order by cur.Year, category;

END
GO


DROP PROCEDURE IF EXISTS sp_sales_count_per_color
GO
CREATE PROCEDURE sp_sales_count_per_color
@color varchar(100)
AS BEGIN
-- new
select color_name, count(*) as 'Number of sales' 
from WWIGlobal.sales.sale_stock
inner join WWIGlobal.sales.stock on stock_id = stockItem_id
inner join WWIGlobal.coreData.color on color_id = stock_color_id
where color_name = @color
group by color_name
order by color_name

-- old
select stock.Color, count(*) as 'Number of sales' 
from WWI_DS.dbo.Sale as sale
inner join WWI_DS.dbo.[Stock Item] as stock on sale.[Stock Item Key] = stock.[Stock Item Key]
where stock.Color = @color
group by stock.Color
order by stock.Color

END
GO


SET STATISTICS IO ON
EXEC sp_number_of_sales_per_city_employee 'Zurich', 'KS'
EXEC sp_growth_rate_per_category 
EXEC sp_sales_count_per_color 'Black'

DROP INDEX IF EXISTS city_index ON WWiGlobal.coreData.city
CREATE INDEX city_index
ON WWiGlobal.coreData.city (city_name, city_state_code);

DROP INDEX IF EXISTS color_index ON WWiGlobal.coreData.color
CREATE INDEX color_index
ON WWiGlobal.coreData.color (color_name);

EXEC sp_number_of_sales_per_city_employee 'Zurich', 'KS'
EXEC sp_growth_rate_per_category 
EXEC sp_sales_count_per_color 'Black'
