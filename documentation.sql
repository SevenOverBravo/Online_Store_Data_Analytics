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

-- Analysis Pt. 1: Customer Factors (Location) --

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
	  GROUP BY o.order_id) AS DIST
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

-- First: Confirm No Null/Improper Entries in Target Columns --
SELECT COUNT(zip_code_prefix) AS ZIP_NUM, COUNT(customer_city) AS CITY_NUM, COUNT(customer_state) AS STATE_NUM
FROM customers
WHERE (zip_code_prefix IS NOT NULL AND zip_code_prefix REGEXP '^[0-9]{4,5}$') -- Not Null and a sequence of 4 or 5 numbers
	AND customer_city IS NOT NULL
  AND (customer_state IS NOT NULL AND customer_state REGEXP '^[A-Z]{2}$'); -- Not Null and a sequence of 2 letters
  -- Output shows no row is invalid (Counts = Number of Rows)

-- Customer State: Average items ordered and Number of customers for each
WITH elligible_cities (customer_state, customer_city) 
AS (
	SELECT customer_state, customer_city
    FROM customers
    GROUP BY customer_state, customer_city
    HAVING COUNT(DISTINCT customer_id)>=20)
SELECT DIST.customer_state, COUNT(DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT c.customer_state, c.customer_city, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM customers c
		JOIN orders o ON c.customer_id=o.customer_id
        JOIN items i ON o.order_id=i.order_id
      WHERE (c.customer_state, c.customer_city) IN (SELECT customer_state, customer_city FROM elligible_cities)
	  GROUP BY c.customer_state, c.customer_city, o.order_id) AS DIST
GROUP BY DIST.customer_state
  -- Output: Top 3 states in terms of average items per order (AIPO) are MT (1.193), GO (1.180), and PB (1.165); not much different from overall average of 1.144
  -- Eight of the ten states with above-average AIPO have >300 orders; high sample size indicates accurate averages
  
-- Customer City: Average items ordered and Number of customers for each --
WITH elligible_cities (customer_state, customer_city) 
AS (
	SELECT customer_state, customer_city
    FROM customers
    GROUP BY customer_state, customer_city
    HAVING COUNT(DISTINCT customer_id)>=20)
SELECT DIST.customer_state, DIST.customer_city, COUNT(DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT c.customer_state, c.customer_city, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM customers c
		JOIN orders o ON c.customer_id=o.customer_id
        JOIN items i ON o.order_id=i.order_id
      WHERE (c.customer_state, c.customer_city) IN (SELECT customer_state, customer_city FROM elligible_cities)
	  GROUP BY c.customer_state, c.customer_city, o.order_id) AS DIST
GROUP BY DIST.customer_state, DIST.customer_city
ORDER BY AVG_ITEMS_PER_ORDER DESC
 -- Top 3 cities are Uniao da Vitoria (PR, AIPO = 1.621), Peruibe (SP, AIPO = 1.455), and Santana do Livramento (RS, AIPO = 1.450)
 -- In the Top 20 cities, eight are in SP, three in SC, two in RS, PR, and RJ, and one in MT, GO, and BA
 -- Accuracy of averages is less certain due to most sample sizes falling between 20 and 100

-- Customer Zip Code: Average items ordered and Number of customers for each --
WITH elligible_cities (customer_state, customer_city) 
AS (
	SELECT customer_state, customer_city
    FROM customers
    GROUP BY customer_state, customer_city
    HAVING COUNT(DISTINCT customer_id)>=20)
SELECT DIST.customer_state, DIST.customer_city, DIST.zip_code_prefix, COUNT(DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT c.customer_state, c.customer_city, c.zip_code_prefix, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM customers c
		JOIN orders o ON c.customer_id=o.customer_id
        JOIN items i ON o.order_id=i.order_id
      WHERE (c.customer_state, c.customer_city) IN (SELECT customer_state, customer_city FROM elligible_cities)
	  GROUP BY c.customer_state, c.customer_city, c.zip_code_prefix, o.order_id) AS DIST
GROUP BY DIST.customer_state, DIST.customer_city, DIST.zip_code_prefix
ORDER BY AVG_ITEMS_PER_ORDER DESC
 -- Multiple zip codes in the ranges of 4-7 AIPO; primarily located in SP
 -- Number of orders is so low that this is unikely to extrapolate to a larger order sample

-- Analysis Part 2: Seller Factors --

-- Seller ID (note that sellers are left unnamed in the data set and are only identified by unique IDs)--

-- Begin with basic query displaying unfiltered AIPO and number of orders for each seller ID --
SELECT DIST.seller_id, COUNT(DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT s.seller_id, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  GROUP BY s.seller_id, order_id) AS DIST
GROUP BY DIST.seller_id
ORDER BY AVG_ITEMS_PER_ORDER DESC
 -- Output reveals many sellers are only involved with one or two orders; generates possible bias in the average

-- New query, now requiring each seller to be associated with at least 10 orders to be included in AIPO calculation
WITH elligible_sellers (seller_id) AS (
	SELECT s.seller_id
    FROM items i
		JOIN orders o ON i.order_id=o.order_id 
        JOIN sellers s ON i.seller_id=s.seller_id
	GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id)>=10) 
SELECT AVG(NUM_ITEMS) AS AVG_ITEMS_PER_CUSTOMER
FROM (SELECT s.seller_id, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  WHERE s.seller_id IN (SELECT seller_id FROM elligible_sellers)
	  GROUP BY s.seller_id, order_id) AS DIST 
 -- Outputs 1.123, slightly lower than base AIPO of 1.142

-- Rework above query to include seller ID and number of orders 
WITH elligible_sellers (seller_id) AS (
	SELECT s.seller_id
    FROM items i
		JOIN orders o ON i.order_id=o.order_id 
        JOIN sellers s ON i.seller_id=s.seller_id
	GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id)>=10) 
SELECT DIST.seller_id, COUNT(DISTINCT DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_CUSTOMER
FROM (SELECT s.seller_id, o.order_id, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  WHERE s.seller_id IN (SELECT seller_id FROM elligible_sellers)
	  GROUP BY s.seller_id, order_id) AS DIST
GROUP BY DIST.seller_id
ORDER BY AVG_ITEMS_PER_CUSTOMER DESC
-- Top three sellers in terms of AIPO are those with IDs beginning in eed78 (2.546), 334ca (2.367), and e7d5b (2.250)
-- Many sellers with >100 orders also have high AIPOs, like 25c5c (158 orders, AIPO = 1.703) and 1025f (915 orders, AIPO = 1.561)
-- High order number and AIPO signals accurate long-term averages and opportunities to improve overall AIPO

-- Seller Location --

-- Seller State --
-- AIPO per seller_state and number of sellers/orders from each, keeping the same filter as above
WITH elligible_sellers (seller_id) AS (
	SELECT s.seller_id
    FROM items i
		JOIN orders o ON i.order_id=o.order_id 
        JOIN sellers s ON i.seller_id=s.seller_id
	GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id)>=10) 
SELECT DIST.seller_state, COUNT(DISTINCT DIST.seller_id) AS NUM_SELLERS, COUNT(DISTINCT DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT s.seller_id, o.order_id, s.seller_state, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  WHERE s.seller_id IN (SELECT seller_id FROM elligible_sellers)
	  GROUP BY s.seller_id, order_id, s.seller_state) AS DIST
GROUP BY DIST.seller_state
ORDER BY AVG_ITEMS_PER_ORDER DESC
 -- Top three states in terms of AIPO are ES (1.183), BA (1.135), and SP (1.129)
 -- Increases from base AIPO are minimal, and both ES and BA have low seller/order counts; suggests innacurate averages in the long term

-- Seller City --
-- AIPO per seller_city (including seller_state) and number of sellers/orders from each
WITH elligible_sellers (seller_id) AS (
	SELECT s.seller_id
    FROM items i
		JOIN orders o ON i.order_id=o.order_id 
        JOIN sellers s ON i.seller_id=s.seller_id
	GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id)>=10) 
SELECT DIST.seller_state, DIST.seller_city, COUNT(DISTINCT DIST.seller_id) AS NUM_SELLERS, COUNT(DISTINCT DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT s.seller_id, o.order_id, s.seller_state, s.seller_city, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  WHERE s.seller_id IN (SELECT seller_id FROM elligible_sellers)
	  GROUP BY s.seller_id, order_id, s.seller_state) AS DIST
GROUP BY DIST.seller_state, DIST.seller_city
ORDER BY AVG_ITEMS_PER_ORDER DESC 
 -- Top three cities in terms of AIPO are Fernandopolis (state is SP, AIPO = 2.057), Campina das Missoes (state is RS, AIPO = 1.909) and Portao (state is RS, AIPO = 1.8667)
 -- Most cities have only one seller, but some have high seller, order, and AIPO counts (Sao Jose do Rio Preto, for example) reinforcing the validity of their measurements
 -- Possible correlation between seller_city and AIPO with some locations, but not robust enough in most cases 

-- Seller Zip Code Prefix --
-- AIPO per zip_code_prefix (including seller_state and seller_city) and number of sellers/orders from each
WITH elligible_sellers (seller_id) AS (
	SELECT s.seller_id
    FROM items i
		JOIN orders o ON i.order_id=o.order_id 
        JOIN sellers s ON i.seller_id=s.seller_id
	GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id)>=10) 
SELECT DIST.seller_state, DIST.seller_city, DIST.zip_code_prefix, COUNT(DISTINCT DIST.seller_id) AS NUM_SELLERS, COUNT(DISTINCT DIST.order_id) AS NUM_ORDERS, AVG(NUM_ITEMS) AS AVG_ITEMS_PER_ORDER
FROM (SELECT s.seller_id, o.order_id, s.seller_state, s.seller_city, s.zip_code_prefix, COUNT(i.order_item_id) AS NUM_ITEMS
	  FROM items i
		  JOIN orders o ON i.order_id=o.order_id
		  JOIN sellers s ON s.seller_id=i.seller_id
	  WHERE s.seller_id IN (SELECT seller_id FROM elligible_sellers)
	  GROUP BY s.seller_id, order_id, s.seller_state) AS DIST
GROUP BY DIST.seller_state, DIST.seller_city, DIST.zip_code_prefix
ORDER BY AVG_ITEMS_PER_ORDER DESC 
-- Majority of top ten zipcodes are located in SP, with many exceeding an averages items per order of two
-- Most zipcodes only have one seller; likely high colinearlity with the seller_id findings
