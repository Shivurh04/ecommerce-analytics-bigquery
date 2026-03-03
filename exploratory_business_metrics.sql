------------- Exploratory Analysis (EDA) -----------------
-- Sample data
SELECT *
FROM `bigquery-public-data.thelook_ecommerce.orders`
LIMIT 10;

-- Order status distribution
SELECT
  status,
  COUNT(*) AS number_of_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status
ORDER BY number_of_orders DESC;

-- Gender distribution
SELECT
  gender,
  COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY gender;

-- Date range check
SELECT
  MIN(created_at) AS first_order_date,
  MAX(created_at) AS last_order_date
FROM `bigquery-public-data.thelook_ecommerce.orders`;




-----------------  Order Volume & Trends -----------------
-- Total orders
SELECT COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`;

-- Orders by year
SELECT
  EXTRACT(YEAR FROM created_at) AS year,
  COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY year
ORDER BY year;

-- Orders by month
SELECT
  FORMAT_DATE('%Y-%m', DATE(created_at)) AS year_month,
  COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY year_month
ORDER BY year_month;



-----------------  Revenue & AOV -----------------
-- Total revenue
SELECT
  ROUND(SUM(sale_price), 2) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

-- Average Order Value (AOV)
SELECT
  ROUND(SUM(sale_price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items`;
