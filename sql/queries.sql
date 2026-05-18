/* PROJECT: Mobile Game Product Analysis
AUTHOR: Volodymyr Voldymyrovych
DESCRIPTION: Database schema and key product metrics (Retention, Revenue, Segmentation)
*/

-- 1. CREATING TABLES (Database Schema)
CREATE TABLE vv_users_data ( ... );
CREATE TABLE vv_purchases_data ( ... );
CREATE TABLE vv_events_data ( ... );

-- 2. KEY METRICS (Key Performance Indicators)
-- Calculation of Retention, ARPU, and User Segmentation






-- User Table Add a prefix vv_ (Volodymyr Voldymyrovych)
CREATE TABLE vv_users_data (
    user_id INT PRIMARY KEY,
    reg_date DATE,
    country VARCHAR(50),
    device VARCHAR(20),
    channel VARCHAR(50)
);

--Transaction Table Add a prefix vv_ (Volodymyr Voldymyrovych)
CREATE TABLE vv_purchases_data (
    purchase_id INT PRIMARY KEY,
    user_id INT REFERENCES vv_users_data(user_id), -- Foreign Key
    amount NUMERIC(10, 2), -- For monetary values, we use the precise NUMERIC data type instead of FLOAT
    timestamp DATE
);

--Event (Activity) Table  Add a prefix vv_ (Volodymyr Voldymyrovych)
CREATE TABLE vv_events_data (
    event_id SERIAL PRIMARY KEY, -- Automatic line counter
    user_id INT REFERENCES vv_users_data(user_id),
    event_name VARCHAR(50),
    timestamp DATE
);



SELECT  
	u.channel
	,COUNT(DISTINCT u.user_id) as total_usere
	,COUNT(DISTINCT p.user_id) as paying_esers
	,ROUND(COUNT(DISTINCT p.user_id)::numeric / COUNT(DISTINCT u.user_id) * 100, 2) as conversion_rate
	,SUM(p.amount) as total_revenue
	,ROUND(SUM(p.amount) / COUNT(DISTINCT p.user_id), 2) as ARPPU
FROM vv_users_data u
LEFT JOIN vv_purchases_data p on u.user_id = p.user_id
GROUP BY 1
ORDER BY total_revenue desc
;


-- Calculating the Retention Rate
WITH user_cohorts AS (
-- Determine the registration date for each user
	SELECT
		user_id
		,reg_date
	FROM vv_users_data
)
,activity_days AS (
-- calculate the number of days between registration and activity
	SELECT
		e.user_id
		,u.reg_date
		,e.timestamp AS event_date
		,(e.timestamp - u.reg_date) AS diff_days
	FROM vv_events_data e
	JOIN user_cohorts u ON e.user_id = u.user_id
)
SELECT 
	reg_date
	,COUNT(DISTINCT user_id) AS cohortr_size
-- Counting users who returned on specific days
	,COUNT(DISTINCT CASE WHEN diff_days = 1 THEN user_id END) AS day_1_retention
	,COUNT(DISTINCT CASE WHEN diff_days = 7 THEN user_id END) AS day_7_retention
-- Express as a percentage
	,ROUND(COUNT(DISTINCT CASE WHEN diff_days = 1 THEN user_ID END)::NUMERIC / COUNT(DISTINCT user_id) * 100, 2) AS day_1_pct
	,ROUND(COUNT(DISTINCT CASE WHEN diff_days = 7 THEN user_ID END)::NUMERIC / COUNT(DISTINCT user_id) * 100, 2) AS day_7_pct
FROM activity_days
GROUP BY 1
ORDER BY 1
;



-- Analysis of “Whales” and “Dolphins” (Segmentation by Income)
WITH user_revenue AS (
	SELECT
		user_id
		,SUM(amount) AS total_spent
	FROM vv_purchases_data
	GROUP BY 1
)
,ranked_users AS (
	SELECT 
		user_id
		,total_spent
		,NTILE(100) OVER (ORDER BY total_spent DESC) AS revenue_percentile
	FROM user_revenue
)
SELECT 
	CASE 
		WHEN revenue_percentile <= 5 THEN '1. Whale (Top 5%)'
		WHEN revenue_percentile <= 20 THEN '2. Dolphin (Top 20%)'
		ELSE '3. Minnow'
	END AS yser_category
	,COUNT(user_id) AS users_count
	,SUM(total_spent) AS category_revenue
	,ROUND(AVG(total_spent), 2) AS avg_ltv
FROM ranked_users 
GROUP BY 1
ORDER BY 1
;



-- Cumulative Revenue by Day
WITH daily_revenue AS (
	SELECT 
		timestamp::DATE AS sales_date
		,SUM(amount) AS daily_amount
	FROM vv_purchases_data
	GROUP BY 1
)
SELECT 
	sales_date
	,daily_amount
-- Cumulative amount from the beginning of the period to the current date
	,SUM(daily_amount) OVER (ORDER BY sales_date) AS running_total_revenue
-- Average daily check
	,AVG(daily_amount) over(ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7days_avg
FROM daily_revenue 
ORDER BY 1
;