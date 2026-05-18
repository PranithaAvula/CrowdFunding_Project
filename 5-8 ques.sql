-- 5. Projects Overview KPI :

 -- Total Number of Projects based on outcome 
USE `crowdfunding`;
SELECT state AS outcome,
COUNT(*) AS total_projects
FROM projects
GROUP BY state;
----------------------------------------------------------------------------------------------------
 -- Total Number of Projects based on Locations
 
SELECT state AS outcome,
COUNT(*) AS total_projects
FROM projects
GROUP BY state;
----------------------------------------------------------------------------------------------------
-- Total Number of Projects created by Year , Quarter , Month

SELECT 
calendar.year,
calendar.quarter,
calendar.monthno,
COUNT(projects.projectid) AS total_projects
FROM projects
JOIN calendar
ON date(projects.created_at) = calendar.calendar_date
GROUP BY calendar.year, calendar.quarter, calendar.monthno
ORDER BY calendar.year, calendar.monthno;
--------------------------------------------------------------------------------------------------------
-- Total Number of Projects based on  Category


SELECT 
category.name AS category,
COUNT(projects.projectid) AS total_projects
FROM projects
JOIN category
ON projects.category_id = category.id
GROUP BY category.name
ORDER BY total_projects DESC;
----------------------------------------------------------------------------------------------------------

-- 6 Successful Projects
-- Amount Raised 


SELECT SUM(usd_pledged) AS amount_raised
FROM projects
WHERE state = 'successful';
-----------------------------------------------------------------------------------------------------
--  Number of Backers

SELECT SUM(backers_count) AS number_of_backers
FROM projects
WHERE state = 'successful';
-------------------------------------------------------------------------------------------------------------
--  Avg NUmber of Days for successful projects
SELECT AVG(DATEDIFF(deadline, created_at)) AS avg_days
FROM projects
WHERE state = 'successful';
-------------------------------------------------------------------------------------------------------------


-- 7 Top Successful Projects :
-- Based on Number of Backers

SELECT 
name,
backers_count,
usd_pledged
FROM projects
WHERE state = 'successful'
ORDER BY backers_count DESC
LIMIT 10;
---------------------------------------------------------------------------------------------------------
--  Based on Amount Raised.

SELECT 
name,
usd_pledged,
backers_count
FROM projects
WHERE state = 'successful'
ORDER BY usd_pledged DESC
LIMIT 10;
-------------------------------------------------------------------------------------------------------


-- 8. Percentage of Successful Projects overall
SELECT 
ROUND(
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) 
    / COUNT(*) * 100,2
) AS success_percentage
FROM projects;

-------------------------------------------------------------------------------------
 -- Percentage of Successful Projects  by Category
 
 
SELECT 
c.name AS category,
ROUND(
    SUM(CASE WHEN p.state='successful' THEN 1 ELSE 0 END) 
    / COUNT(*) * 100,2
) AS success_percentage
FROM projects p
JOIN category c
ON p.category_id = c.id
GROUP BY c.name
ORDER BY success_percentage DESC;

------------------------------------------------------------------
-- Percentage of Successful Projects by Year , Month etc..
SELECT 
cal.Year,
cal.Monthfullname,
ROUND(
    SUM(CASE WHEN p.state='successful' THEN 1 ELSE 0 END) 
    / COUNT(*) * 100,2
) AS success_percentage
FROM projects p
JOIN calendar cal
ON DATE(p.created_at)=cal.calendar_date
GROUP BY cal.Year, cal.Monthno, cal.Monthfullname
ORDER BY cal.Year, cal.Monthno;

-----------------------------------------------------------------------------
 --  Percentage of Successful projects by Goal Range 
SELECT 
CASE 
WHEN goal_usd < 10000 THEN '0 - 10K'
WHEN goal_usd BETWEEN 10000 AND 50000 THEN '10K - 50K'
WHEN goal_usd BETWEEN 50001 AND 100000 THEN '50K - 100K'
ELSE '100K+'
END AS goal_range,

ROUND(
SUM(CASE WHEN state='successful' THEN 1 ELSE 0 END)
/ COUNT(*) * 100,2
) AS success_percentage

FROM projects
GROUP BY goal_range
ORDER BY goal_range;