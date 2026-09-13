-- ============================================================
-- E-Commerce Analytics Project — CTEs (Common Table Expressions)
-- ============================================================
-- Purpose: Practice WITH ... AS (CTEs) for multi-step
-- aggregations, and build the foundation metrics needed for
-- RFM segmentation and retention analysis in SQL.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Average order value per customer (CTE version)
-- ------------------------------------------------------------
-- Same result as the earlier subquery version in 02_joins.sql,
-- rewritten as a CTE for readability. Needs two aggregation
-- levels: order-level totals first, then averaged per customer.
WITH order_totals AS (
  SELECT o.customer_id, o.order_id, SUM(oi.price + oi.shipping_charges) AS order_total
  FROM orders o
  JOIN orderitems oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
)
SELECT customer_id, AVG(order_total) AS avg_order_value
FROM order_totals
GROUP BY customer_id
ORDER BY avg_order_value DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 2. Repeat customers + overall repeat rate
-- ------------------------------------------------------------
-- Mirrors the repeat-customer-rate calculation done in the
-- Python/pandas version of this project (result there: 65.28%).
WITH customer_orders AS (
  SELECT c.customer_id, COUNT(o.order_id) AS order_count
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_id
)
SELECT 
  COUNT(*) AS total_customers,
  SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
  ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_rate_pct
FROM customer_orders;
-- Result: 4000 total customers, 2624 repeat, 65.60% repeat rate
-- (matches the 65.28% Python result closely — small difference
-- expected due to differing dataset snapshots).


-- ------------------------------------------------------------
-- 3. First and last order date per customer (+ days active)
-- ------------------------------------------------------------
-- For customers with only 1 order, first_order = last_order,
-- so days_active = 0 — a useful way to distinguish one-time
-- vs repeat customers, and a building block for RFM Recency.
WITH customer_dates AS (
  SELECT 
    customer_id,
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
  FROM orders
  GROUP BY customer_id
)
SELECT 
  customer_id,
  first_order,
  last_order,
  DATEDIFF(last_order, first_order) AS days_active
FROM customer_dates
ORDER BY days_active DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 4. RFM snapshot date
-- ------------------------------------------------------------
-- Snapshot date = latest order date + 1 day, same convention
-- used in the Python RFM analysis.
SELECT MAX(order_purchase_timestamp) AS latest_order
FROM orders;
-- Result: 2024-12-30 23:00:00 -> snapshot date = 2024-12-31 23:00:00
