DeliverEats: 20 Real-World SQL Business Problem Solutions

SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;

-- Handling NULL VALUES

SELECT COUNT(*) FROM customers
WHERE 
	customer_name IS NULL
	OR
	reg_date IS NULL



SELECT COUNT(*) FROM restaurants
WHERE 
	restaurant_name IS NULL
	OR
	city IS NULL
	OR
	opening_hours IS NULL

SELECT * FROM orders
WHERE 
	order_item IS NULL
	OR
	order_date IS NULL
	OR
	order_time IS NULL
	OR
	order_status IS NULL
	OR 
	total_amount IS NULL;


DELETE FROM orders
WHERE 
	order_item IS NULL
	OR
	order_date IS NULL
	OR
	order_time IS NULL
	OR
	order_status IS NULL
	OR 
	total_amount IS NULL

INSERT INTO orders(order_id, customer_id, restaurant_id)
VALUES
(10002,9, 54),
(10003, 10, 51),
(10005, 10, 50)
;

-- -------------------------
-- Analysis & Reports
-- -------------------------


-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.
-- 

-- join cx and orders
-- filter for last 1 year 
-- FILTER 'arjun mehta'
-- group by cx id, dishes, cnt




SELECT 
	customer_name,
	dishes,
	total_orders
FROM -- table name
	(SELECT 
		c.customer_id,
		c.customer_name,
		o.order_item as dishes,
		COUNT(*) as total_orders,
		DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rank
	FROM orders as o
	JOIN
	customers as c
	ON c.customer_id = o.customer_id
	WHERE 
		o.order_date >= CURRENT_DATE - INTERVAL '1 Year'
		AND 
		c.customer_name = 'Arjun Mehta'
	GROUP BY 1, 2, 3
	ORDER BY 1, 4 DESC) as t1
WHERE rank <= 5


-- 

-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

-- Approach 1
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;


-- Approach 2
SELECT 
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 as start_time,
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 as end_time,
	COUNT(*) as total_orders
FROM orders
GROUP BY 1, 2
ORDER BY 3 DESC

-- 23:55PM /2 -- 11 * 2 = 22 start, 22 +2 
22-11:59:59 PM

-- SELECT 00:59:59AM -- 0
-- SELECT 01:59:59AM -- 1
-- 0


-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)


SELECT 
	-- o.customer_id,
	c.customer_name,
	AVG(o.total_amount) as aov
FROM orders as o
	JOIN customers as c
	ON c.customer_id = o.customer_id
GROUP BY 1
HAVING  COUNT(order_id) > 750


-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!


SELECT 
	-- o.customer_id,
	c.customer_name,
	SUM(o.total_amount) as total_spent
FROM orders as o
	JOIN customers as c
	ON c.customer_id = o.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000



-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 

SELECT 
	r.restaurant_name,
	COUNT(o.order_id) as cnt_not_delivered_orders
FROM orders as o
LEFT JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
LEFT JOIN
deliveries as d
ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1
ORDER BY 2 DESC


SELECT 
	r.restaurant_name,
	COUNT(*)
FROM orders as o
LEFT JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
WHERE 
	o.order_id NOT IN (SELECT order_id FROM deliveries)
GROUP BY 1
ORDER BY 2 DESC




-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.

WITH ranking_table
AS
(
	SELECT 
		r.city,
		r.restaurant_name,
		SUM(o.total_amount) as revenue,
		RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as rank
	FROM orders as o
	JOIN 
	restaurants as r
	ON r.restaurant_id = o.restaurant_id
	WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
	GROUP BY 1, 2
)
SELECT 
	*
FROM ranking_table
WHERE rank = 1




-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.

SELECT * 
FROM
(SELECT 
	r.city,
	o.order_item as dish,
	COUNT(order_id) as total_orders,
	RANK() OVER(PARTITION BY r.city ORDER BY COUNT(order_id) DESC) as rank
FROM orders as o
JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
) as t1
WHERE rank = 1



-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.
