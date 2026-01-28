/*
Part 2: SQL-Based Data Analysis 
*/

-- Create clean schema and tables (simple types; Redshift-friendly)
CREATE SCHEMA IF NOT EXISTS sales;

DROP TABLE IF EXISTS sales.order_items;
DROP TABLE IF EXISTS sales.orders;
DROP TABLE IF EXISTS sales.products;
DROP TABLE IF EXISTS sales.customers;

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

-- Load CSVs from the container path /data (mounted from ./Sales_data)
COPY sales.customers    FROM '/data/customers.csv'    WITH (FORMAT csv, HEADER true);
COPY sales.products     FROM '/data/products.csv'     WITH (FORMAT csv, HEADER true);
COPY sales.orders       FROM '/data/orders.csv'       WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY sales.order_items  FROM '/data/order_items.csv'  WITH (FORMAT csv, HEADER true);

-- Quick sanity checks
SELECT 'customers' AS table, COUNT(*) FROM sales.customers


--  What are the top 10 best-selling products by total revenue?

-- Top 10 best-selling products by total revenue

SELECT 
    p.product_id,
    p.product_name,
    count(oi.quantity),
    SUM(oi.quantity * oi.price_per_item) AS total_revenue
FROM 
    order_items oi
JOIN
    products p
ON
    oi.product_id = p.product_id
GROUP BY
    p.product_id, p.product_name
ORDER BY
    total_revenue DESC
LIMIT 10;


-- 2. Who are the top 5 customers based on their total spending?  

SELECT
    c.customer_id, 
    c.name, 
    c.email, 
    Sum(oi.quantity*price_per_item) AS total_spending 
FROM 
    customers c 
JOIN 
    orders o ON c.customer_id  = o.customer_id  
JOIN 
    order_items oi ON o.order_id = oi.order_id 
WHERE
    o.status NOT IN ('cancelled')
GROUP BY 
    c.customer_id, c.name,c.email 
ORDER BY  
    total_spending DESC 
LIMIT 5; 


-- 3. What is the total revenue per month? 
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS Year,
    EXTRACT(MONTH FROM o.order_date) AS Month,  
    SUM(oi.quantity * price_per_item) AS total_revenue 
FROM 
    Orders o 
JOIN 
    order_items oi ON o.order_id = oi.order_id 
WHERE 
    o.status NOT IN ('cancelled') 
GROUP BY 
   EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
ORDER BY 
    YEAR, MONTH;

-- 4. Which product category has the highest average number of items per order?
 
WITH category_order_totals AS (
    SELECT
        p.category,
        oi.order_id,
        SUM(oi.quantity) AS total_items
    FROM 
        sales.order_items oi
    JOIN 
        sales.products p ON p.product_id = oi.product_id
    GROUP BY 
        p.category, oi.order_id
)
SELECT
    category,
    AVG(total_items) AS highest_average_items_per_order
FROM 
    category_order_totals
GROUP BY 
    category
ORDER BY 
    highest_average_items_per_order DESC
LIMIT 1;
