use WWIGlobal
go
CREATE SCHEMA sales;
go
CREATE SCHEMA users;
go
CREATE SCHEMA logs;
go
CREATE SCHEMA coreData;
go

drop table if exists WWIGlobal.coreData.color;
create table WWIGlobal.coreData.color(
	color_id tinyint IDENTITY(1,1) PRIMARY KEY, 
	color_name varchar(30) NOT NULL
) on readOnly_filegroup

drop table if exists WWIGlobal.coreData.package;
create table WWIGlobal.coreData.package(
	package_id tinyint IDENTITY(1,1) PRIMARY KEY, 
	package_name varchar(30) NOT NULL
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.category;
create table WWIGlobal.coreData.category(
	category_id tinyint IDENTITY(1,1) PRIMARY KEY, 
	category_name varchar(30) NOT NULL
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.continent;
create table WWIGlobal.coreData.continent(
	continent_name varchar(30) PRIMARY KEY
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.country;
create table WWIGlobal.coreData.country(
	country_name varchar(50) PRIMARY KEY,
	country_continent_name varchar(30),
	FOREIGN KEY (country_continent_name) REFERENCES WWIGlobal.coreData.continent (continent_name)
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.state;
create table WWIGlobal.coreData.state(
	state_code char(2) PRIMARY KEY, 
	state_name varchar(50) not null, 
	state_country_name varchar(50),
	FOREIGN KEY (state_country_name) REFERENCES WWIGlobal.coreData.country (country_name)
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.salesterritory;
create table WWIGlobal.coreData.salesterritory(
	salesterritory_id int IDENTITY(1,1) PRIMARY KEY, 
	salesterritory_name varchar(50)  NOT NULL
)on readOnly_filegroup

drop table if exists WWIGlobal.coreData.city;
create table WWIGlobal.coreData.city(
	city_id int IDENTITY(1,1) PRIMARY KEY, 
	city_name varchar(50)  NOT NULL, 
	city_postal_code varchar(30)  NOT NULL, 
	city_state_code char(2),
	city_last_recorded_population bigint  NOT NULL, 
	city_salesterritory_id int,
	FOREIGN KEY (city_state_code) REFERENCES WWIGlobal.coreData.state (state_code),
	FOREIGN KEY (city_salesterritory_id) REFERENCES WWIGlobal.coreData.salesterritory (salesterritory_id)
)on readOnly_filegroup

drop table if exists WWIGlobal.users.company;
create table WWIGlobal.users.company(
	company_id smallint IDENTITY(1,1) PRIMARY KEY, 
	company_name varchar(30)  NOT NULL
);

drop table if exists WWIGlobal.users.employee;
create table WWIGlobal.users.employee(
	employee_id int IDENTITY(1,1) PRIMARY KEY, 
	employee_name varchar(60)  NOT NULL, 
	employee_isSalesperson bit  NOT NULL, 
	employee_photo varbinary(MAX)
);

drop table if exists WWIGlobal.users.customer;
create table WWIGlobal.users.customer(
	customer_WWI_id int IDENTITY(1,1) PRIMARY KEY, 
	customer_name varchar(40)  NOT NULL, 
	customer_category_id tinyint, 
	customer_company_id smallint, 
	customer_primary_contact varchar(60)  NOT NULL,
	customer_city_id int,
	customer_bill_to_id int,
	FOREIGN KEY (customer_bill_to_id) REFERENCES WWIGlobal.users.customer (customer_WWI_id),
	FOREIGN KEY (customer_category_id) REFERENCES WWIGlobal.coreData.category (category_id),
	FOREIGN KEY (customer_company_id) REFERENCES WWIGlobal.users.company (company_id),
	FOREIGN KEY (customer_city_id) REFERENCES WWIGlobal.coreData.city (city_id)
);

drop table if exists WWIGlobal.users.wwiuser;
create table WWIGlobal.users.wwiuser(
	wwiuser_id int IDENTITY(1,1) PRIMARY KEY, 
	wwiuser_email varchar(80)  NOT NULL, 
	wwiuser_password varchar(30)  NOT NULL, 
	wwiuser_customer_id int,
	FOREIGN KEY (wwiuser_customer_id) REFERENCES WWIGlobal.users.customer (customer_WWI_id)
);

drop table if exists WWIGlobal.users.token;
create table WWIGlobal.users.token(
	token char(9) PRIMARY KEY, 
	token_creation_date datetime NOT NULL, 
	token_user_id int,
	FOREIGN KEY (token_user_id) REFERENCES WWIGlobal.users.wwiuser (wwiuser_id)
);

drop table if exists WWIGlobal.sales.promotion;
create table WWIGlobal.sales.promotion(
	promotion_id int IDENTITY(1,1) PRIMARY KEY, 
	promotion_quantity tinyint NOT NULL, 
	promotion_inicial_date date NOT NULL, 
	promotion_end_date date NOT NULL
) on intensive_filegroup

drop table if exists WWIGlobal.sales.stock;
create table WWIGlobal.sales.stock(
	stock_id int IDENTITY(1,1) PRIMARY KEY, 
	stock_item varchar(100) NOT NULL, 
	stock_color_id tinyint, 
	stock_selling_package_id tinyint,
	stock_buying_package_id tinyint, 
	stock_brand varchar(30) NOT NULL, 
	stock_size varchar(40) NOT NULL, 
	stock_lead_time_days tinyint NOT NULL, 
	stock_per_outer smallint NOT NULL, 
	stock_isChiller bit NOT NULL, 
	stock_barcode char(13), 
	stock_tax_rate decimal(18, 3) NOT NULL, 
	stock_unitprice decimal(18, 2) NOT NULL, 
	stock_recommended_retail_price decimal(18, 2), 
	stock_weight_per_unit decimal(18, 3) NOT NULL,
	FOREIGN KEY (stock_color_id) REFERENCES WWIGlobal.coreData.color (color_id),
	FOREIGN KEY (stock_selling_package_id) REFERENCES WWIGlobal.coreData.package (package_id),
	FOREIGN KEY (stock_buying_package_id) REFERENCES WWIGlobal.coreData.package (package_id)
)on intensive_filegroup

drop table if exists WWIGlobal.sales.sale;
create table WWIGlobal.sales.sale(
	sale_id bigint IDENTITY(1,1) PRIMARY KEY, 
	sale_invoice_date date NOT NULL, 
	sale_delivery_date date, 
	sale_salesperson_id int,
	FOREIGN KEY (sale_salesperson_id) REFERENCES WWIGlobal.users.employee (employee_id)
)on intensive_filegroup

drop table if exists WWIGlobal.sales.stock_promotion;
create table WWIGlobal.sales.stock_promotion(
	stock_id int,
	promotion_id int,
	FOREIGN KEY (stock_id) REFERENCES WWIGlobal.sales.stock (stock_id),
	FOREIGN KEY (promotion_id) REFERENCES WWIGlobal.sales.promotion (promotion_id),
	PRIMARY KEY (stock_id, promotion_id)
) on intensive_filegroup

drop table if exists WWIGlobal.sales.sale_stock;
create table WWIGlobal.sales.sale_stock(
	sale_stock_id bigint IDENTITY(1,1) PRIMARY KEY, 
	sale_id bigint, 
	sale_city_id int,
	sale_customer_id int,
	stockItem_id int, 
	sale_description varchar(150) NOT NULL, 
	sale_quantity int NOT NULL,
	sale_unit_price float NOT NULL,
	sale_tax_rate float NOT NULL,
	FOREIGN KEY (sale_city_id) REFERENCES WWIGlobal.coredata.city (city_id),
	FOREIGN KEY (sale_customer_id) REFERENCES WWIGlobal.users.customer (customer_WWI_id),
	FOREIGN KEY (sale_id) REFERENCES WWIGlobal.sales.sale (sale_id),
	FOREIGN KEY (stockItem_id) REFERENCES WWIGlobal.sales.stock (stock_id)
) on intensive_filegroup

-- ******************************************************************************************************************
-- Gestãodrop table if exists WWIGlobal.logs.error_log;
create table WWIGlobal.logs.error_log(
	error_log_id int identity(1,1) primary key,
	error_log_error int,
	error_log_sql_user varchar(50),
	error_log_date datetime
) on log_filegroup

drop table if exists WWIGlobal.logs.TableStats;
create table WWIGlobal.logs.TableStats(
TableStats_id int identity(1,1) primary key, 
TableStats_table_name sysname,
TableStats_row_count int,
TableStats_reserved_size_mb float,
TableStats_unused_size_mb float,
TableStats_stats_date datetime
) on log_filegroup

drop table if exists WWIGlobal.logs.table_info;
create table WWIGlobal.logs.table_info(
table_info_id int identity(1,1) primary key, 
tablee_info_name SYSNAME,
tablee_info_column_name SYSNAME,
tablee_info_column_data_type VARCHAR(50),
tablee_info_column_maximum_length INT,
tablee_info_column_is_nullable VARCHAR(3),
tablee_info_column_constraint_type VARCHAR(50),
tablee_info_column_constraint_name SYSNAME
) on log_filegroup