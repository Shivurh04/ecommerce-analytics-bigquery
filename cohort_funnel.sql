---------- Cohort Analysis & Funnel Metrics --------------
---------- Cohort Analysis -----------------
WITH user_cohort AS (
  SELECT
    user_id,
    DATE(MIN(created_at)) AS cohort_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
),
orders_with_cohort AS (
  SELECT
    o.user_id,
    u.cohort_date,
    DATE_DIFF(DATE(o.created_at), u.cohort_date, MONTH) AS months_since_first_order
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN user_cohort u
    ON o.user_id = u.user_id
)
SELECT
  FORMAT_DATE('%Y-%m', cohort_date) AS cohort_month,
  months_since_first_order,
  COUNT(DISTINCT user_id) AS active_users
FROM orders_with_cohort
GROUP BY cohort_month, months_since_first_order
ORDER BY cohort_month, months_since_first_order;



---------- Funnel Analysis -----------------
-- Event distribution
SELECT
  event_type,
  COUNT(*) AS events
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY event_type;

-- Funnel Counts (View → Cart → Purchase)
WITH funnel AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)
SELECT
  COUNTIF(viewed_product = 1) AS product_view_users,
  COUNTIF(added_to_cart = 1) AS cart_users,
  COUNTIF(purchased = 1) AS purchased_users
FROM funnel;

-- Funnel Conversion Rates
WITH funnel AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)
SELECT
  COUNTIF(added_to_cart = 1)*100/COUNTIF(viewed_product = 1) AS product_to_cart_pct,
  COUNTIF(purchased = 1)*100/COUNTIF(added_to_cart = 1) AS cart_to_purchase_pct
FROM funnel;