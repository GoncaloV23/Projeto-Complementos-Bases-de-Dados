--Number of customer // Nova
select count(*)
from WWIGlobal.users.customer;

--Nº de Customers // Antiga
select count(*)
from WWI_DS.dbo.customer;


--Nº de Customers por Categoria // Nova
select cat.category_name, count(*) as 'Number of customers'
from WWIGlobal.users.customer c inner join WWIGlobal.coreData.category cat 
on c.customer_category_id = cat.category_id
group by cat.category_name;

--Nº de Customers por Categoria // Antiga
select Category, count(*) as 'Number of customers'
from WWI_DS.dbo.customer
group by Category;


--Total de vendas por Employee // Nova
select e.employee_id ,count(*) as 'Number of sales'
from WWIGlobal.users.employee e inner join WWIGlobal.sales.sale s 
on e.employee_id = s.sale_salesperson_id
group by e.employee_id
order by e.employee_id;

--Total de vendas por Employee // Antiga
select e.[Employee Key], count(distinct s.[WWI Invoice ID]) as 'Number of sales'
from WWI_DS.dbo.employee e inner join WWI_DS.dbo.sale s 
on e.[Employee Key] = s.[Salesperson Key]
group by e.[Employee Key]
order by e.[Employee Key];


--Total monetário de vendas por StockItem // Nova
select stockItem_id, sum(sale_quantity*sale_unit_price) as 'Sales Value'
from WWIGlobal.sales.sale_stock
group by stockItem_id
order by stockItem_id;

--Total monetário de vendas por StockItem // Antiga
select s.[Stock Item Key], sum(s.Quantity*s.[Unit Price]) as 'Sales Value'
from WWI_DS.dbo.[Stock Item] st inner join WWI_DS.dbo.sale s 
on st.[Stock Item Key] = s.[Stock Item Key]
group by s.[Stock Item Key]
order by s.[Stock Item Key];


--Total monetário de vendas por ano por StockItem // Nova
select s.sale_id, year(sale_delivery_date) as Year, sum(sale_quantity * sale_unit_price) as 'Sales Value'
from WWIGlobal.sales.sale_stock st inner join WWIGlobal.sales.sale s on st.sale_id = s.sale_id
group by year(sale_delivery_date), s.sale_id
order by s.sale_id, year(sale_delivery_date);

--Total monetário de vendas por ano por StockItem // Antiga
select s.[WWI Invoice ID], year(s.[Delivery Date Key])as Year, sum(s.Quantity * st.[Unit Price]) as 'Sales Value'
from WWI_DS.dbo.[Stock Item] st inner join WWI_DS.dbo.sale s 
on st.[Stock Item Key] = s.[Stock Item Key]
group by year(s.[Delivery Date Key]), s.[WWI Invoice ID]
order by s.[WWI Invoice ID], year(s.[Delivery Date Key]);


--Total monetário de vendas por ano por City // Nova
select city_name, year(sale_delivery_date), sum(sale_quantity * sale_unit_price) as 'Sales Value'
from WWIGlobal.sales.sale_stock st inner join WWIGlobal.sales.sale s on st.sale_id = s.sale_id
inner join WWIGlobal.coreData.city on city_id = sale_city_id
group by year(sale_delivery_date), city_name
order by city_name, year(sale_delivery_date);

--Total monetário de vendas por ano por City // Antiga
select c.City, year([Delivery Date Key]), sum(s.Quantity * st.[Unit Price]) as 'Sales Value'
from WWI_DS.dbo.[Stock Item] st inner join WWI_DS.dbo.sale s 
on st.[Stock Item Key] = s.[Stock Item Key]
inner join WWI_DS.dbo.City as c on c.[City Key] = s.[City Key]
group by year(s.[Delivery Date Key]), c.City
order by c.City, year(s.[Delivery Date Key]);