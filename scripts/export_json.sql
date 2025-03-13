use WWIGlobal
select  sale.sale_id, '{"id":'+ CONVERT(VARCHAR, sale.sale_id) +' ,"invoinceDate":"'+ ISNULL(CONVERT(VARCHAR, sale_invoice_date), 'NULL') +'", "deliveryDate":"'+ ISNULL(CONVERT(VARCHAR, sale_delivery_date), 'NULL') +'", "sellerName":"'+ CONVERT(VARCHAR, employee_name) +'", "saleStocks":'+ ISNULL((
		SELECT stockItem_id as stockId, stock_brand as brand, sale_quantity as quantity, CAST(sale_unit_price AS DECIMAL(10, 2)) as unitPrice, CAST(sale_tax_rate AS DECIMAL(10, 2)) as taxRate 
		FROM WWIGlobal.sales.sale_stock
		inner join WWIGlobal.sales.stock on stock_id = stockItem_id
		where sale_id = sale.sale_id
		FOR JSON PATH), '[]') +'},'
from sales.sale as sale
inner join WWIGlobal.users.employee on employee_id = sale_salesperson_id