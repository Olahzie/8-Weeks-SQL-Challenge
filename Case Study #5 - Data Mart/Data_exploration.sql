-- Data Exploration

SELECT * FROM clean_weekly_sales
DROP TABLE clean_weekly_sales


-- What day of the week is used for each week_date value?


SELECT DISTINCT days 
FROM (SELECT to_char(week_date,'day') as days, * FROM clean_weekly_sales) D

-- What range of week numbers are missing from the dataset?



-- How many total transactions were there for each year in the dataset?

SELECT calender_year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calender_year


-- What is the total sales for each region for each month?

SELECT region,
	   to_char(week_date,'month') as months,
	   SUM(sales) as total_sales
FROM clean_weekly_sales
GROUP BY region, months
ORDER BY region, months

-- What is the total count of transactions for each platform

SELECT
	platform,
	SUM(Transactions)
FROM clean_weekly_sales
GROUP BY platform

-- What is the percentage of sales for Retail vs Shopify for each month?

SELECT
	to_char(week_date,'month') as months,
	(100 * CAST(SUM(sales) filter(where platform = 'Retail')as float)/CAST(SUM(sales) as float)) as retail_perc,
	(100 * CAST(SUM(sales) filter(where platform = 'Shopify')as float)/CAST(SUM(sales) as float)) as shopify_perc
FROM clean_weekly_sales
GROUP BY months


-- What is the percentage of sales by demographic for each year in the dataset?

SELECT
	calender_year,
	(100 * CAST(SUM(sales) filter(where demographic = 'Couples')as float)/CAST(SUM(sales) as float)) as couple_perc,
	(100 * CAST(SUM(sales) filter(where demographic = 'Families')as float)/CAST(SUM(sales) as float)) as families_perc
FROM clean_weekly_sales
GROUP BY calender_year

-- Which age_band and demographic values contribute the most to Retail sales?
SELECT
	age_band,
	demographic,
	(100 * CAST(SUM(sales) filter(where platform = 'Retail')as float)/
	 (SELECT SUM(sales) from clean_weekly_sales
		where platform = 'Retail')) as retail_perc
FROM clean_weekly_sales
GROUP BY age_band, demographic

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?

SELECT 
	calender_year,
	SUM(sales) filter(where platform = 'Retail')/ SUM(transactions) filter(where platform = 'Retail') as avg_trscn_retail,
	SUM(sales) filter(where platform = 'Shopify')/ SUM(transactions) filter(where platform = 'Shopify') as avg_trscn_shopify
FROM clean_weekly_sales
GROUP BY calender_year