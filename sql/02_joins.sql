-- ============================================================
-- E-Commerce Analytics Project — JOINs
-- ============================================================
-- Purpose: Practice INNER JOIN, LEFT JOIN, multi-table joins,
-- and JOIN + GROUP BY, using the 5 related tables:
-- customers, orders, orderitems, payments, products.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Basic INNER JOIN: orders + customers
-- ------------------------------------------------------------
-- Every order should have a valid customer, so INNER JOIN is
-- appropriate here (no need to preserve unmatched rows).
SELECT o.order_id, o.order_purchase_timestamp, c.customer_id
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;


-- ------------------------------------------------------------
-- 2. LEFT JOIN: find customers who never ordered
-- ------------------------------------------------------------
-- Keeps every row from customers (the "left" table), even
-- when there's no matching order. WHERE o.order_id IS NULL
-- filters down to only customers with zero orders.
SELECT c.customer_id, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ------------------------------------------------------------
-- 3. Multi-table JOIN (4 tables): order + customer + product + price
-- ------------------------------------------------------------
SELECT 
  o.order_id,
  c.customer_id,
  p.product_category_name,
  oi.price,
  oi.seller_id
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN orderitems oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
LIMIT 10;


-- ------------------------------------------------------------
-- 4. JOIN + GROUP BY: total revenue per product category
-- ------------------------------------------------------------
SELECT 
  p.product_category_name,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(*) AS items_sold
FROM orderitems oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 5. JOIN + GROUP BY: total spend per customer (incl. shipping)
-- ------------------------------------------------------------
SELECT 
  c.customer_id, 
  ROUND(SUM(oi.price + oi.shipping_charges), 2) AS total_spend
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN orderItems AS oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 6. Orders per customer
-- ------------------------------------------------------------
SELECT c.customer_id, COUNT(o.order_id) AS no_of_orders
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY no_of_orders DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 7. Top-selling categories by number of times ordered
-- ------------------------------------------------------------
SELECT 
  p.product_category_name,
  COUNT(*) AS times_ordered
FROM orderitems oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY times_ordered DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 8. Data-quality check: orders with no matching payment record
-- ------------------------------------------------------------
-- Checking p.order_id (the join key) rather than a value column
-- like payment_value, since only the key reliably indicates
-- "no matching row at all" vs. "row exists but a field is blank".
SELECT COUNT(*) AS orders_without_payment
FROM orders AS o
LEFT JOIN payments AS p ON o.order_id = p.order_id
WHERE p.order_id IS NULL;
-- Result: 0 — every order has at least one payment record.


-- ------------------------------------------------------------
-- 9. Average order value per customer (correct version)
-- ------------------------------------------------------------
-- Needs two aggregation levels: first sum each order's total
-- (order_id level), then average those totals per customer.
-- A single flat GROUP BY cannot do both at once — this is why
-- a subquery/CTE is required here.
SELECT c.customer_id, AVG(order_total) AS avg_order_value
FROM customers c
JOIN (
  SELECT o.customer_id, o.order_id, SUM(oi.price + oi.shipping_charges) AS order_total
  FROM orders o
  JOIN orderitems oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
) AS order_totals ON c.customer_id = order_totals.customer_id
GROUP BY c.customer_id
ORDER BY avg_order_value DESC
LIMIT 10;
