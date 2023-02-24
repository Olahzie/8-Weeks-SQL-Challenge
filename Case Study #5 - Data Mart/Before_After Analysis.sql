
-- Before and After Analysis

-- What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?

-- For the first 4 weeks

WITH before_sales AS(
	SELECT
		extract(week from week_date) as before_weeks,
		sum(sales) as total_sales_before,
		week_date,
		RANK()
		over( order by week_date desc) as date_rank
	FROM clean_weekly_sales
	where week_date < '2020-06-15'
	GROUP BY before_weeks,week_date
	LIMIT 4),

after_sales AS(
	SELECT
		extract(week from week_date) as after_weeks,
		sum(sales) as total_sales_after,
		week_date,
		RANK()
		over( order by week_date asc) as date_rank
	FROM clean_weekly_sales
	where week_date >= '2020-06-15'
	GROUP BY after_weeks,week_date
	LIMIT 4) 

SELECT
	SUM(total_sales_after) - SUM(total_sales_before) AS variance,
	(100*(SUM(total_sales_after) - SUM(total_sales_before))/SUM(total_sales_before)) AS percent_variance
FROM
	(SELECT
		*
	FROM before_sales D
	join after_sales  L
	on D.date_rank = L.date_rank) R
	
	
-- What about the entire 12 weeks before and after?

WITH before_sales AS(
	SELECT
		extract(week from week_date) as before_weeks,
		sum(sales) as total_sales_before,
		week_date,
		RANK()
		over( order by week_date desc) as date_rank
	FROM clean_weekly_sales
	where week_date < '2020-06-15'
	GROUP BY before_weeks,week_date
	LIMIT 12),

after_sales AS(
	SELECT
		extract(week from week_date) as after_weeks,
		sum(sales) as total_sales_after,
		week_date,
		RANK()
		over( order by week_date asc) as date_rank
	FROM clean_weekly_sales
	where week_date >= '2020-06-15'
	GROUP BY after_weeks,week_date
	LIMIT 12) 

SELECT
	SUM(total_sales_after) - SUM(total_sales_before) AS variance,
	(100*(SUM(total_sales_after) - SUM(total_sales_before))/SUM(total_sales_before)) AS percent_variance
FROM
	(SELECT
		*
	FROM before_sales D
	join after_sales  L
	on D.date_rank = L.date_rank) R


-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- Sales metrics for the 4 weeks period

WITH total_sales AS(	
	SELECT
		calender_year, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	GROUP BY calender_year)

SELECT
	calender_year,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales

-- Sales metrics for the 12 weeks period

WITH total_sales AS(	
	SELECT
		calender_year, 
		sum(sales) filter(where week_number between 13 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 36 ) as sales_after
	FROM clean_weekly_sales
	GROUP BY calender_year)

SELECT
	calender_year,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales

