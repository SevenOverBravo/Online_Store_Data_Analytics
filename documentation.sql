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

-- BASELINE INFO --

-- Number of customers from each state --
SELECT customer_state, COUNT(customer_id) AS NUM_CUSTOMERS
FROM customers
GROUP BY customer_state
ORDER BY NUM_CUSTOMERS DESC
  -- Top 3 are SP (41746), RJ (12852), and MG (11635) out of 112650 customers
  
-- Average # of items purchased per order --
SELECT AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM orders o JOIN items i 
	    ON o.order_id = i.order_id
	  GROUP BY o.order_id) AS INF 
    -- Returns 1.142, but neglects any possible outliers in cities with low customer counts

-- Recalculate Average with Caveat: Remove orders associated with customers from cities with less than 20 customers overall
WITH elligible_cities (customer_city) 
AS (
	SELECT customer_city
    FROM customers
    GROUP BY customer_city
    HAVING COUNT(DISTINCT customer_id)>=20)
SELECT AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT c.customer_city, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM customers c
		JOIN orders o ON c.customer_id=o.customer_id
        JOIN items i ON o.order_id=i.order_id
      WHERE c.customer_city IN (SELECT * FROM elligible_cities)
	  GROUP BY c.customer_city, o.order_id) AS DIST
   -- Returns 1.144; Not significantly different from non-filtered counterpart
  
-- Analysis Pt. 1: Customer Factors (Location) --

-- First: Confirm No Null/Improper Entries in Target Columns --
SELECT COUNT(zip_code_prefix) AS ZIP_NUM, COUNT(customer_city) AS CITY_NUM, COUNT(customer_state) AS STATE_NUM
FROM customers
WHERE (zip_code_prefix IS NOT NULL AND zip_code_prefix REGEXP '^[0-9]{4,5}$') -- Not Null and a sequence of 4 or 5 numbers
	AND customer_city IS NOT NULL
  AND (customer_state IS NOT NULL AND customer_state REGEXP '^[A-Z]{2}$'); -- Not Null and a sequence of 2 letters
  -- Output shows no row is invalid (Counts = Number of Rows)

-- Customer State: Average items ordered and Number of customers for each
WITH elligible_cities (customer_city) 
AS (
	SELECT customer_city
    FROM customers
    GROUP BY customer_city
    HAVING COUNT(DISTINCT customer_id)>=20)
SELECT DIST.customer_state, COUNT(DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT c.customer_state, c.customer_city, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM customers c
		JOIN orders o ON c.customer_id=o.customer_id
        JOIN items i ON o.order_id=i.order_id
      WHERE c.customer_city IN (SELECT * FROM elligible_cities)
	  GROUP BY c.customer_state, c.customer_city, o.order_id) AS DIST
GROUP BY DIST.customer_state
ORDER BY AVG_ITEMS_PER_ORDER DESC
  -- Output: Ranges from 
  
-- Customer City: Average items ordered and Number of customers for each 
SELECT DIST.customer_city, COUNT(DIST.customer_id) AS NUM_CUSTOMERS, AVG(DIST.order_item_id) as AVG_ITEMS
FROM (SELECT DISTINCT c.customer_city, c.customer_id, i.order_item_id
FROM customers c, orders o, items i
WHERE o.customer_id = c.customer_id
	AND o.order_id = i.order_id) AS DIST
GROUP BY DIST.customer_city
ORDER BY AVG_ITEMS DESC
 -- Many cities with 4, 5, or up to 6.5 items purchased per order on average
 -- Majority of cities in top 20 (for average items purchased per order) a

-- Additional Query: State, City, and Zip Code -- 

