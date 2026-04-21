CREATE DATABASE superstore;
USE superstore;

-- creating tables from ER
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

-- define relationships and adding fk
ALTER TABLE `Customers` ADD FOREIGN KEY (`geo_id`) REFERENCES `Geography` (`geo_id`);
ALTER TABLE `Orders` ADD FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`);
ALTER TABLE `Order_Items` ADD FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`);
ALTER TABLE `Order_Items` ADD FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`);
ALTER TABLE `Shipments` ADD FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`);

-- filling tables with data from unnormalized table
INSERT INTO geography(geo_id, country, city, state, postal_code, region)
SELECT DISTINCT `row id`, country, city, state, `postal code`, region FROM superstore;
SELECT * FROM geography;

INSERT INTO customers (customer_id, customer_name, segment, geo_id)
SELECT s.`Customer ID`, MAX(s.`Customer Name`), MAX(s.Segment), MIN(g.geo_id)
FROM superstore s JOIN geography g ON s.Country = g.country AND s.City = g.city
AND s.State = g.state AND s.`Postal Code` = g.postal_code AND s.Region = g.region
GROUP BY s.`Customer ID`;
SELECT * FROM customers;

INSERT INTO products (product_id, product_name, category, sub_category)
SELECT `Product ID`, MAX(`Product Name`), MAX(Category), MAX(`Sub-Category`)
FROM superstore GROUP BY `Product ID`;
SELECT * FROM products;

INSERT INTO orders (order_id, order_date, customer_id)
SELECT `Order ID`, STR_TO_DATE(MAX(`Order Date`), '%m/%d/%Y'), `Customer ID`
FROM superstore GROUP BY `Order ID`, `Customer ID`;
SELECT * FROM orders;

INSERT INTO order_items(order_id, product_id, sales, quantity, discount, profit)
SELECT o.order_id, p.product_id, s.`sales`, s.`quantity`, s.`discount`, s.`profit`
FROM superstore s JOIN orders o ON s.`order id`=o.order_id AND STR_TO_DATE(s.`Order Date`, '%m/%d/%Y') = o.order_date
JOIN products p ON s.`Product ID` = p.product_id;
SELECT * FROM order_items;

ALTER TABLE shipments CHANGE `ship_mode` ship_model VARCHAR(255); -- changed name of column for better understanding

ALTER TABLE shipments CHANGE ship_mode ship_model VARCHAR(255);
INSERT INTO shipments (shipment_id, order_id, ship_date, ship_model)
SELECT DISTINCT `Row ID`, `Order ID`, STR_TO_DATE(`Ship Date`, '%m/%d/%Y'), `Ship Mode` FROM superstore;
SELECT * FROM shipments;

-- 1. Find customer segments with highest profit per order.

SELECT c.segment, MAX(i.profit) AS max_profit
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.segment ORDER BY max_profit DESC LIMIT 1;

-- 2. Analyze how discounts affect profit margin.

SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low'
        WHEN discount <= 0.5 THEN 'Medium'
        ELSE 'High'
    END AS discount_group,
    AVG(profit / sales) AS avg_margin,
    SUM(profit) AS total_profit
FROM order_items GROUP BY discount_group;

-- 3. Identify regions or cities with the highest sales and profit
-- a) by regions
SELECT g.region, SUM(i.sales) AS total_sales, SUM(i.profit) AS total_profit
FROM customers c JOIN geography g ON c.geo_id = g.geo_id JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id GROUP BY g.region ORDER BY total_sales DESC;

-- b) by cities
SELECT g.city, SUM(i.sales) AS total_sales, SUM(i.profit) AS total_profit
FROM customers c JOIN geography g ON c.geo_id = g.geo_id JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id GROUP BY g.city ORDER BY total_sales DESC;

-- 4. Evaluate delivery performance by shipping model

-- a) average delivery time by model
SELECT sh.ship_model, AVG(DATEDIFF(sh.ship_date, o.order_date)) AS avg_delivery_days
FROM shipments sh JOIN orders o ON sh.order_id=o.order_id GROUP BY sh.ship_model ORDER BY avg_delivery_days;

-- b) affection on profit
SELECT sh.ship_model, AVG(i.profit) AS avg_profit, SUM(i.profit) AS total_profit
FROM shipments sh JOIN orders o ON sh.order_id = o.order_id 
JOIN order_items i ON o.order_id=i.order_id GROUP BY sh.ship_model;

-- c) number of orders
SELECT ship_model, COUNT(*) AS total_orders
FROM shipments GROUP BY ship_model;


SELECT * FROM geography LIMIT 5;
SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM shipments LIMIT 5;



-- SQL Insights
-- Insight 1. Which customer segments generate the highest profit?
SELECT c.segment, SUM(i.profit) AS total_profit
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
GROUP BY c.segment
ORDER BY total_profit DESC;
-- This query shows which customer segment contributes the highest total profit.

-- Insight 2. Which regions have the highest sales and profit?
SELECT g.region, SUM(i.sales) AS total_sales, SUM(i.profit) AS total_profit
FROM customers c
JOIN geography g ON c.geo_id = g.geo_id
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
GROUP BY g.region
ORDER BY total_sales DESC;
-- This query helps identify the strongest regions in terms of revenue and profitability.

-- Insight 3. How do discounts affect profit?
SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.5 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_group,
    AVG(profit) AS avg_profit,
    SUM(profit) AS total_profit
FROM order_items
GROUP BY discount_group;
-- This query analyzes whether higher discounts reduce or increase profitability

-- Insight 4. Which products are the most profitable?

SELECT p.product_name, SUM(i.profit) AS total_profit
FROM products p
JOIN order_items i ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 10;
-- This query identifies the products that generate the highest profit.

-- Views
-- View 1. customer_sales_summary

CREATE VIEW customer_sales_summary AS
SELECT c.customer_id,
       c.customer_name,
       c.segment,
       SUM(i.sales) AS total_sales,
       SUM(i.profit) AS total_profit
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
GROUP BY c.customer_id, c.customer_name, c.segment;

-- Проверка
SELECT * 
FROM customer_sales_summary
ORDER BY total_sales DESC
LIMIT 10;

-- View 2. regional_performance
CREATE VIEW regional_performance AS
SELECT g.region,
       SUM(i.sales) AS total_sales,
       SUM(i.profit) AS total_profit
FROM customers c
JOIN geography g ON c.geo_id = g.geo_id
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
GROUP BY g.region;

-- Проверка
SELECT * FROM regional_performance;

-- View 3.product_profit_summary
CREATE VIEW product_profit_summary AS
SELECT p.product_id,
       p.product_name,
       p.category,
       SUM(i.sales) AS total_sales,
       SUM(i.profit) AS total_profit
FROM products p
JOIN order_items i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- Проверка
SELECT * 
FROM product_profit_summary
ORDER BY total_profit DESC
LIMIT 10;


-- Procedures
-- Procedure 1. Top customers
DELIMITER //
CREATE PROCEDURE get_top_customers(IN n INT)
BEGIN
    SELECT c.customer_name, SUM(i.sales) AS total_sales
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items i ON o.order_id = i.order_id
    GROUP BY c.customer_name
    ORDER BY total_sales DESC
    LIMIT n;
END //
DELIMITER ;

-- Запуск
CALL get_top_customers(5);






