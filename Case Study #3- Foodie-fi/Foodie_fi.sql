
/* --------------------
   Case Study Questions
   --------------------*/


-- How many customers has Foodie-Fi ever had?
SELECT 
	 COUNT(DISTINCT customer_id ) AS total_customers
FROM foodie_fi.subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
	EXTRACT(MONTH FROM start_date) AS months,
    COUNT(start_date) AS monthly_distribution
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE plan_name = 'trial'
GROUP BY months
ORDER BY months;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
    plan_name,
    COUNT(plan_name) AS events
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE start_date > '2020-12-31'
GROUP BY plan_name
ORDER BY plan_name;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	COUNT(customer_id) filter(where plan_name ='churn'),
	COUNT(customer_id) filter(where plan_name ='churn')/CAST(COUNT(DISTINCT customer_id) AS FLOAT)*100 AS percentage
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

SELECT SUM(churn_customers) filter(where customers <= 2) AS total_churn_customers,
	  ROUND((SUM(churn_customers)filter(where customers <= 2)/COUNT(customer_id)*100),0) AS Percentage
FROM
(SELECT customer_id,	
	COUNT(customer_id) AS customers,
	COUNT(DISTINCT customer_id) filter(where plan_name = 'churn') churn_customers
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
GROUP BY customer_id) V;


-- What is the number and percentage of customer plans after their initial free trial?


SELECT 
	plan_name,
	plans_count,
	round(plans_count/sum(plans_count)over()*100,1) as percentage
FROM
(SELECT
	plan_name,
	COUNT(DISTINCT customer_id) filter (WHERE ranks in (1,2)) as plans_count
FROM
(SELECT 
	customer_id,
	plan_name,
	RANK() OVER(partition by customer_id order by start_date,plan_name) as ranks
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id)N
where plan_name != 'trial'
GROUP BY plan_name) R
GROUP BY plan_name,plans_count;

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

SELECT
	plan_name,
    customer_count,
   round(( customer_count/sum(customer_count) over())*100,1) as percentage_distribution

FROM
(SELECT 
	plan_name,
    count(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE start_date <= '2020-12-31'
GROUP BY plan_name) Z
GROUP BY plan_name,customer_count;

-- How many customers have upgraded to an annual plan in 2020?


SELECT COUNT(DISTINCT customer_id)
FROM
(SELECT  DISTINCT customer_id, 
					plan_name,
					RANK() OVER(partition by customer_id order by start_date,plan_name) as ranks
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE EXTRACT(year from start_date) = '2020') V
where plan_name = 'pro annual' AND ranks >1;

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

SELECT
	ROUND(AVG(high_date - low_value) ,0) AS days_on_average
FROM
(SELECT
	customer_id,
    MIN(start_date) AS low_value,
	 MAX(start_date)  filter (where subscriptions.plan_id = 3) AS high_date 
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
GROUP BY customer_id) N;



-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


SELECT COUNT(DISTINCT customer_id) 
FROM
(SELECT  DISTINCT customer_id, 
					plan_name,
					RANK() OVER(partition by customer_id order by start_date,plan_name) as ranks
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE plan_name IN ('pro monthly','basic monthly') AND EXTRACT(year from start_date) = '2020') V
where plan_name = 'basic monthly' AND ranks =2;






	







