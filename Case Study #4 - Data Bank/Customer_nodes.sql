-- A. Customer Nodes Exploration

-- How many unique nodes are there on the Data Bank system?

SELECT 
	COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;

-- What is the number of nodes per region?

SELECT
	region_name,
	COUNT(node_id)
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
ON customer_nodes.region_id = regions.region_id
GROUP BY region_name;

-- How many customers are allocated to each region?

SELECT 
	region_name,
	COUNT(DISTINCT customer_id)
FROM data_bank.customer_nodes
INNER JOIN data_bank.regions
ON customer_nodes.region_id = regions.region_id
GROUP BY region_name;


-- in other to answer the next question some inconsistency are detected and are needed to be cleaned
-- some irregularities are discovered in the end_date column of customer node has some of the year are 9999 instead of 2020
-- Creating a temporary table to deal with the irregularities in the end_date column

SELECT
	customer_id,
	region_id,
	node_id,
	start_date,
	CASE
	WHEN EXTRACT('Year' from end_date) = 9999 THEN DATE(end_date + (2020-EXTRACT('YEAR' FROM end_date)||'years')::interval)
	ELSE end_date
	END AS end_date
INTO TEMP TABLE temp_data_bank
FROM data_bank.customer_nodes;


-- How many days on average are customers reallocated to a different node?
SELECT
	ROUND(AVG(total_days),0) AS avg_days
FROM
(SELECT 
	customer_id,
 	node_id,
	SUM(dayys) AS total_days
FROM
(SELECT
	customer_id,
 	node_id,
 	start_date,
 	end_date,
	end_date - start_date AS dayys
FROM temp_data_bank
WHERE end_date != '2020-12-31'
ORDER BY customer_id, start_date, end_date, node_id)V
GROUP BY customer_id,node_id
ORDER BY customer_id,node_id)W;	

-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
	ROUN
FROM
(SELECT
 	region_name,
 	customer_id,
 	node_id,
	SUM(dayys) AS total_days
FROM
(SELECT
 	region_name,
	customer_id,
 	node_id,
 	start_date,
 	end_date,
	end_date - start_date AS dayys
FROM temp_data_bank
INNER JOIN data_bank.regions
ON temp_data_bank.region_id = regions.region_id
WHERE end_date != '2020-12-31'
ORDER BY region_name, customer_id, start_date, end_date, node_id)V
GROUP BY region_name, customer_id,node_id
ORDER BY region_name, customer_id,node_id)W;


















