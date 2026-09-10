-- ============================================================
-- E-Commerce Analytics Project — SQL Setup & Data Cleaning
-- ============================================================
-- Purpose: Load the 5 source tables (exported from the pandas
-- portfolio project) into MySQL and clean up data type issues
-- encountered during import, before moving on to analysis
-- (JOINs, CTEs, window functions).
--
-- Source tables:
--   customers, orders, order_items, payments, products
-- ============================================================


-- ------------------------------------------------------------
-- 1. Database setup
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS ecommerce_project;
USE ecommerce_project;

-- All 5 tables (customers, orders, order_items, payments,
-- products) were loaded via MySQL Workbench's
-- "Table Data Import Wizard" directly from the project's CSV
-- exports (df_Customers.csv, df_Orders.csv, df_OrderItems.csv,
-- df_Payments.csv, df_Products.csv).
--
-- Note: master/merged Excel sheet was NOT used for import —
-- the 5 separate tables were kept normalized/relational on
-- purpose, so they could be joined back together in SQL
-- (that's the whole point of practicing JOINs).


-- ------------------------------------------------------------
-- 2. Data cleaning: orders.order_purchase_timestamp
-- ------------------------------------------------------------
-- This column imported as TEXT in a clean
-- 'YYYY-MM-DD HH:MM:SS' format, so it converted directly
-- with no issues.

ALTER TABLE orders
MODIFY COLUMN order_purchase_timestamp DATETIME;


-- ------------------------------------------------------------
-- 3. Data cleaning: orders.order_approved_at
-- ------------------------------------------------------------
-- Problem: this column contained fractional seconds down to
-- NANOSECOND precision (e.g. '2024-03-25 16:07:29.205198109').
-- MySQL's DATETIME type only supports up to MICROSECOND
-- precision (6 digits), so a direct type conversion failed
-- with "Incorrect datetime value".
--
-- Fix: truncate to the first 19 characters (YYYY-MM-DD HH:MM:SS)
-- before converting, since sub-second precision isn't needed
-- for approval-lag analysis.

-- Safe Update Mode in MySQL Workbench blocks UPDATEs without a
-- key-based WHERE clause by default — disabled for this session:
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE orders
ADD COLUMN order_approved_at_clean DATETIME;

UPDATE orders
SET order_approved_at_clean = STR_TO_DATE(LEFT(order_approved_at, 19), '%Y-%m-%d %H:%i:%s')
WHERE order_approved_at IS NOT NULL AND order_approved_at != '';

-- Sanity check before swapping columns:
-- out of 10,691 total rows, 10,477 converted successfully.
-- The remaining 214 are genuinely blank in the source data —
-- these represent orders that were never approved (e.g.
-- cancelled / failed payment), confirmed by inspecting the
-- raw rows. Left as NULL intentionally, not a data loss bug.

ALTER TABLE orders DROP COLUMN order_approved_at;
ALTER TABLE orders CHANGE COLUMN order_approved_at_clean order_approved_at DATETIME;


-- ------------------------------------------------------------
-- 4. Verification
-- ------------------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'products', COUNT(*) FROM products;

-- Confirm no unexpected nulls remain in the cleaned column:
SELECT
  COUNT(*) AS total_orders,
  COUNT(order_approved_at) AS approved_orders,
  COUNT(*) - COUNT(order_approved_at) AS never_approved
FROM orders;
