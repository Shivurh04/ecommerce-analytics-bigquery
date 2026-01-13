----------- New vs Repeat Customers -----------
WITH customer_orders AS (
  SELECT
    user_id,
    COUNT(order_id) AS order_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
)
SELECT
  CASE
    WHEN order_count = 1 THEN 'New'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers
FROM customer_orders
GROUP BY customer_type;


------------ Repeat Purchase Rate -----------
WITH user_orders AS (
  SELECT
    user_id,
    COUNT(order_id) AS order_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
)
SELECT
  ROUND(
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) AS repeat_purchase_rate
FROM user_orders;



----------------- Time Between First & Second Purchase -----------------
WITH ordered_purchases AS (
  SELECT
    user_id,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at
    ) AS order_seq
  FROM `bigquery-public-data.thelook_ecommerce.orders`
)
SELECT
  user_id,
  DATE_DIFF(
    MAX(CASE WHEN order_seq = 2 THEN DATE(created_at) END),
    MAX(CASE WHEN order_seq = 1 THEN DATE(created_at) END),
    DAY
  ) AS days_between_first_second
FROM ordered_purchases
GROUP BY user_id
HAVING days_between_first_second IS NOT NULL;


----------- Customer Lifetime Value (LTV) -----------
SELECT
  o.user_id,
  ROUND(SUM(oi.sale_price), 2) AS lifetime_value
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
GROUP BY o.user_id
ORDER BY lifetime_value DESC
LIMIT 10;

