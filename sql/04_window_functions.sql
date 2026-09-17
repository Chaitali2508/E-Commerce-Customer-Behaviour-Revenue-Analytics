-- ============================================================
-- E-Commerce Analytics Project — Window Functions
-- ============================================================
-- Purpose: Practice OVER(), PARTITION BY, ranking functions,
-- and build the remaining pieces of RFM segmentation and
-- retention analysis (the final SQL topic for this project).
-- ============================================================


-- ------------------------------------------------------------
-- 1. Window function basics: ROW_NUMBER() + PARTITION BY
-- ------------------------------------------------------------
-- Unlike GROUP BY, window functions do NOT collapse rows —
-- every original row is kept, with a calculated value (here,
-- an order sequence number) added alongside it.
-- PARTITION BY customer_id resets the numbering independently
-- for each customer (like a mini GROUP BY, but without
-- collapsing rows). ORDER BY inside OVER() decides the
-- numbering sequence (oldest order = 1).
SELECT 
  customer_id,
  order_id,
  order_purchase_timestamp,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS order_number
FROM orders
ORDER BY customer_id, order_number
LIMIT 20;
-- Confirmed: e.g. CUST100004 has 6 orders, numbered 1-6 in
-- chronological order, independent of every other customer.


-- ------------------------------------------------------------
-- 2. RANK() vs DENSE_RANK(): ranking customers by revenue
-- ------------------------------------------------------------
-- No PARTITION BY here — a single ranking across ALL customers,
-- not reset per group. RANK() skips numbers after a tie
-- (1,2,2,4); DENSE_RANK() does not (1,2,2,3). No ties appeared
-- in the top 15 by revenue (continuous decimal values rarely
-- tie exactly) — both columns matched in this dataset.
WITH customer_totals AS (
  SELECT c.customer_id, SUM(oi.price + oi.shipping_charges) AS total_revenue
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN orderitems oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id
)
SELECT 
  customer_id,
  total_revenue,
  RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
  DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_dense_rank
FROM customer_totals
ORDER BY total_revenue DESC
LIMIT 15;

-- ------------------------------------------------------------
-- 3. NTILE(5): scoring Recency, Frequency, Monetary (RFM)
-- ------------------------------------------------------------
-- NTILE(5) splits customers into 5 roughly equal-sized buckets
-- based on the ORDER BY inside OVER(). Frequency and Monetary
-- sort ASC (lowest values first) so top spenders/most-frequent
-- customers land in bucket 5. Recency is DELIBERATELY sorted
-- DESC (biggest day-gap first) because a SMALLER day-gap
-- (recently active) should score HIGHER (5) -- the opposite
-- direction from the other two metrics.
WITH calculation AS (
  SELECT 
    c.customer_id AS customer,
    COUNT(o.order_id) AS order_count,
    SUM(oi.shipping_charges + oi.price) AS monetary,
    MAX(o.order_purchase_timestamp) AS lastdate
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN orderitems oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id
),
rfm_scores AS (
  SELECT 
    customer,
    DATEDIFF('2024-12-31 23:00:00', lastdate) AS recency,
    order_count AS frequency,
    monetary,
    NTILE(5) OVER (ORDER BY DATEDIFF('2024-12-31 23:00:00', lastdate) DESC) AS recency_score,
    NTILE(5) OVER (ORDER BY order_count ASC) AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
  FROM calculation
)
SELECT * FROM rfm_scores
ORDER BY monetary DESC
LIMIT 15;
-- Verified: e.g. CUST102938 (240-day gap, least recent here)
-- correctly scored recency_score=3, lower than customers like
-- CUST101119 and CUST103229 (only 3-day gap) who scored 5 --
-- confirming the flipped sort direction works as intended.
 
-- Next step: combine recency_score + frequency_score +
-- monetary_score into an actual segment label (e.g. Champion,
-- Loyal, At Risk) -- matching the Python RFM segmentation.
 
