-- Bonus Questions

-- Region variance	
		
WITH total_sales AS(	
	SELECT
		region, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	WHERE calender_year = 2020
	GROUP BY region)

SELECT
	region,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales
	
	
-- Platform variance	
	
WITH total_sales AS(	
	SELECT
		platform, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	WHERE calender_year = 2020
	GROUP BY platform)

SELECT
	platform,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales
	


-- Age_band variance

WITH total_sales AS(	
	SELECT
		age_band, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	WHERE calender_year = 2020
	GROUP BY age_band)

SELECT
	age_band,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales
	
	
	
-- Demographic variance

WITH total_sales AS(	
	SELECT
		demographic, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	WHERE calender_year = 2020
	GROUP BY demographic)

SELECT
	demographic,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales
	

-- Customer_type variance

WITH total_sales AS(	
	SELECT
		customer_type, 
		sum(sales) filter(where week_number between 21 and 24 ) as sales_before,
		sum(sales) filter(where week_number between 25 and 28 ) as sales_after
	FROM clean_weekly_sales
	WHERE calender_year = 2020
	GROUP BY customer_type)

SELECT
	customer_type,
	cast(sales_after as float) - cast(sales_before as float) AS variance,
	(100*(cast(sales_after as float) - cast(sales_before as float))/cast(sales_before as float)) AS percent_variance
FROM total_sales