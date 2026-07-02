-- BUILDING THE SCHEMA --

-- Orders Table --
CREATE TABLE `olist`.`orders` (
  `order_id` VARCHAR(32) NOT NULL,
  `customer_id` VARCHAR(32) NULL,
  `order_status` VARCHAR(45) NULL,
  `order_purchase_timestamp` TIMESTAMP NULL,
  `order_approved_at` TIMESTAMP NULL,
  `order_delivered_carrier_date` TIMESTAMP NULL DEFAULT NULL,
  `order_delivery_customer_date` TIMESTAMP NULL DEFAULT NULL,
  `order_estimated_delivery_date` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`));

-- Load Orders CSV Into Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv' 
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Reviews Table --
