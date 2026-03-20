-- Cohort Analysis: tracks customer retention by grouping customers by their first purchase month
-- and measuring how many come back in subsequent months
-- months_since_first_purchase represents how many months have passed since the customer first purchased
-- retention_percentage is calculated relative to month 1 which is always 100%

WITH first_purchase AS (
    -- finding the first purchase month for each customer
    SELECT
        customer_id,
        MIN(transaction_date) AS first_purchase_date,
        -- truncating to the first day of the month for grouping
        DATEFROMPARTS(YEAR(MIN(transaction_date)), MONTH(MIN(transaction_date)), 1) AS cohort_month
    FROM dbo.cleaned_transactions
    GROUP BY customer_id
),
cohort_data AS (
    -- calculating how many months have passed since the customer first purchased
    SELECT
        t.customer_id,
        f.cohort_month,
        DATEDIFF(MONTH, f.cohort_month, t.transaction_date) + 1 AS months_since_first_purchase
    FROM dbo.cleaned_transactions AS t
    JOIN first_purchase AS f 
        ON t.customer_id = f.customer_id
),
cohort_counts AS (
    -- counting distinct customers per cohort per month
    SELECT
        cohort_month,
        months_since_first_purchase,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_data
    GROUP BY cohort_month, months_since_first_purchase
)

SELECT
    cohort_month,
    months_since_first_purchase,
    total_customers,
    -- retention percentage relative to month 1, month 1 is always 100%
    -- FIRST_VALUE gets the total customers in month 1 for each cohort to use as the denominator
    CAST(total_customers * 100.0 / FIRST_VALUE(total_customers) OVER (
        PARTITION BY cohort_month ORDER BY months_since_first_purchase
    ) AS DECIMAL(10,2)) AS retention_percentage
FROM cohort_counts
ORDER BY cohort_month, months_since_first_purchase;
