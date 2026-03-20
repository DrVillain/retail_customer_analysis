-- RFM Analysis: segments customers into groups based on their purchase behavior
-- uses the transactions table to calculate recency, frequency and monetary value
-- each metric is scored 1-5 using NTILE and then combined into a segment label

-- Recency   - days since last purchase, lower is better, scored 1-5 where 5 = most recent
-- Frequency - number of transactions, higher is better, scored 1-5 where 5 = most frequent
-- Monetary  - total spent, higher is better, scored 1-5 where 5 = highest spender

WITH rfm_base AS 
(
    -- calculating the raw RFM metrics per customer
    SELECT
        t.customer_id,
        c.full_name,
        -- days since last purchase from today
        DATEDIFF(DAY, MAX(t.transaction_date), GETDATE()) AS recency_days,
        -- total number of transactions
        COUNT(t.transaction_id) AS frequency,
        -- total spent
        CAST(SUM(t.price * t.quantity) AS DECIMAL(10,2)) AS monetary
    FROM dbo.cleaned_transactions AS t
    JOIN dbo.cleaned_customers AS c 
        ON t.customer_id = c.customer_id
    GROUP BY t.customer_id, c.full_name
),
rfm_scored AS 
(
    -- scoring each metric from 1-5 using NTILE
    -- NTILE(5) divides customers into 5 equal buckets based on the metric
    SELECT
        customer_id,
        full_name,
        recency_days,
        frequency,
        monetary,
        -- recency is reversed since lower days = better = higher score
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
rfm_segmented AS 
(
    -- assigning segment labels based on the RFM scores
    SELECT
        customer_id,
        full_name,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        -- Segment logic:
        -- Champions          - perfect score across all 3 metrics
        -- Loyal Customers    - high frequency and monetary regardless of recency
        -- Potential Loyalists - recent buyers that are building up frequency
        -- At Risk            - used to be great customers but havent bought recently
        -- Needs Attention    - not recent and average frequency
        -- Lost               - worst score across all 3 metrics
        CASE
            WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champions'
            WHEN f_score >= 4 AND m_score >= 4 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score >= 2 THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 2 THEN 'Needs Attention'
            ELSE 'Lost'
        END AS rfm_segment
    FROM rfm_scored
)

SELECT *
FROM rfm_segmented
ORDER BY rfm_segment, monetary DESC;
