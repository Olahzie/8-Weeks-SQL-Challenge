/* --------------------
   Case Study 1
   --------------------*/
--Author: Olayode Ogunniran
--Date: 05/12/2022
--Tool used: PostgreSQL

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id, 
    SUM(price) AS total_amount
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS days_number
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT
	customer_id,
	product_name
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
WHERE order_date in (SELECT first_date FROM (SELECT customer_id, MIN(order_date) AS first_date 
					FROM dannys_diner.sales
                    GROUP BY customer_id) Z GROUP BY first_date)
GROUP BY customer_id,product_name, order_date
ORDER BY customer_id;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  
 SELECT
    product_name,
    COUNT(sales.product_id) AS purchased_times
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales 
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY purchased_times DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

SELECT
 	customer_id,
    product_name,
    occurence
FROM 
   (SELECT
	  customer_id,
    product_name,
    COUNT(sales.product_id) AS occurence,
	RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(sales.product_id) DESC) ad
  	FROM dannys_diner.menu
  	INNER JOIN dannys_diner.sales 
  	ON sales.product_id = menu.product_id
  	GROUP BY customer_id,product_name) x
WHERE ad = 1	
GROUP BY customer_id,product_name, occurence,ad;
  

   
            
-- 6. Which item was purchased first by the customer after they became a member?
SELECT
customer_id,
product_name
FROM
(SELECT
	sales.customer_id AS customer_id,
	product_name,
    order_date,
    RANK()
    over(partition by sales.customer_id order by order_date ASC) as first_purchase
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members 
ON sales.customer_id = members.customer_id
where order_date > (SELECT MIN(join_date) FROM dannys_diner.members)
group by sales.customer_id,order_date, product_name) R
WHERE first_purchase = 1;

-- 7. Which item was purchased just before the customer became a member?
SELECT
	customer_id,
	product_name
FROM
(SELECT
	sales.customer_id AS customer_id,
    product_name,
    RANK()
    over(partition by sales.customer_id order by order_date desc) as last_purchase
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members 
ON sales.customer_id = members.customer_id
where order_date < (SELECT MIN(join_date) FROM dannys_diner.members)
group by sales.customer_id,order_date, product_name) V
WHERE last_purchase = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
 	sales.customer_id,
    count(sales.product_id) AS total_items,
    sum(price) AS amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
WHERE order_date < (SELECT MIN(join_date) FROM dannys_diner.members)
GROUP BY sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	custom_id,
    sum(total_price) AS total_price,
    sum(new_price) AS total_points
FROM

  (SELECT
      sales.customer_id AS custom_id,
      product_name,
      sum(price) AS total_price,
      CASE 
          WHEN product_name = 'sushi' THEN sum(price)*20
          ELSE	sum(price)*10
     END
     AS  new_price
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
  group by sales.customer_id,product_name) Y
GROUP BY Y.custom_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
	custom_id,
    sum(total_price) AS total_price,
    sum(new_price) AS total_points
FROM

  (SELECT
      sales.customer_id AS custom_id,
      order_date,
      sum(price) AS total_price,
      CASE 
          WHEN sum(price) >0
                  AND order_date >= (select min(join_date) from dannys_diner.members) THEN sum(price)*20
          ELSE	sum(price)*10
     END
     AS  new_price
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
  INNER JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
  where order_date <='2021-01-31'
  group by sales.customer_id,order_date) Y
GROUP BY Y.custom_id;

-- BONUS
-- Join all the table
-- Dannys want a table that contains the following columns customer_id, order_date, product_name and a member 
-- column that show whether the customer is member yet with Y or not a member with N

SELECT sales.customer_id,
		order_date,
		product_name,
		price,
		CASE 
          WHEN customer_id in (select customer_id from dannys_diner.members) 
		  AND order_date >= (SELECT MIN(join_date) from dannys_diner.members) THEN 'Y'
          ELSE	'N'
     END
     AS  members
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id
ORDER BY customer_id,members, price desc;

-- TABLE 2
-- Dannys want a table that contains the following columns customer_id, order_date, product_name, a member 
-- column that show whether the customer is member yet with Y or not a member with N and also a ranking colunms 
-- that shows the ranking of customers that are members and null for non_member customer.
SELECT *,
	CASE
	WHEN members = 'Y' THEN RANK() over(partition by customer_id,members order by order_date ASC,customer_id)
	ELSE  NULL
   END
   AS rankings
FROM	
(SELECT sales.customer_id AS customer_id,
		order_date,
		product_name,
		price,
		CASE 
          WHEN customer_id in (select customer_id from dannys_diner.members) 
		  AND order_date >= (SELECT MIN(join_date) from dannys_diner.members) THEN 'Y'
          ELSE	'N'
     END
     AS  members
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu 
ON sales.product_id = menu.product_id) X
ORDER BY customer_id,members, price desc,rankings;
