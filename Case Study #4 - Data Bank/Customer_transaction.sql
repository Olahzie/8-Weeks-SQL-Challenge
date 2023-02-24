-- B. Customer Transactions

-- What is the unique count and total amount for each transaction type?

SELECT
	txn_type,
	COUNT(txn_type) AS total_txn_type,
	SUM(txn_amount) AS total_txn_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;

-- What is the average total historical deposit counts and amounts for all customers?
SELECT
	ROUND(AVG(cus_txn_type),0) AS avg_txn_type,
	ROUND(AVG(cus_txn_amount),0) AS avg_txn_amount
FROM
(SELECT
	customer_id,
 	SUM(txn_amount) filter(where txn_type ='deposit') AS cus_txn_amount,
	COUNT(txn_type) filter(where txn_type ='deposit') AS cus_txn_type
FROM data_bank.customer_transactions
GROUP BY customer_id
ORDER BY customer_id) R;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

SELECT
	Months,
	COUNT(DISTINCT customer_id)
FROM
(SELECT
	customer_id,
	to_char(txn_date,'Month') AS Months,
	COUNT(customer_id) filter(where txn_type = 'deposit') AS dep_count,
	COUNT(customer_id) filter(where txn_type = 'withdrawal') AS w_count,
 	COUNT(customer_id) filter(where txn_type = 'purchase') AS p_count
FROM data_bank.customer_transactions
GROUP BY customer_id,Months
ORDER BY customer_id, Months)X
WHERE dep_count >1 AND (w_count >=1 OR p_count >=1)
GROUP BY Months
ORDER BY Months;

-- What is the closing balance for each customer at the end of the month?

 WITH cte_closing AS(
 SELECT 
	customer_id,
	txn_date,
	Months,
	(COALESCE(credit,0) - COALESCE(debit,0)) AS closing_balance,
  	ranks
FROM
(SELECT
	customer_id,
	to_char(txn_date,'Month') AS Months,
 	txn_date,
	SUM(txn_amount) filter(where txn_type = 'deposit') AS credit,
 	SUM(txn_amount) filter(where txn_type = 'purchase' OR txn_type ='withdrawal') AS debit,
	RANK() OVER(PARTITION BY customer_id,to_char(txn_date,'Month') ORDER BY txn_date ASC) AS ranks
FROM data_bank.customer_transactions
GROUP BY customer_id, txn_date,txn_amount,Months
ORDER BY customer_id) V) 

SELECT
	DISTINCT customer_id,
	months,
	txn_date,
	closing_bal
FROM
(SELECT 
	e1.customer_id,
	e1.txn_date,
	e1.Months,
	e1.closing_balance ,
	sum(e1.closing_balance) OVER(PARTITION BY e1.customer_id ORDER BY e1.customer_id,e1.txn_date) AS closing_bal,
	e1.ranks,
	RANK() OVER(PARTITION BY e1.customer_id,e1.months ORDER BY e1.ranks DESC) AS rankss
FROM cte_closing  e1
JOIN cte_closing  e2 on e1.customer_id = e2.customer_id 
GROUP BY e1.customer_id, e1.Months, e1.txn_date, e1.closing_balance, e1.ranks
ORDER BY e1.customer_id) O
WHERE rankss = 1
ORDER BY customer_id, txn_date;

-- What is the percentage of customers who increase their closing balance by more than 5%?

 WITH cte_closing AS(
 SELECT 
	customer_id,
	txn_date,
	Months,
	(COALESCE(credit,0) - COALESCE(debit,0)) AS closing_balance,
  	ranks
FROM
(SELECT
	customer_id,
	to_char(txn_date,'Month') AS Months,
 	txn_date,
	SUM(txn_amount) filter(where txn_type = 'deposit') AS credit,
 	SUM(txn_amount) filter(where txn_type = 'purchase' OR txn_type ='withdrawal') AS debit,
	RANK() OVER(PARTITION BY customer_id,to_char(txn_date,'Month') ORDER BY txn_date ASC) AS ranks
FROM data_bank.customer_transactions
GROUP BY customer_id, txn_date,txn_amount,Months
ORDER BY customer_id) V) 


SELECT
	((COUNT(DISTINCT customer_id) filter(where growth >5)/ CAST(COUNT(DISTINCT customer_id)as FLOAT)) *100) || '%' AS cus_perc
FROM
(SELECT customer_id,
		txn_date,
		months,
		closing_bal,
	   ROUND((100 * (NULLIF(closing_bal,0) - lag(NULLIF(closing_bal,0), 1)  
			   OVER (PARTITION BY customer_id ORDER BY customer_id)) / lag(ABS(NULLIF(closing_bal,0)), 1)  
		OVER (PARTITION BY customer_id ORDER BY customer_id)),1) as growth
FROM
(SELECT
	DISTINCT customer_id,
	months,
	txn_date,
	closing_bal
FROM
(SELECT 
	e1.customer_id,
	e1.txn_date,
	e1.Months,
	e1.closing_balance ,
	sum(e1.closing_balance) OVER(PARTITION BY e1.customer_id ORDER BY e1.customer_id,e1.txn_date) AS closing_bal,
	e1.ranks,
	RANK() OVER(PARTITION BY e1.customer_id,e1.months ORDER BY e1.ranks DESC) AS rankss
FROM cte_closing  e1
JOIN cte_closing  e2 on e1.customer_id = e2.customer_id 
GROUP BY e1.customer_id, e1.Months, e1.txn_date, e1.closing_balance, e1.ranks
ORDER BY e1.customer_id) O
WHERE rankss = 1
ORDER BY customer_id, txn_date) H) Y;