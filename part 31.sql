use tips;

CREATE TABLE cus_transactions (
    customer_id INT,
    transaction_date DATE
);

INSERT INTO cus_transactions VALUES
(1, '2023-01-15'),
(1, '2023-02-10'),
(1, '2023-03-05'),
(2, '2023-01-20'),
(2, '2023-02-15'),
(3, '2023-01-25'),
(3, '2023-02-20'),
(3, '2023-04-10'),
(4, '2023-02-05'),
(4, '2023-03-07'),
(5, '2023-03-10'),
(5, '2023-04-12'),
(6, '2023-01-15'),
(6, '2023-03-18'),
(7, '2023-02-25'),
(7, '2023-04-05'),
(8, '2023-01-30'),
(8, '2023-03-01'),
(9, '2023-02-12'),
(10, '2023-01-18'),
(10, '2023-02-28'),
(11, '2023-03-22');

-- Retention analysis involves calculating the percentage of customers who continue to use your service over a given period.
/* Steps:
1. Define the Time Periods: Determine the time intervals for your analysis (e.g., monthly, weekly).
2. Identify Unique Customers: Extract the list of unique customers for each time period.
3. Calculate Retention Rate: Compare the list of customers in each period to the previous period to see who has stayed.
*/
-- method 1
WITH monthly_customers AS ( -- Extract unique customers per month
    SELECT customer_id, DATE_FORMAT(transaction_date, '%Y-%m-01') AS month
    FROM cus_transactions
    GROUP BY customer_id, month 
),
retention AS ( -- Calculate retention
    SELECT mc1.month AS month,
        COUNT(DISTINCT mc1.customer_id) AS total_customers,
        COUNT(DISTINCT mc2.customer_id) AS retained_customers
    FROM monthly_customers mc1
    LEFT JOIN monthly_customers mc2
    ON mc1.customer_id = mc2.customer_id
        AND mc2.month = DATE_FORMAT(DATE_ADD(mc1.month, INTERVAL 1 MONTH), '%Y-%m-01')
    GROUP BY mc1.month
)
-- Select retention data
SELECT month, total_customers, retained_customers,
    (retained_customers / total_customers) * 100 AS retention_rate
FROM retention
ORDER BY month;

-- method 2
SELECT MONTH(current_month.transaction_date) AS month_date, COUNT(DISTINCT last_month.customer_id) AS retained_customers
FROM cus_transactions current_month
LEFT JOIN cus_transactions last_month
ON current_month.customer_id = last_month.customer_id 
AND PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM current_month.transaction_date), EXTRACT(YEAR_MONTH FROM last_month.transaction_date)) = 1
GROUP BY MONTH(current_month.transaction_date);

-- method 2 (different data)
SELECT MONTH(current_month.order_date) AS month_date, COUNT(DISTINCT last_month.cust_id) AS retained_customers
FROM transactions current_month
LEFT JOIN transactions last_month
ON current_month.cust_id = last_month.cust_id 
AND PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM current_month.order_date), EXTRACT(YEAR_MONTH FROM last_month.order_date)) = 1
GROUP BY MONTH(current_month.order_date);


-- Churn analysis involves identifying the percentage of customers who stop using your service over a specified period.
/* Steps:
1. Define the Time Periods:Similar to retention, determine the time intervals for your analysis.
2. Identify Churned Customers: Identify customers who were active in one period but not in the subsequent period.
3. Calculate Churn Rate: The churn rate can be calculated by comparing the number of churned 
customers to the total number of customers in the previous period.
*/
-- method 1
WITH monthly_customers AS ( --  Extract unique customers per month
    SELECT customer_id, DATE_FORMAT(transaction_date, '%Y-%m-01') AS month
    FROM cus_transactions
    GROUP BY customer_id, month
),
churn AS ( -- Calculate churn
    SELECT mc1.month AS month,
        COUNT(DISTINCT mc1.customer_id) AS total_customers,
        COUNT(DISTINCT mc1.customer_id) - COUNT(DISTINCT mc2.customer_id) AS churned_customers
    FROM monthly_customers mc1
    LEFT JOIN monthly_customers mc2
    ON mc1.customer_id = mc2.customer_id
        AND mc2.month = DATE_FORMAT(DATE_ADD(mc1.month, INTERVAL 1 MONTH), '%Y-%m-01')
    GROUP BY mc1.month
)
--  Select churn data
SELECT month, total_customers, churned_customers,
    (churned_customers / total_customers) * 100 AS churn_rate
FROM churn
ORDER BY month;

-- method 2
SELECT MONTH(last_month.transaction_date) AS month_date, COUNT(DISTINCT last_month.customer_id) AS churned_customers
FROM cus_transactions last_month
LEFT JOIN cus_transactions current_month
ON current_month.customer_id = last_month.customer_id 
AND PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM current_month.transaction_date), EXTRACT(YEAR_MONTH FROM last_month.transaction_date)) = 1
WHERE current_month.customer_id IS NULL
GROUP BY MONTH(last_month.transaction_date);

-- method 2 (different data)
SELECT MONTH(last_month.order_date) AS month_date, COUNT(DISTINCT last_month.cust_id) AS churned_customers
FROM transactions last_month
LEFT JOIN transactions current_month
ON current_month.cust_id = last_month.cust_id 
AND PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM current_month.order_date), EXTRACT(YEAR_MONTH FROM last_month.order_date)) = 1
WHERE current_month.cust_id IS NULL
GROUP BY MONTH(last_month.order_date);











