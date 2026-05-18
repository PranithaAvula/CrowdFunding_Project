-- 1. Convert the Date fields to Natural Time ( Currently the dates are in Epoch time Read the attached Artical for Reference on Epoch Time 
	-- https://www.epochconverter.com/ )

USE `crowdfunding`;

SELECT * FROM projects;

ALTER TABLE projects ADD created_date DATE GENERATED ALWAYS AS (DATE(FROM_UNIXTIME(created_at))) STORED AFTER created_at;

ALTER TABLE projects ADD deadline_date DATE GENERATED ALWAYS AS (DATE(FROM_UNIXTIME(deadline))) STORED AFTER deadline;

ALTER TABLE projects ADD updated_date DATE GENERATED ALWAYS AS (DATE(FROM_UNIXTIME(updated_at))) STORED AFTER updated_at;

ALTER TABLE projects ADD state_changed_date DATE GENERATED ALWAYS AS (DATE(FROM_UNIXTIME(state_changed_at))) STORED AFTER state_changed_at;

ALTER TABLE projects ADD successful_date DATE GENERATED ALWAYS AS (
CASE 
WHEN successful_at IS NULL OR successful_at = ""
THEN NULL
ELSE DATE(FROM_UNIXTIME(successful_at))
END
) STORED AFTER successful_at;

ALTER TABLE projects ADD launched_date DATE GENERATED ALWAYS AS (DATE(FROM_UNIXTIME(launched_at))) STORED AFTER launched_at;

-----------------------------------------------------------------------------------------------------------------
-- 2. Build a Calendar Table using the Date Column Created Date ( Which has Dates from Minimum Dates and Maximum Dates)
  -- Add all the below Columns in the Calendar Table using the Formulas.



SET @@cte_max_recursion_depth = 10000;

DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar AS
WITH RECURSIVE cal AS (
SELECT MIN(created_date) AS dt 
FROM projects

UNION ALL

SELECT DATE_ADD(dt, INTERVAL 1 DAY)
FROM cal
WHERE dt < (SELECT MAX(created_date) FROM projects)
)

SELECT 
dt AS create_date,
YEAR(dt) AS year,
MONTH(dt) AS month,
MONTHNAME(dt) AS monthfullname,
CONCAT('Q',QUARTER(dt)) AS quarter,
DATE_FORMAT(dt,'%Y-%M') AS yearmonth,
DAYOFWEEK(dt) AS weekday_no,
DAYNAME(dt) AS weekday_name,

CASE
WHEN MONTH(dt) >= 4 THEN CONCAT('FM', MONTH(dt)-3)
ELSE CONCAT('FM', MONTH(dt)+9)
END AS financial_year,

CASE 
WHEN MONTH(dt) BETWEEN 4 AND 6 THEN 'FQ1'
WHEN MONTH(dt) BETWEEN 7 AND 9 THEN 'FQ2'
WHEN MONTH(dt) BETWEEN 10 AND 12 THEN 'FQ3'
ELSE 'FQ4'
END AS financial_quarter

FROM cal;

SELECT * FROM calendar;
------------------------------------------------------------------------------------------------------

-- 3. Build the Data Model using the attached Excel Files.


SELECT * 
FROM projects 
JOIN category
ON projects.category_id = category.id

JOIN creator
ON projects.creator_id = creator.id

JOIN location
ON projects.location_id = location.id

JOIN calendar
ON date(projects.created_at) = calendar.calendar_date;
------------------------------------------------------------------------------------------------------------
-- 4. Convert the Goal amount into USD using the Static USD Rate.

SELECT * FROM projects;

ALTER TABLE projects 
ADD COLUMN goal_usd DOUBLE 
GENERATED ALWAYS AS (goal * static_usd_rate) STORED 
AFTER static_usd_rate;

SELECT * FROM projects;

ALTER TABLE projects 
ADD COLUMN goal_usd DOUBLE 
GENERATED ALWAYS AS (goal * static_usd_rate) STORED 
AFTER static_usd_rate;
-- ---------------------------------------------------------------------------------------------------------------------------