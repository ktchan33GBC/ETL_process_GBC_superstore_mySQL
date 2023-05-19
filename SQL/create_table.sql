
USE gbc_superstore;

/* Create table relational managers */
CREATE TABLE IF NOT EXISTS regional_managers (
	regional_manager VARCHAR(20) NOT NULL,
	region varchar(20) NOT NULL,
	PRIMARY KEY (region)
);

/* Create table addresses */
CREATE TABLE IF NOT EXISTS addresses (
	address_id varchar(20) NOT NULL,
	postal_code varchar(20) NOT NULL,
	city varchar(20) NOT NULL,
	state varchar(20) NOT NULL,
	region varchar(20) NOT NULL,
	country varchar(20) NOT NULL,
	PRIMARY KEY (address_id),
    FOREIGN KEY (region) REFERENCES regional_managers(region)
);

/* Create table products */
CREATE TABLE IF NOT EXISTS products (
	product_id varchar(20) NOT NULL,
	category varchar(20) NOT NULL,
	sub_category varchar(20) NOT NULL,
	product_name varchar(255) NOT NULL,
	PRIMARY KEY (product_id)
);


/* Create table customers */
CREATE TABLE IF NOT EXISTS customers (
	customer_id varchar(20) NOT NULL,
	customer_name varchar(30) NOT NULL,
	segment varchar(20) NOT NULL,
	PRIMARY KEY (customer_id)
);

/* Create table orders */
CREATE TABLE IF NOT EXISTS orders (
	order_id varchar(20) NOT NULL,
	customer_id varchar(20) NOT NULL ,
	product_id varchar(20) NOT NULL ,
	sales double NOT NULL,
	quantity DECIMAL(32,0) NOT NULL,
	discount double NOT NULL,
	profit double NOT NULL,
	order_date DATE NOT NULL,
	address_id varchar(20) NOT NULL,
	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (address_id) REFERENCES addresses(address_id)
);


/* Create table shipments */
CREATE TABLE IF NOT EXISTS shipments (
	order_id varchar(20) NOT NULL,
	ship_date date NOT NULL,
	ship_mode varchar(20) NOT NULL,
	PRIMARY KEY (order_id),
	FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

/* Create table returns */
CREATE TABLE IF NOT EXISTS returns (
	order_id varchar(20) NOT NULL,
	returned varchar(20) NOT NULL,
	PRIMARY KEY (order_id),
	FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

/* Create table metadata */
create table IF NOT EXISTS customer_metadata (
	customer_id VARCHAR(20) NOT NULL,
	customer_name varchar(20) NOT NULL,
	date_record_created datetime not null,
	CRUD_role varchar(20) not null,
	CRUD_permission_create varchar(1) not null,
	CRUD_permission_read varchar(1) not null,
	CRUD_permission_update varchar(1) not null,
	CRUD_permission_delete varchar(1) not null,
	PRIMARY KEY (customer_id)
);

