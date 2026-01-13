--Total Orders 
SELECT COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`;

SELECT status, COUNT(*) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status;

SELECT status, COUNT(*) number_of_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status
ORDER BY number_of_orders desc;

--GENDERS
SELECT gender, COUNT(*) as Total_count
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY gender;

--Number of orders in every year
SELECT 
  EXTRACT(YEAR FROM created_at) as year, 
  count(*) as total_orders  
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY year
ORDER BY year;

--Number of orders in every months
SELECT 
  EXTRACT(MONTH FROM created_at) as month, 
  COUNT(*) as total_orders  
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY month
ORDER BY month;

--Numbers of orders based on days
SELECT 
  EXTRACT(DAY FROM created_at) as day, 
  COUNT(*) as total_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY day
ORDER BY day;

--Number of cancellations in a year
SELECT 
  EXTRACT(YEAR FROM created_at) AS year, 
  status, 
  COUNT(*) AS count 
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY year, status
ORDER BY status desc, count desc;


SELECT 
  ROUND(SUM((sale_price)),1) as total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`;


SELECT 
  ROUND((SUM(sale_price)/COUNT(DISTINCT order_id)),2) AS average_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

--Revenue by Order Status 
SELECT 
  status, 
  ROUND(SUM(sale_price),2) AS rev_order_status
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status;

SELECT 
  status, 
  ROUND((SUM(sale_price)/COUNT(DISTINCT order_id)),2) as aov_by_order_status
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status;


WITH customer_orders AS
(
SELECT user_id, COUNT(*) order_count
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY user_id
)
SELECT 
CASE
  WHEN order_count = 1 THEN 'New'
  ELSE 'Repeated'
END as user_type,
COUNT(*) AS customers
FROM customer_orders
GROUP BY user_type;


SELECT FORMAT_DATE('%Y-%m', DATE(created_at)) as month, ROUND(SUM(sale_price),2) as revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY month
ORDER BY revenue DESC;

--Cancellation Rate
SELECT ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END)*100/COUNT(*),2) AS cancellation_rate
FROM `bigquery-public-data.thelook_ecommerce.orders`;

--AOV by Status
SELECT status, ROUND(SUM(sale_price)/COUNT(DISTINCT order_id),2) as AOV
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status;

--Identify First Purchase per Customer
SELECT user_id, MIN(created_at)
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY user_id;

--New vs Repeat Customers
WITH type_of_customers AS(
SELECT user_id, COUNT(*) order_count
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY user_id
)
SELECT
  CASE
    WHEN order_count = 1 THEN 'NEW'
    ELSE 'REPEAT'
  END as customer_type,COUNT(*) AS customers
FROM type_of_customers
group by customer_type
;

--Time Between First & Second Purchase (Retention Signal)
WITH ordered_purchases as (
  SELECT user_id, created_at, 
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_at) AS order_seq
  FROM `bigquery-public-data.thelook_ecommerce.orders`
)
SELECT user_id, 
  DATE_DIFF(
    MAX(CASE WHEN order_seq = 2 THEN DATE(created_at) END),
    MAX(CASE WHEN order_seq = 1 THEN DATE(created_at) END), 
            DAY) AS day_difference_first_second
FROM ordered_purchases
GROUP BY user_id
HAVING day_difference_first_second IS NOT NULL
;

--Repeat Purchase Rate
WITH repeated_users as (
SELECT 
  user_id, 
  COUNT(order_id) AS repeat_count
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY user_id
ORDER BY repeat_count desc
)
SELECT 
  ROUND(
    SUM(CASE WHEN repeat_count >1 THEN 1 ELSE 0 END) *100/COUNT(*), 
    2) AS repeat_purchase_rate
FROM repeated_users
;

--Top Customers by Lifetime Value (LTV)
SELECT
  o.user_id,
  ROUND(SUM(oi.sale_price), 2) AS lifetime_value
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
GROUP BY o.user_id
ORDER BY lifetime_value DESC
LIMIT 10;




--COHORT ANALYSIS (Retention)
WITH user_cohort AS (
  SELECT user_id, DATE(MIN(created_at)) as cohort_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
),
order_with_cohort AS(
SELECT o.user_id, u.cohort_date, DATE(o.created_at) AS order_date,
  DATE_DIFF(DATE(o.created_at), u.cohort_date, MONTH) AS months_since_first_order
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN user_cohort u
  ON u.user_id = o.user_id
)
SELECT *
FROM order_with_cohort
LIMIT 10
;


--Building the Retention Table
WITH user_cohort AS (
  SELECT user_id, DATE(MIN(created_at)) AS cohort_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
),
order_with_cohort AS (
  SELECT o.user_id, u.cohort_date, DATE(o.created_at) as order_date, 
    DATE_DIFF(DATE(o.created_at), u.cohort_date, MONTH) as months_since_first_order
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN user_cohort as u 
    ON u.user_id = o.user_id
)
SELECT 
  FORMAT_DATE('%Y-%m', cohort_date) AS cohort_month, 
  months_since_first_order, 
  COUNT(DISTINCT user_id) AS active_user
FROM order_with_cohort
GROUP BY cohort_month, months_since_first_order
ORDER BY cohort_month, months_since_first_order;


--FUNNEL ANALYSIS (Conversion)
SELECT event_type, COUNT(*) AS events
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY event_type;

--Funnel Counts (View → Cart → Purchase)
WITH funnel as (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) as viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) as add_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)
SELECT 
  COUNTIF(viewed_product = 1) AS product_viewed_users,
  COUNTIF(add_to_cart = 1) AS cart_usres,
  COUNTIF(purchased =1)AS purchased_users
FROM funnel;


-- Funnel Conversion Rates
WITH funnel as (
  SELECT 
    user_id,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS add_to_cart,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)
SELECT 
  COUNTIF(add_to_cart = 1)*100/ COUNTIF(viewed_product = 1) AS product_to_cart_pct,
  COUNTIF(purchased =1)*100/COUNTIF(add_to_cart = 1) AS cart_to_purchase_pct,
FROM funnel;



SELECT *
FROM `bigquery-public-data.thelook_ecommerce.order_items`
;
select count(*) 
from `bigquery-public-data.thelook_ecommerce.orders`;









