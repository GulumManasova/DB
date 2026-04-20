CREATE TABLE `Geography` (
  `geo_id` int PRIMARY KEY AUTO_INCREMENT,
  `country` varchar(255),
  `city` varchar(255),
  `state` varchar(255),
  `postal_code` varchar(255),
  `region` varchar(255)
);

CREATE TABLE `Customers` (
  `customer_id` varchar(255) PRIMARY KEY,
  `customer_name` varchar(255),
  `segment` varchar(255),
  `geo_id` int
);

CREATE TABLE `Products` (
  `product_id` varchar(255) PRIMARY KEY,
  `product_name` varchar(255),
  `category` varchar(255),
  `sub_category` varchar(255)
);

CREATE TABLE `Orders` (
  `order_id` varchar(255) PRIMARY KEY,
  `order_date` date,
  `customer_id` varchar(255)
);

CREATE TABLE `Order_Items` (
  `order_item_id` int PRIMARY KEY AUTO_INCREMENT,
  `order_id` varchar(255),
  `product_id` varchar(255),
  `sales` decimal,
  `quantity` int,
  `discount` decimal,
  `profit` decimal
);

CREATE TABLE `Shipments` (
  `shipment_id` int PRIMARY KEY AUTO_INCREMENT,
  `order_id` varchar(255),
  `ship_date` date,
  `ship_mode` varchar(255)
);

ALTER TABLE `Customers` ADD FOREIGN KEY (`geo_id`) REFERENCES `Geography` (`geo_id`);

ALTER TABLE `Orders` ADD FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`);

ALTER TABLE `Order_Items` ADD FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`);

ALTER TABLE `Order_Items` ADD FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`);

ALTER TABLE `Shipments` ADD FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`);
