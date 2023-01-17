
-- Data Cleaning and Transformation


-- Create a temporary table for both customer_orders and runner_orders table to deal with the data issues

-- Data Cleaning issues
-- Customer_orders - removal of null and NAN values and replace it with ''
-- Runner_orders - removal of null and NAN values and replace it with ''
  
-- creating customer_orders temporary table 
 
 SELECT order_id,
 		customer_id,
		pizza_id,
		order_time,
 	CASE
    WHEN exclusions = 'null' THEN ''
	ELSE exclusions
    END AS exclusions,
	CASE
	WHEN extras ISNULL OR extras = 'null' THEN ''
    ELSE extras
    END AS extras 
 INTO TEMP TABLE temp_customer_orders
 FROM pizza_runner.customer_orders;
 
 
-- creating runner_orders temporary table  
 
 SELECT order_id,
 		runner_id,
 	CASE
    WHEN pickup_time = 'null' OR pickup_time ISNULL THEN ''
	ELSE pickup_time
    END AS pickup_time,
	CASE
    WHEN distance = 'null' OR distance ISNULL THEN ''
	ELSE distance
    END AS distance,
	CASE
	WHEN duration ISNULL OR duration = 'null' THEN ''
    ELSE duration
    END AS duration,
	CASE
	WHEN cancellation ISNULL OR cancellation = 'null' THEN ''
    ELSE cancellation
    END AS cancellation 
 INTO TEMP TABLE temp_runner_orders
 FROM pizza_runner.runner_orders;
 
 
 

 
 
  
  
  
  
  
  






	
	
	

  
  
  
  
  
  