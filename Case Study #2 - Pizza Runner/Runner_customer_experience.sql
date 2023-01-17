-- Runner and Customer Experience

 /* --------------------
   Case Study Questions
   --------------------*/
   
 -- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT EXTRACT(week from runners.registration_date) AS weeks, COUNT(*) AS runner
FROM pizza_runner.runners
GROUP BY weeks;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	runner_id,
    AVG(diff)
FROM
(SELECT runner_id,((date_part('hour',pickup_time::TIMESTAMP - order_time::TIMESTAMP)*60) + date_part('minute',pickup_time::TIMESTAMP - order_time::TIMESTAMP)) AS diff
FROM temp_customer_orders
INNER JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
WHERE pickup_time != ''
GROUP BY runner_id,pickup_time,order_time) X
GROUP BY runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT
	corr(orders,diff) as correlation
FROM
(SELECT temp_customer_orders.order_id,
 count(temp_customer_orders.order_id) as orders,
 ((date_part('hour',pickup_time::TIMESTAMP - order_time::TIMESTAMP)*60) + date_part('minute',pickup_time::TIMESTAMP - order_time::TIMESTAMP)) AS diff
FROM temp_customer_orders
INNER JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
WHERE pickup_time != ''
GROUP BY temp_customer_orders.order_id,pickup_time,order_time) X;

-- What was the average distance travelled for each customer?

SELECT customer_id, 
	   AVG(CAST(split_part(distance,'k',1) AS FLOAT))
FROM temp_customer_orders
INNER JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
WHERE pickup_time != ''
GROUP BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    max(CAST (delivery_time AS FLOAT)) - min(CAST (delivery_time AS FLOAT)) AS diff
FROM
(SELECT temp_customer_orders.order_id, split_part(duration,'m',1) AS delivery_time
FROM temp_customer_orders
INNER JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
WHERE pickup_time != ''
GROUP BY temp_customer_orders.order_id, duration) X;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	runner_id,
    order_id,
    AVG(CAST(distances AS FLOAT)/ CAST(delivery_time AS FLOAT)) AS avg_speed
FROM
(SELECT runner_id,
 temp_customer_orders.order_id, 
 split_part(duration,'m',1) AS delivery_time,
 split_part(distance,'k',1) AS distances
 FROM temp_customer_orders
 INNER JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
 WHERE pickup_time != ''
 GROUP BY runner_id,temp_customer_orders.order_id, duration, distance) X
GROUP BY runner_id,order_id
ORDER BY runner_id;


-- What is the successful delivery percentage for each runner?
SELECT 
	runner_id,
	(CAST(COUNT(order_id)  filter (where cancellation ='')AS FLOAT)/CAST(COUNT(order_id) AS FLOAT))*100 AS percentage
FROM temp_runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
	SUM(profit) AS total_revenue
FROM
(SELECT
	pizza_name,
    COUNT(temp_customer_orders.pizza_id) AS total_pizza,
    CASE
    WHEN pizza_name = 'Meatlovers' THEN COUNT(temp_customer_orders.pizza_id)*12
    
    ELSE COUNT(temp_customer_orders.pizza_id)*10
    END
    AS profit
FROM temp_customer_orders
INNER JOIN pizza_runner.pizza_names
ON temp_customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY pizza_name) W;