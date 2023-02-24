-- Data Cleaning 
-- creating a temporary table


WITH clean_table AS(
SELECT
	TO_DATE(week_date,'DD/MM/YY') AS week_date,
	region,
	platform,
	segment,
	customer_type,
	transactions,
	sales
FROM data_mart.weekly_sales)

SELECT
	week_date,
	Extract(week from week_date) as week_number,
	EXTRACT(month from week_date) AS month_number,
	EXTRACT(year from week_date) AS calender_year,
	CASE 
	WHEN substring(segment,2,1) = '1' THEN 'Young Adult'
	WHEN substring(segment,2,1) = '2' THEN 'Middle Aged'
	WHEN substring(segment,2,1) = '3' OR substring(segment,2,1) = '4' THEN 'Retirees'
	ELSE segment
	END AS age_band,
	CASE
	WHEN substring(segment,1,1) = 'C' THEN 'Couples'
	WHEN substring(segment,1,1) = 'F' THEN 'Families'
	ELSE segment
	END AS demographic,
	ROUND(sales/transactions, 2)AS avg_transactions,
	region,
	platform,
	segment,
	customer_type,
	transactions,
	sales
INTO TEMP TABLE clean_weekly_sales
FROM clean_table


	
	