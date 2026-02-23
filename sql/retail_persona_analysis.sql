-- Task 1: Create Database and Schema for RetailVC

-- 1️⃣ Create the main database
CREATE DATABASE IF NOT EXISTS retailvc
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

-- 2️⃣ Use the database
USE retailvc;

-- 3️⃣ Confirm the active schema
SELECT DATABASE() AS current_schema;

-- 4️⃣ Optional: view all available databases
SHOW DATABASES;

-- Step-by-Step SQL Checks
USE retailvc;

-- See if your table is there
SHOW TABLES;

-- Count total rows
SELECT COUNT(*) AS total_rows FROM marketing_campaign;

-- Step 2. Quick peek at your data
SELECT * FROM marketing_campaign LIMIT 10;

-- Step 3. Check for missing values (NULLs or blanks)
-- Run this to quickly count nulls across all main columns:

SELECT 
  SUM(CASE WHEN year_birth IS NULL THEN 1 ELSE 0 END) AS missing_year_birth,
  SUM(CASE WHEN income IS NULL THEN 1 ELSE 0 END) AS missing_income,
  SUM(CASE WHEN marital_Status IS NULL THEN 1 ELSE 0 END) AS missing_marital_status,
  SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) AS missing_education,
  SUM(CASE WHEN response IS NULL THEN 1 ELSE 0 END) AS missing_response
FROM marketing_campaign;

-- Step 4. Check unique ID count (no duplicate customers)
SELECT COUNT(DISTINCT id) AS unique_ids,
       COUNT(*) AS total_rows
FROM marketing_campaign;

SELECT 
    COUNT(DISTINCT `ï»¿id`) AS unique_ids,
    COUNT(*) AS total_rows
FROM marketing_campaign;

-- altering the name above ALTER TABLE marketing_campaign 
ALTER TABLE marketing_campaign 
CHANGE COLUMN `ï»¿id` id INT;

-- re_running the query with the correct name
SELECT COUNT(DISTINCT id) AS unique_ids,
       COUNT(*) AS total_rows
FROM marketing_campaign;


-- Step 5. Check for weird values

-- Negative or zero income
SELECT COUNT(*) AS invalid_income 
FROM marketing_campaign
WHERE income <= 0;

-- Unrealistic ages (<18 or >100)
SELECT COUNT(*) AS invalid_age
FROM marketing_campaign
WHERE age < 18 OR age > 100;

-- Invalid year_birth
SELECT COUNT(*) AS invalid_year
FROM marketing_campaign
WHERE year_birth < 1900 OR year_birth > YEAR(CURDATE());

-- Step 6. Check for empty strings (not just NULL)
SELECT COUNT(*) AS blank_marital_status 
FROM marketing_campaign 
WHERE TRIM(marital_Status) = '';

-- Task 4 – Data Exploration (Descriptive SQL Insights)
-- confirming  the structure and shape of your data first.

USE retailvc;

-- Check the number of rows
SELECT COUNT(*) AS total_rows FROM marketing_campaign;

-- Check all column names and their types
DESCRIBE marketing_campaign;

-- Quick glance at a few random rows
SELECT * FROM marketing_campaign LIMIT 10;


-- Step 2 – Basic Descriptive Stats

-- Average, min, and max income
SELECT 
    ROUND(AVG(income), 2) AS avg_income,
    MIN(income) AS min_income,
    MAX(income) AS max_income
FROM marketing_campaign;

-- Average age, youngest, and oldest customer
SELECT 
    ROUND(AVG(age), 1) AS avg_age,
    MIN(age) AS youngest,
    MAX(age) AS oldest
FROM marketing_campaign;

-- Average recency (days since last purchase)
SELECT 
    ROUND(AVG(recency), 1) AS avg_recency,
    MIN(recency) AS most_recent,
    MAX(recency) AS least_recent
FROM marketing_campaign;

--  Step 3 – Category Breakdown
--         exploring categorical data — like education, marital status, and campaign responses.

-- Education distribution
SELECT 
    education, 
    COUNT(*) AS count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM marketing_campaign), 2) AS percentage
FROM marketing_campaign
GROUP BY education
ORDER BY count DESC;

-- Marital Status distribution
SELECT 
    marital_status, 
    COUNT(*) AS count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM marketing_campaign), 2) AS percentage
FROM marketing_campaign
GROUP BY marital_status
ORDER BY count DESC;

-- Response rate overall
SELECT 
    response, 
    COUNT(*) AS count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM marketing_campaign), 2) AS percentage
FROM marketing_campaign
GROUP BY response
ORDER BY response DESC;

-- Step 4 – Income and Response Relationship
--  checking if richer customers responded more to campaigns:

SELECT 
    response,
    ROUND(AVG(income), 2) AS avg_income
FROM marketing_campaign
GROUP BY response;


-- Task 5 – Behavioral & Campaign Insights


-- Disabling safe updates for this session as i got error while updating
SET SQL_SAFE_UPDATES = 0;

-- (a) Create Age Group Column
ALTER TABLE marketing_campaign ADD COLUMN age_group VARCHAR(20);

UPDATE marketing_campaign
SET age_group = CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56+'
END;


-- aa  Average Web Visits by Age Group
SELECT 
    age_group,
    ROUND(AVG(num_web_visits_month), 2) AS avg_web_visits
FROM marketing_campaign
GROUP BY age_group
ORDER BY avg_web_visits DESC;

-- Step 1 – Total Spending Behavior
--        Let’s calculate total spending per customer across all categories.

-- Step 1: Total spending across all product types
SELECT 
    id,
    (mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
     mnt_sweet_products + mnt_gold_prods) AS total_spent
FROM marketing_campaign
LIMIT 10;

-- find the average and extremes:

SELECT 
    ROUND(AVG(mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
              mnt_sweet_products + mnt_gold_prods), 2) AS avg_total_spent,
    MIN(mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
        mnt_sweet_products + mnt_gold_prods) AS min_spent,
    MAX(mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
        mnt_sweet_products + mnt_gold_prods) AS max_spent
FROM marketing_campaign;

-- Step 2 – Spending Breakdown by Category
-- Let’s see which product type brings in the most revenue overall.

SELECT
  ROUND(SUM(mnt_wines), 0) AS total_wines,
  ROUND(SUM(mnt_fruits), 0) AS total_fruits,
  ROUND(SUM(mnt__eat_products), 0) AS total_meat,
  ROUND(SUM(mnt_fish_products), 0) AS total_fish,
  ROUND(SUM(mnt_sweet_products), 0) AS total_sweets,
  ROUND(SUM(mnt_gold_prods), 0) AS total_gold
FROM marketing_campaign;



-- Step 3 – Response Rate by Marital Status
-- Let’s check who responded best.

SELECT 
    marital_status,
    COUNT(*) AS total_customers,
    SUM(response) AS responded,
    ROUND(100 * SUM(response) / COUNT(*), 2) AS response_rate
FROM marketing_campaign
GROUP BY marital_status
ORDER BY response_rate DESC;

-- Step 4 – Response Rate by Education
SELECT 
    education,
    COUNT(*) AS total_customers,
    SUM(response) AS responded,
    ROUND(100 * SUM(response) / COUNT(*), 2) AS response_rate
FROM marketing_campaign
GROUP BY education
ORDER BY response_rate DESC;


-- Step 5 – Response Rate by Income Group
--                    Let’s bucket income to see patterns.

SELECT 
  CASE 
    WHEN income < 25000 THEN 'Low Income (<25K)'
    WHEN income BETWEEN 25000 AND 50000 THEN 'Mid Income (25K-50K)'
    WHEN income BETWEEN 50001 AND 75000 THEN 'Upper Mid (50K-75K)'
    WHEN income BETWEEN 75001 AND 100000 THEN 'High Income (75K-100K)'
    ELSE 'Very High Income (>100K)'
  END AS income_group,
  COUNT(*) AS total_customers,
  SUM(response) AS responders,
  ROUND(100 * SUM(response) / COUNT(*), 2) AS response_rate
FROM marketing_campaign
GROUP BY income_group
ORDER BY income_group;

-- Step 6 – Top 10 Spending Customers Who Responded
-- Let’s find your top loyal responders (they spend and respond):

SELECT 
    id,
    (mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
     mnt_sweet_products + mnt_gold_prods) AS total_spent
FROM marketing_campaign
WHERE response = 1
ORDER BY total_spent DESC
LIMIT 10;

-- Task 6 – RFM Segmentation (Recency–Frequency–Monetary)

-- Step 1 – Create RFM Metrics
--         Let’s calculate each customer’s total_spent, frequency, and recency.

-- Step 1: Create a temporary RFM table
CREATE OR REPLACE VIEW rfm_base AS
SELECT 
    id,
    recency,
    (num_web_purchases + num_catalog_purchases + num_store_purchases) AS frequency,
    (mnt_wines + mnt_fruits + mnt__eat_products + mnt_fish_products +
     mnt_sweet_products + mnt_gold_prods) AS monetary
FROM marketing_campaign;

-- Step 2 – Check RFM Data
SELECT * FROM rfm_base LIMIT 10;

-- Quick sanity check: averages
SELECT 
  ROUND(AVG(recency),1) AS avg_recency,
  ROUND(AVG(frequency),1) AS avg_frequency,
  ROUND(AVG(monetary),1) AS avg_monetary
FROM rfm_base;

-- Step 3 – Assign R, F, M Scores (1–5 scale)
			-- We’ll bucket each metric into quintiles — 1 = worst, 5 = best.

-- Step 3: Scoring Recency, Frequency, and Monetary (1–5 scale)
CREATE OR REPLACE VIEW rfm_scores AS
SELECT 
    id,
    recency,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency DESC) AS R_score,  -- higher recency = worse (recently inactive)
    NTILE(5) OVER (ORDER BY frequency ASC) AS F_score, -- higher frequency = better
    NTILE(5) OVER (ORDER BY monetary ASC) AS M_score   -- higher monetary = better
FROM rfm_base;

-- Step 4 – Combine Scores
               -- Now we combine the three metrics into an overall RFM score.

-- Step 4: Combine into overall RFM Score
CREATE OR REPLACE VIEW rfm_combined AS
SELECT 
    id,
    recency,
    frequency,
    monetary,
    (6 - R_score) AS R_final,  -- invert recency score (low recency = high score)
    F_score,
    M_score,
    CONCAT((6 - R_score), F_score, M_score) AS RFM_Code,
    ROUND(((6 - R_score) + F_score + M_score) / 3, 2) AS RFM_Avg
FROM rfm_scores;

-- Step 5 – Categorize Customers by Segment
					-- Let’s assign human-readable labels.

-- Step 5: Segment customers based on RFM score
CREATE OR REPLACE VIEW rfm_segments AS
SELECT *,
CASE
    WHEN RFM_Avg >= 4.5 THEN 'Loyal Customers'
    WHEN RFM_Avg BETWEEN 3.5 AND 4.49 THEN 'Potential Loyalists'
    WHEN RFM_Avg BETWEEN 2.5 AND 3.49 THEN 'Needs Attention'
    WHEN RFM_Avg BETWEEN 1.5 AND 2.49 THEN 'At Risk'
    ELSE 'Lost Customers'
END AS segment
FROM rfm_combined;

-- Step 6 – View Results
--                    Let’s see how your customer base is distributed.

-- Step 6: View customer segment counts
SELECT 
    segment,
    COUNT(*) AS num_customers,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM rfm_segments), 2) AS percentage
FROM rfm_segments
GROUP BY segment
ORDER BY num_customers DESC;

--  See a few sample top customers
SELECT * FROM rfm_segments 
WHERE segment = 'Loyal Customers'
LIMIT 10;

