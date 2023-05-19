select * from customer;
ALTER TABLE customer MODIFY `Customer ID` VARCHAR(20);
ALTER TABLE customer MODIFY `Customer Name` VARCHAR(30);
ALTER TABLE customer MODIFY `Segment` VARCHAR(20);
ALTER TABLE customer ADD PRIMARY KEY(`Customer ID`);

select * from rm;
ALTER TABLE rm MODIFY `Regional Manager` VARCHAR(20);
ALTER TABLE rm MODIFY Region VARCHAR(20);
ALTER TABLE rm ADD PRIMARY KEY(`Region`);

select * from address;
ALTER TABLE address ADD address_id INT UNSIGNED NOT NULL AUTO_INCREMENT, ADD PRIMARY KEY (address_id);
ALTER TABLE address MODIFY `Postal Code` VARCHAR(20);
ALTER TABLE address MODIFY `City` VARCHAR(20);
ALTER TABLE address MODIFY `Country/Region` VARCHAR(20);
ALTER TABLE address MODIFY `State` VARCHAR(20);
ALTER TABLE address MODIFY Region VARCHAR(20);
ALTER TABLE address MODIFY `address_id` VARCHAR(20);
ALTER TABLE address ADD FOREIGN KEY (Region) REFERENCES rm (Region);

select * from `to_returns`;
ALTER TABLE `to_returns` MODIFY `Order ID` VARCHAR(20);
ALTER TABLE `to_returns` MODIFY `Returned` VARCHAR(20);
ALTER TABLE `to_returns` ADD PRIMARY KEY(`Order ID`);

select * from ship;
ALTER TABLE ship MODIFY `Order ID` VARCHAR(20);
ALTER TABLE ship MODIFY `Ship mode` VARCHAR(20);
ALTER TABLE ship MODIFY `Ship Date` DATE;
ALTER TABLE ship ADD PRIMARY KEY(`Order ID`);

select * from product;
ALTER TABLE product MODIFY `Product ID` VARCHAR(20);
ALTER TABLE product MODIFY `Category` VARCHAR(20);
ALTER TABLE product MODIFY `Sub-Category` VARCHAR(20);
ALTER TABLE product MODIFY `Product Name` VARCHAR(255);
ALTER TABLE product ADD PRIMARY KEY(`Product ID`);

select * from to_orders;

SELECT STR_TO_DATE(`Order Date`,'%Y-%m-%d') from to_orders;

ALTER TABLE `to_orders` MODIFY `Order ID` VARCHAR(20);
ALTER TABLE `to_orders` MODIFY `Product ID` VARCHAR(20);
ALTER TABLE `to_orders` MODIFY `Customer ID` VARCHAR(20);
ALTER TABLE `to_orders` MODIFY `Order ID` VARCHAR(20);
ALTER TABLE `to_orders` MODIFY `Postal Code` VARCHAR(20);
ALTER TABLE to_orders ADD COLUMN address_id INT NOT NULL;
ALTER TABLE `to_orders` MODIFY `address_id` VARCHAR(20);
UPDATE to_orders, address SET to_orders.address_id = address.address_id WHERE to_orders.`Postal Code` = address.`Postal Code`;
ALTER TABLE to_orders DROP `Postal Code`;

CREATE TABLE order_table as SELECT address_id, `Order ID`, `Product ID`, `Customer ID`, `Order Date`,sum(Sales) as Sales, Discount, 
sum(Quantity) as Quantity, sum(Profit) as Profit FROM to_orders GROUP BY `Order ID`, `Product ID`;

select * from order_table;

ALTER TABLE order_table MODIFY `Order Date` DATE;
ALTER TABLE order_table ADD PRIMARY KEY (`Order ID`, `Product ID`);

ALTER TABLE order_table ADD FOREIGN KEY (`Order ID`) REFERENCES ship (`Order ID`);
ALTER TABLE order_table ADD FOREIGN KEY (`Order ID`) REFERENCES `to_returns` (`Order ID`);
ALTER TABLE order_table ADD FOREIGN KEY (`address_id`) REFERENCES address (`address_id`);
ALTER TABLE order_table ADD FOREIGN KEY (`Product ID`) REFERENCES product (`Product ID`);
ALTER TABLE order_table ADD FOREIGN KEY (`Customer ID`) REFERENCES customer (`Customer ID`);

#SHOW CREATE TABLE order_table;
