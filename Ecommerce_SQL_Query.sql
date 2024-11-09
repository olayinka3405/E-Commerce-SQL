 --Create DataBase ECommerce  

USE [ECommerce]

--A. Basic Select Queries

--	1. Retrieve all customers from a specific state
SELECT 
	[customer_id], [customer_unique_id], 
	[customer_zip_code_prefix],[customer_zip_code_prefix], 
	UPPER([customer_city]), [customer_state]
FROM 
	[dbo].[customers]
WHERE 
	1 = 1
AND 
	[customer_state] IN ('SP', 'PR', 'RJ')
AND 
	[customer_city] IS NOT NULL  
AND 
	[customer_state] IS NOT NULL --***IS NOT NULL was used to handled null values

--	2. List all products with their category and dimensions
SELECT 
	[product_category], [product_weight_g], 
	[product_length_cm], [product_height_cm], 
	[product_width_cm] 
FROM 
	[dbo].[products]
WHERE 
	1 = 1
AND 
	[product_category] IS NOT NULL;

--B. Joins

--	1. Find all orders with customer details
SELECT 
	Cus.[customer_id],Cus.[customer_city],
	Cus.[customer_state], Ord.order_id, 
	Ord.[order_status], Ord.[order_purchase_timestamp]
FROM
	[dbo].[orders] Ord
LEFT JOIN 
	[dbo].[customers] Cus ON Ord.customer_id = Cus.customer_id;

--	2. Retrieve order details along with item and product information
SELECT 
	O.[order_id], P.[product_id], 
	P.[product_category], Oi.[order_item_id], 
	Oi.[freight_value], Oi.[price], 
	O.[order_status]
FROM 
	[dbo].[orders] O 
LEFT JOIN 
	[dbo].[order_items] Oi ON O.[order_id] = Oi.[order_id]
LEFT JOIN 
	[dbo].[products] P ON Oi.[product_id] = P.[product_id];

--C. Aggregations

--	1. Calculate the total amount spent by each customer
SELECT 
	O.customer_id, SUM([payment_value]) AS total_spent
FROM 
	[dbo].[orders] O
JOIN 
	[dbo].[payments] P ON O.order_id = P.order_id
GROUP BY 
	O.customer_id
 
--	2. Find the total number of products sold and their total value
SELECT
	p.product_id, COUNT(o.order_id) AS total_sold, 
	SUM(oi.price) AS total_value
FROM 
	[dbo].[orders] o 
LEFT JOIN 
	[dbo].[order_items] oi ON o.order_id = oi.order_id
RIGHT JOIN 
	[dbo].[products] p ON oi.product_id = p.product_id
WHERE 
	1 = 1
--	AND p.[product_id] LIKE '%ada88'
GROUP BY 
	p.product_id;

--  3. Top 10 product categories based on the sum of product dimensions
SELECT TOP 10 
	[product_category], (
	SUM(CAST([product_weight_g] AS BIGINT) * 
	CAST([product_length_cm] AS BIGINT) * 
	CAST([product_height_cm] AS BIGINT))
) AS product_dimensions --***BIGINT was used to handled large numbers
FROM 
	[dbo].[products]
WHERE 
	1 = 1
AND 
	[product_category] IS NOT NULL
GROUP BY 
	[product_category]
ORDER BY 
	product_dimensions DESC;

--D. Subqueries

--	1. List customers who have placed more than 5 orders
SELECT 
	customer_id
FROM (
	SELECT 
		c.customer_id, c.customer_unique_id, 
		c.customer_city, 
		COUNT(DISTINCT o.order_id) AS Order_Count
	FROM 
		[dbo].[customers] c
	JOIN 
		[dbo].[orders] O ON c.customer_id = o.customer_id
	GROUP BY 
		c.customer_id, 
		c.customer_unique_id, 
		c.customer_city
) AS Orders
WHERE 
	1 = 1 
AND 
	Order_Count > 5;

--or

SELECT 
	c.customer_id
FROM 
	Customers c
WHERE 
	(SELECT 
		COUNT(*) 
	FROM 
		Orders o 
	WHERE 
		1 = 1
	AND	o.customer_id = c.customer_id) > 5;

--	2. Find the most recent order for each customer

SELECT 
	customer_id, 
	MAX([order_purchase_timestamp]) AS Order_Date
FROM (
	SELECT 
		c.customer_id, o.order_id, o.order_purchase_timestamp
	FROM 
		customers c
	JOIN 
		orders o ON c.customer_id = o.customer_id
) AS order_Date
GROUP BY 
	customer_id

--E. Advanced Queries

--	1. Determine the delivery time in days for each orders

SELECT 
	order_id, order_purchase_timestamp, 
	order_delivered_customer_date, 
	DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) AS Delivery_Days
FROM
	[dbo].[orders]
WHERE 
	1 = 1
AND 
	order_delivered_customer_date IS NOT NULL
ORDER BY 
	Delivery_Days DESC

-- 2. Determine the average delivery time for orders

SELECT  
	AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS Average_Delivery_Time
FROM
	[dbo].[orders]
WHERE 
	1 = 1
AND 
	order_delivered_customer_date IS NOT NULL

-- 3. Determine the average delivery time for orders by Months

SELECT 
	MONTH(order_purchase_timestamp) AS Month,
	AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS Average_Delivery_Time
FROM
	[dbo].[orders]
WHERE 
	1 = 1
AND 
	order_delivered_customer_date IS NOT NULL
GROUP BY 
	MONTH(order_purchase_timestamp)
ORDER BY
	Month

-- 4. Determine the average delivery time for orders by Years

SELECT 
	YEAR(order_purchase_timestamp) AS Years,
	AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS Average_Delivery_Time
FROM
	[dbo].[orders]
WHERE 1 = 1
AND 
	order_delivered_customer_date IS NOT NULL
GROUP BY 
	YEAR(order_purchase_timestamp)


