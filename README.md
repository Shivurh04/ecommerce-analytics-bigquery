# E-commerce Analytics using Google BigQuery

## Business Objective

Analyze customer behavior, revenue performance, retention, and conversion funnels
for an e-commerce business using cloud-scale SQL.

## Dataset

Google BigQuery Public Dataset:
bigquery-public-data.thelook_ecommerce

## Key Questions Answered

- How healthy is the business?
- How much revenue does each order generate (AOV)?
- Are customers returning or churning?
- Which customer cohorts retain better?
- Where do users drop off in the purchase funnel?

## Analysis Performed

### Day 1: Business Metrics

- Total orders, revenue, AOV
- Order status analysis
- Time-based trends

### Day 2: Customer Behavior

- New vs repeat customers
- Order sequencing using window functions
- Time between purchases
- Customer lifetime value (CLV)

### Day 3: Retention & Funnel Analysis

- Cohort-based retention analysis
- Product → Cart → Purchase funnel
- Funnel conversion rates

## Key Insights

- Majority of customers are one-time buyers, indicating retention opportunity
- Significant drop-off observed between product views and cart actions
- Certain cohorts show stronger repeat behavior than others

## Tools Used

- Google BigQuery (SQL)
- Window Functions, CTEs
- Cohort & Funnel Analysis


## Sample Outputs
Screenshots of key query results are available in the `screenshots/` folder,
demonstrating business metrics, customer behavior, and funnel analysis outputs.