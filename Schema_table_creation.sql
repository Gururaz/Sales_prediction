-- create_schema.sql
-- Step 1: Create schema
CREATE SCHEMA IF NOT EXISTS sales;

-- Step 2: Drop old tables if they exist (for a clean setup)
DROP TABLE IF EXISTS sales.order_items;
DROP TABLE IF EXISTS sales.orders;
DROP TABLE IF EXISTS sales.products;
DROP TABLE IF EXISTS sales.customers;

-- Step 3: Create tables
CREATE TABLE sales.customers (
  customer_id   TEXT PRIMARY KEY,
  name          TEXT,
  email         TEXT,
  join_date     DATE
);

CREATE TABLE sales.products (
  product_id    TEXT PRIMARY KEY,
  product_name  TEXT,
  category      TEXT,
  price         NUMERIC(12,2)
);

CREATE TABLE sales.orders (
  order_id      TEXT PRIMARY KEY,
  customer_id   TEXT,
  order_date    TIMESTAMP,
  status        TEXT
);

CREATE TABLE sales.order_items (
  order_item_id   TEXT PRIMARY KEY,
  order_id        TEXT,
  product_id      TEXT,
  quantity        INT,
  price_per_item  NUMERIC(12,2)
);