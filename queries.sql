-- =============================================================================
-- PROJECT 3 — PERFORMANCE QUERIES (BEFORE OPTIMIZATION)
-- Database : ecommerce
-- Tables   : orders, order_item, product, seller, brand, category, customer
-- Purpose  : Run each query TWICE:
--            1. Normal query  → see the result
--            2. EXPLAIN block → measure execution time & read the query plan
-- =============================================================================


SELECT 'brand' AS table_name, COUNT(*) AS total_rows FROM brand
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'seller', COUNT(*) FROM seller
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'promotion', COUNT(*) FROM promotion
UNION ALL
SELECT 'promotion_product', COUNT(*) FROM promotion_product
UNION ALL 
SELECT 'order', COUNT(*) from orders
UNION ALL 
SELECT 'order_item', COUNT(*) from order_item;

SELECT version();   
-- =============================================================================
-- QUERY 1: Total Revenue per Month
-- =============================================================================

SELECT
    TO_CHAR(order_date, 'YYYY-MM')     AS month,
    COUNT(*)                           AS total_orders,
    SUM(total_amount)                  AS total_revenue
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-05-31'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- ▶ EXPLAIN (đo thời gian thực tế):
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    TO_CHAR(order_date, 'YYYY-MM')     AS month,
    COUNT(*)                           AS total_orders,
    SUM(total_amount)                  AS total_revenue
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-05-31'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- =============================================================================
-- QUERY 2: Orders filtered by Seller and Date
-- =============================================================================

SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    s.seller_name,
    s.seller_type
FROM orders          o
JOIN order_item      oi ON o.order_id    = oi.order_id
JOIN product         p  ON oi.product_id = p.product_id
JOIN seller          s  ON p.seller_id   = s.seller_id
WHERE s.seller_id    = 1
  AND o.order_date BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY o.order_id, o.order_date, o.status, o.total_amount,
         s.seller_name, s.seller_type
ORDER BY o.order_date;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    s.seller_name,
    s.seller_type
FROM orders          o
JOIN order_item      oi ON o.order_id    = oi.order_id
JOIN product         p  ON oi.product_id = p.product_id
JOIN seller          s  ON p.seller_id   = s.seller_id
WHERE s.seller_id    = 1
  AND o.order_date BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY o.order_id, o.order_date, o.status, o.total_amount,
         s.seller_name, s.seller_type
ORDER BY o.order_date;


-- =============================================================================
-- QUERY 3: Filter order_item by product_id
-- =============================================================================

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.order_date,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    p.product_name,
    p.sku
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
WHERE oi.product_id = 100
ORDER BY oi.order_date DESC;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.order_date,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    p.product_name,
    p.sku
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
WHERE oi.product_id = 100
ORDER BY oi.order_date DESC;


-- =============================================================================
-- QUERY 4: Find Order with Highest total_amount
-- =============================================================================

SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.customer_name,
    c.city
FROM orders    o
JOIN customer  c ON o.customer_id = c.customer_id
ORDER BY o.total_amount DESC
LIMIT 10;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.customer_name,
    c.city
FROM orders    o
JOIN customer  c ON o.customer_id = c.customer_id
ORDER BY o.total_amount DESC
LIMIT 10;


-- =============================================================================
-- QUERY 5: Products with Highest Quantity Sold
-- =============================================================================

SELECT
    p.product_id,
    p.product_name,
    p.sku,
    s.seller_name,
    SUM(oi.quantity)   AS total_quantity_sold,
    SUM(oi.subtotal)   AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
GROUP BY p.product_id, p.product_name, p.sku, s.seller_name
ORDER BY total_quantity_sold DESC
LIMIT 20;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    s.seller_name,
    SUM(oi.quantity)   AS total_quantity_sold,
    SUM(oi.subtotal)   AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
GROUP BY p.product_id, p.product_name, p.sku, s.seller_name
ORDER BY total_quantity_sold DESC
LIMIT 20;


-- =============================================================================
-- QUERY 6: Orders by Seller in March 2025
-- =============================================================================

SELECT
    s.seller_id,
    s.seller_name,
    s.seller_type,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    SUM(oi.quantity)            AS total_quantity,
    SUM(oi.subtotal)            AS total_revenue
FROM orders      o
JOIN order_item  oi ON o.order_id    = oi.order_id
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
WHERE o.order_date BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY s.seller_id, s.seller_name, s.seller_type
ORDER BY total_revenue DESC;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    s.seller_id,
    s.seller_name,
    s.seller_type,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    SUM(oi.quantity)            AS total_quantity,
    SUM(oi.subtotal)            AS total_revenue
FROM orders      o
JOIN order_item  oi ON o.order_id    = oi.order_id
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
WHERE o.order_date BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY s.seller_id, s.seller_name, s.seller_type
ORDER BY total_revenue DESC;


-- =============================================================================
-- QUERY 7: Revenue per Product per Month
-- =============================================================================

SELECT
    TO_CHAR(oi.order_date, 'YYYY-MM')  AS month,
    p.product_id,
    p.product_name,
    SUM(oi.quantity)                   AS total_quantity,
    SUM(oi.subtotal)                   AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
WHERE oi.order_date BETWEEN '2025-01-01' AND '2025-05-31'
GROUP BY TO_CHAR(oi.order_date, 'YYYY-MM'), p.product_id, p.product_name
ORDER BY month, total_revenue DESC;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    TO_CHAR(oi.order_date, 'YYYY-MM')  AS month,
    p.product_id,
    p.product_name,
    SUM(oi.quantity)                   AS total_quantity,
    SUM(oi.subtotal)                   AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
WHERE oi.order_date BETWEEN '2025-01-01' AND '2025-05-31'
GROUP BY TO_CHAR(oi.order_date, 'YYYY-MM'), p.product_id, p.product_name
ORDER BY month, total_revenue DESC;


-- =============================================================================
-- QUERY 8: Products Sold per Seller
-- =============================================================================

SELECT
    s.seller_id,
    s.seller_name,
    s.seller_type,
    COUNT(DISTINCT p.product_id)  AS total_products,
    SUM(oi.quantity)              AS total_quantity_sold,
    SUM(oi.subtotal)              AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
GROUP BY s.seller_id, s.seller_name, s.seller_type
ORDER BY total_revenue DESC;

-- ▶ EXPLAIN:
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    s.seller_id,
    s.seller_name,
    s.seller_type,
    COUNT(DISTINCT p.product_id)  AS total_products,
    SUM(oi.quantity)              AS total_quantity_sold,
    SUM(oi.subtotal)              AS total_revenue
FROM order_item  oi
JOIN product     p  ON oi.product_id = p.product_id
JOIN seller      s  ON p.seller_id   = s.seller_id
GROUP BY s.seller_id, s.seller_name, s.seller_type
ORDER BY total_revenue DESC;


-- =============================================================================
-- Di chuyển dữ liệu 
-- =============================================================================

ALTER TABLE order_item RENAME TO order_item_old;
ALTER TABLE orders RENAME TO orders_old;


CREATE TABLE orders (
    order_id SERIAL,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_orders PRIMARY KEY (order_id, order_date), -- Khóa chính kết hợp
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
) PARTITION BY RANGE (order_date);



-- Tạo 5 partitions từ T1 đến T5/2025 của order
CREATE TABLE orders_2025_01 PARTITION OF orders FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE orders_2025_02 PARTITION OF orders FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE orders_2025_03 PARTITION OF orders FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE orders_2025_04 PARTITION OF orders FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE orders_2025_05 PARTITION OF orders FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE order_item (
    order_item_id BIGSERIAL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_order_item PRIMARY KEY (order_item_id, order_date), -- Khóa chính kết hợp
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES product (product_id),
    CONSTRAINT fk_order FOREIGN KEY (order_id, order_date) REFERENCES orders (order_id, order_date) ON DELETE CASCADE
) PARTITION BY RANGE (order_date);

-- Tạo 5 partitions từ T1 đến T5/2025 của order_item
CREATE TABLE order_item_2025_01 PARTITION OF order_item FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE order_item_2025_02 PARTITION OF order_item FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE order_item_2025_03 PARTITION OF order_item FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE order_item_2025_04 PARTITION OF order_item FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE order_item_2025_05 PARTITION OF order_item FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');


INSERT INTO orders SELECT * FROM orders_old;
INSERT INTO order_item SELECT * FROM order_item_old;

-- =============================================================================
-- Cập nhật sequence tự tăng
-- =============================================================================
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));
SELECT setval('order_item_order_item_id_seq', (SELECT MAX(order_item_id) FROM order_item));

-- =============================================================================
-- Chỉ cần tạo trên bảng cha, Postgres tự động nhân bản index sang cả 5 partitions con!
-- =============================================================================
CREATE INDEX idx_order_item_product_id ON order_item (product_id);


SELECT 
    child.relname AS partition_name,
    pg_get_expr(child.relpartbound, child.oid) AS partition_range
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
WHERE parent.relname = 'orders'
ORDER BY partition_name;

SELECT child.relname, pg_get_expr(child.relpartbound, child.oid)
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
WHERE parent.relname = 'order_item'
ORDER BY child.relname;

SELECT 'orders_2025_01' AS p, COUNT(*) FROM orders_2025_01
UNION ALL SELECT 'orders_2025_02', COUNT(*) FROM orders_2025_02
UNION ALL SELECT 'orders_2025_03', COUNT(*) FROM orders_2025_03
UNION ALL SELECT 'orders_2025_04', COUNT(*) FROM orders_2025_04
UNION ALL SELECT 'orders_2025_05', COUNT(*) FROM orders_2025_05;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders
WHERE order_date BETWEEN '2025-03-01' AND '2025-03-31';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders_old
WHERE order_date BETWEEN '2025-03-01' AND '2025-03-31';

SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename LIKE 'order_item%'
ORDER BY indexname;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM order_item
WHERE product_id = 100;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM order_item_old
WHERE product_id = 100;


-- =============================================================================
-- Making dynamic report (using function, procedure)
-- =============================================================================

-- Monthly Revenue Report 
-- Goal: Show total revenue and total orders per month.
-- Columns: `month`, `total_orders`, `total_quantity`, `total_revenue`
-- Filter: Orders within a specific date range (`start_date` to `end_date`) 
SELECT 
	DATE_TRUNC('month', o.order_date)::DATE AS report_month,
	count(distinct o.order_id) as total_order_id,
	coalesce(sum(oi.quantity),0) as total_quantity,
	coalesce(sum(o.total_amount),0) as total_revenue
FROM orders o
JOIN order_item oi on o.order_id = oi.order_id and o.order_date = oi.order_date
WHERE o.order_date >= '2025-01-01 00:00:00'
  AND o.order_date <= '2025-05-31 23:59:59'
GROUP BY DATE_TRUNC('month', o.order_date)::DATE AS report_month
ORDER BY report_month ASC;

CREATE OR REPLACE FUNCTION rpt_monthly_revenue
(
	p_start_date TIMESTAMP,
	p_end_date TIMESTAMP
)
RETURNS TABLE (
	report_month DATE,
	total_order_id BIGINT,
	total_quantity BIGINT,
	total_revenue NUMERIC(25,2)
)
LANGUAGE plpgsql AS $$ 
	BEGIN
		RETURN QUERY
	SELECT 
		DATE_TRUNC('month', o.order_date)::DATE AS report_month,
		count(distinct o.order_id)::BIGINT as total_order_id,
		coalesce(sum(oi.quantity),0)::BIGINT as total_quantity,
		coalesce(sum(o.total_amount),0)::NUMERIC(25,2) as total_revenue
	FROM orders o
	JOIN order_item oi on o.order_id = oi.order_id and o.order_date = oi.order_date
	WHERE o.order_date >= p_start_date
	  AND o.order_date <= p_end_date
	GROUP BY report_month
	ORDER BY report_month ASC;
	END;
$$

select * from rpt_monthly_revenue('2025-01-01 00:00:00','2025-01-31 23:59:59')

-- Daily Revenue Report
-- Goal: Show total revenue and total orders per day.
-- Columns: `date`, `total_orders`, `total_quantity`, `total_revenue`
-- Filter: Orders within a specific date range (`start_date` to `end_date`) and *product list*

SELECT 
	o.order_date:: DATE as report_date,
	count(distinct o.order_id) as total_order_id,
	coalesce(sum(oi.quantity),0) as total_quantity,
	coalesce(sum(oi.subtotal),0) as total_revenue
FROM orders o
JOIN order_item oi on o.order_id = oi.order_id and o.order_date = oi.order_date

WHERE o.order_date >= '2025-01-01 00:00:00'
  AND o.order_date <= '2025-05-01 23:59:59'
  AND oi.product_id IN (1, 10, 50, 100) 
GROUP BY report_date
ORDER BY report_date ASC;

CREATE OR REPLACE FUNCTION rpt_daily_revenue
(
	p_start_date TIMESTAMP,
	p_end_date TIMESTAMP,
	p_product_list INT[] DEFAULT NULL
)
RETURNS TABLE (
	report_date DATE,
	total_order_id BIGINT,
	total_quantity BIGINT,
	total_revenue NUMERIC(25,2)
)
LANGUAGE plpgsql AS $$ 
	BEGIN
	RETURN QUERY
		SELECT 
			o.order_date:: DATE as report_date,
			count(distinct o.order_id):: BIGINT as total_order_id,
			coalesce(sum(oi.quantity),0):: BIGINT as total_quantity,
			coalesce(sum(oi.subtotal),0):: NUMERIC(25,2) as total_revenue
		FROM orders o
		JOIN order_item oi on o.order_id = oi.order_id and o.order_date = oi.order_date
		
		WHERE o.order_date >= p_start_date
		  AND o.order_date <= p_end_date
		  AND (p_product_list IS NULL OR oi.product_id = ANY(p_product_list))
		GROUP BY report_date
		ORDER BY report_date ASC;
	END;
$$

select * from rpt_daily_revenue('2025-03-01', '2025-03-10', ARRAY[1, 2]);

-- Seller Performance Report
-- Goal: Compare sellers by total revenue and quantity sold.
-- Columns: `seller_id`, `seller_name`, `total_orders`, `total_quantity`, `total_revenue`
-- Filter: Orders within a specific date range. Optional filter by `category_id` or `brand_id`.


SELECT 
	s.seller_id,
	s.seller_name,
	p.category_id,
	p.brand_id,
	count(distinct o.order_id) 		 as total_orders,
	coalesce(sum(oi.quantity))		 as total_quantity,
	coalesce(sum(o.total_amount))	 as total_revenue
FROM seller s
JOIN product p     ON s.seller_id = p.seller_id
JOIN order_item oi ON p.product_id = oi.product_id
JOIN orders o      ON oi.order_id = o.order_id AND oi.order_date = o.order_date
WHERE o.order_date >= '2025-01-01 00:00:00'
  AND o.order_date <= '2025-03-31 23:59:59'
GROUP BY s.seller_id, s.seller_name,p.category_id,p.brand_id
ORDER BY total_revenue DESC


SELECT 
	s.seller_id,
	s.seller_name,
	p.category_id,
	p.brand_id,
	count(distinct o.order_id) 		 as total_orders,
	coalesce(sum(oi.quantity))		 as total_quantity,
	coalesce(sum(o.total_amount))	 as total_revenue
FROM seller s
JOIN product p     ON s.seller_id = p.seller_id
JOIN order_item oi ON p.product_id = oi.product_id
JOIN orders o      ON oi.order_id = o.order_id AND oi.order_date = o.order_date
WHERE o.order_date >= '2025-01-01 00:00:00'
  AND o.order_date <= '2025-03-31 23:59:59'
  AND p.category_id = 6
  AND p.brand_id = 1
GROUP BY s.seller_id, s.seller_name,p.category_id,p.brand_id
ORDER BY total_revenue DESC

CREATE OR REPLACE FUNCTION rpt_seller_performance
(
	p_start_date TIMESTAMP,
	p_end_date TIMESTAMP,
	p_category_id INT DEFAULT NULL,
	p_brand_id INT DEFAULT NULL
)
RETURNS TABLE (
	seller_id INT,
	seller_name VARCHAR(250),
	total_orders BIGINT,
	total_quantity BIGINT,
	total_revenue NUMERIC(25,2)
)
LANGUAGE plpgsql AS $$ 
	BEGIN
	RETURN QUERY
		SELECT 
			s.seller_id,
			s.seller_name,
			count(distinct o.order_id)::BIGINT 		 as total_orders,
			coalesce(sum(oi.quantity))::BIGINT		 as total_quantity,
			coalesce(sum(o.total_amount))::NUMERIC(25,2)	 as total_revenue		
		FROM seller s
		JOIN product p     ON s.seller_id = p.seller_id
		JOIN order_item oi ON p.product_id = oi.product_id
		JOIN orders o      ON oi.order_id = o.order_id AND oi.order_date = o.order_date
		WHERE o.order_date >= p_start_date
		  AND o.order_date <= p_end_date
		  AND (p_category_id IS NULL OR p.category_id = p_category_id) 
		  AND (p_brand_id IS NULL OR p.brand_id = p_brand_id) 
		GROUP BY s.seller_id, s.seller_name
		ORDER BY total_revenue DESC;
	END;
$$

SELECT * FROM rpt_seller_performance('2025-01-01', '2025-03-31');
SELECT * FROM rpt_seller_performance('2025-01-01', '2025-03-31', 6, 1);

-- Top Products per Brand
-- Goal: Identify top products for each brand by quantity sold.
-- Columns: `brand_id`, `brand_name`, `product_id`, `product_name`, `total_quantity`, `total_revenue`
-- Filter: Orders within a specific date range. Optional filter by *seller list.*
WITH ranked_products AS(
SELECT 
		b.brand_id,
		b.brand_name,
		p.product_id,
		p.product_name,
		COALESCE(SUM(oi.quantity),0) as total_quantity,
		COALESCE(SUM(oi.subtotal),0)	 as total_revenue,
		DENSE_RANK() OVER(
			PARTITION BY b.brand_id ORDER BY SUM(oi.quantity) DESC
		) as rank_in_brand
	FROM brand b
    JOIN product p     ON b.brand_id = p.brand_id
    JOIN order_item oi ON p.product_id = oi.product_id
    JOIN orders o      ON oi.order_id = o.order_id AND oi.order_date = o.order_date
	WHERE o.order_date >= '2025-01-01 00:00:00'
      AND o.order_date <= '2025-05-31 23:59:59'
	GROUP BY b.brand_id,
		b.brand_name,
		p.product_id,
		p.product_name
)

SELECT brand_id,
    brand_name,
    product_id,
    product_name,
    total_quantity,
    total_revenue,
    rank_in_brand
	FROM ranked_products WHERE rank_in_brand <=3
	ORDER BY brand_id, rank_in_brand;

CREATE OR REPLACE FUNCTION rpt_top_products_per_brand
(
	p_start_date TIMESTAMP,
	p_end_date TIMESTAMP,
	p_seller_id INT[] DEFAULT NULL,
	p_top_n INT DEFAULT 3
)
RETURNS TABLE (
	brand_id INT,
	brand_name VARCHAR(200),
	product_id INT,
	product_name VARCHAR(200),
	seller_id INT,
	seller_name VARCHAR(250),
	total_quantity BIGINT,
	total_revenue NUMERIC(25,2),
	rank_in_brand BIGINT
)
LANGUAGE plpgsql AS $$ 
	BEGIN
	RETURN QUERY
	WITH ranked_products AS(
		SELECT 
				b.brand_id,
				b.brand_name,
				p.product_id,
				p.product_name,
				COALESCE(SUM(oi.quantity),0)::BIGINT as total_quantity,
				COALESCE(SUM(oi.subtotal),0)::NUMERIC(25,2)	 as total_revenue,
				DENSE_RANK() OVER(
					PARTITION BY b.brand_id ORDER BY SUM(oi.quantity) DESC
				) as rank_in_brand
			FROM brand b
		    JOIN product p     ON b.brand_id = p.brand_id
		    JOIN order_item oi ON p.product_id = oi.product_id
		    JOIN orders o      ON oi.order_id = o.order_id AND oi.order_date = o.order_date
			WHERE o.order_date >= p_start_date
		      AND o.order_date <= p_end_date
			  AND (p_seller_id IS NULL or p.seller_id = any(p_seller_id))
			GROUP BY b.brand_id,
				b.brand_name,
				p.product_id,
				p.product_name
	)
	SELECT *
		FROM ranked_products WHERE rank_in_brand <= p_top_n
		ORDER BY brand_id, rank_in_brand;
	END;
$$

SELECT * FROM rpt_seller_performance('2025-01-01', '2025-03-31');
SELECT * FROM rpt_top_products_per_brand('2025-01-01', '2025-05-31', NULL, 3);

-- Orders Status Summary
-- Goal: Count orders per status (completed, pending, cancelled).
-- Columns: `status`, `total_orders`, `total_revenue`
-- Filter: Orders within a specific date range; optionally filter by seller list or category list.
SELECT 
    o.status,
    COUNT(DISTINCT o.order_id)    AS total_orders,
    COALESCE(SUM(oi.subtotal), 0) AS total_revenue
FROM order_item oi
JOIN orders o on o.order_id = oi.order_id
JOIN product p on p.product_id = oi.product_id  AND o.order_date = oi.order_date
WHERE o.order_date >= '2025-01-01 00:00:00'
  AND o.order_date <= '2025-05-31 23:59:59'
GROUP BY o.status
ORDER BY total_orders DESC;

CREATE OR REPLACE FUNCTION rpt_order_status_summary(
    p_start_date TIMESTAMP,
    p_end_date TIMESTAMP,
    p_seller_ids INT[] DEFAULT NULL,
    p_category_ids INT[] DEFAULT NULL
)
RETURNS TABLE (
    order_status VARCHAR(20),
    total_orders BIGINT,
    total_revenue NUMERIC(15,2)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.status,
        COUNT(DISTINCT o.order_id),
        COALESCE(SUM(oi.subtotal), 0)::NUMERIC(15,2)
    FROM orders o
    JOIN order_item oi ON o.order_id = oi.order_id AND o.order_date = oi.order_date
    JOIN product p     ON oi.product_id = p.product_id
    WHERE o.order_date >= p_start_date 
      AND o.order_date <= p_end_date
      AND (p_seller_ids IS NULL OR p.seller_id = ANY(p_seller_ids))
      AND (p_category_ids IS NULL OR p.category_id = ANY(p_category_ids))
    GROUP BY o.status
    ORDER BY total_orders DESC;
END;
$$;

SELECT * FROM rpt_order_status_summary(
    '2025-01-01', 
    '2025-01-31 23:59:59', 
    ARRAY[1, 2], -- Lọc Seller 1 và 2
    NULL         -- Lấy mọi danh mục
);

SELECT * FROM rpt_order_status_summary(
    '2025-03-01', 
    '2025-03-31 23:59:59', 
    NULL,        -- Lấy mọi seller
    ARRAY[1, 6]  -- Chỉ lọc ngành hàng Điện tử & Điện thoại
);

SELECT * FROM rpt_order_status_summary(
    '2025-01-01', 
    '2025-05-31 23:59:59', 
    ARRAY[1],    -- Seller ID = 1
    ARRAY[2]     -- Category ID = 2
);

-- DROP FUNCTION IF EXISTS rpt_seller_performance;
