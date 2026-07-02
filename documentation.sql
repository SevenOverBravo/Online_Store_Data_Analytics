-- BUILDING THE SCHEMA --

-- Orders Table --
CREATE TABLE `olist`.`orders` (
  `order_id` VARCHAR(32) NOT NULL,
  `customer_id` VARCHAR(32) NULL,
  `order_status` VARCHAR(45) NULL,
  `order_purchase_timestamp` DATETIME NULL,
  `order_approved_at` DATETIME NULL,
  `order_delivered_carrier_date` DATETIME NULL,
  `order_delivery_customer_date` DATETIME NULL,
  `order_estimated_delivery_date` DATETIME NULL,
  PRIMARY KEY (`order_id`));

-- Reviews Table --
