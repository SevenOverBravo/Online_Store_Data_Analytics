-- BUILDING THE SCHEMA --

-- Create Schema --
CREATE SCHEMA `olist` ;

-- Orders Table --
CREATE TABLE `olist`.`orders` (
  `order_id` VARCHAR(32) NOT NULL,
  `customer_id` VARCHAR(32) NULL,
  `order_status` VARCHAR(45) NULL,
  `order_purchase_timestamp` DATETIME NULL,
  `order_approved_at` DATETIME NULL,
  `order_delivered_carrier_date` DATETIME NULL DEFAULT NULL,
  `order_delivery_customer_date` DATETIME NULL DEFAULT NULL,
  `order_estimated_delivery_date` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`));

-- Load Orders CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv' 
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Reviews Table --
CREATE TABLE `olist`.`items` (
  `order_id` VARCHAR(45) NOT NULL,
  `order_item_id` VARCHAR(45) NULL,
  `product_id` VARCHAR(45) NULL,
  `seller_id` VARCHAR(45) NULL,
  `shipping_limit_date` DATETIME NULL,
  `price` INT NULL,
  `freight_value` INT NULL,
  PRIMARY KEY (`order_id`, `order_item_id`));

-- Load Reviews CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Products Table --
CREATE TABLE `olist`.`products` (
  `product_id` VARCHAR(45) NOT NULL,
  `product_category_name` VARCHAR(45) NULL,
  `product_name_length` INT NULL,
  `product_description_length` INT NULL,
  `product_photos_qty` INT NULL,
  `product_weight_g` INT NULL,
  `product_length_cm` INT NULL,
  `product_height_cm` INT NULL,
  `product_width_cm` INT NULL,
  PRIMARY KEY (`product_id`));

-- Load Products CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Sellers Table --
CREATE TABLE `olist`.`sellers` (
  `seller_id` VARCHAR(45) NOT NULL,
  `zip_code_prefix` VARCHAR(45) NULL,
  `seller_city` VARCHAR(45) NULL,
  `seller_state` VARCHAR(45) NULL,
  PRIMARY KEY (`seller_id`));

-- Load Sellers CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Payments Table --
CREATE TABLE `olist`.`payments` (
  `order_id` VARCHAR(45) NOT NULL,
  `payment_sequential` INT NOT NULL,
  `payment_type` VARCHAR(45) NULL,
  `payment_installments` INT NULL,
  `payment_value` FLOAT NULL,
  PRIMARY KEY (`order_id`, `payment_sequential`));

-- Load Sellers CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Customers Table --
CREATE TABLE `olist`.`customers` (
  `customer_id` VARCHAR(45) NOT NULL,
  `customer_unique_id` VARCHAR(45) NULL,
  `customer_state` VARCHAR(45) NULL,
  `customer_city` VARCHAR(45) NULL,
  `zip_code_prefix` VARCHAR(45) NULL,
  PRIMARY KEY (`customer_id`));

-- Load Sellers CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Geolocation Table --
CREATE TABLE `olist`.`geolocation` (
  `zip_code_prefix` VARCHAR(45) NOT NULL,
  `geolocation_lat` FLOAT NULL,
  `geolocation_lng` FLOAT NULL,
  `geolocation_city` VARCHAR(45) NULL,
  `geolocation_state` VARCHAR(45) NULL,
  PRIMARY KEY (`zip_code_prefix`));

-- Load Geolocation CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
