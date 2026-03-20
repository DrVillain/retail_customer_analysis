-- Top Customers Ranking: combines spent, frequency, engagement and average order value
-- 40% Total Spent        - how much the customer has spent in total
-- 30% Purchase Frequency - how often the customer buys
-- 20% Engagement Score   - how engaged the customer is across interactions
-- 10% Average Order Value - how much the customer spends per transaction

WITH transaction_metrics AS (
    -- calculating spent metrics per customer from the transactions table
    SELECT
        customer_id,
        CAST(SUM(price * quantity) AS DECIMAL(10,2)) AS total_spent,
        COUNT(transaction_id) AS purchase_frequency,
        CAST(AVG(price * quantity) AS DECIMAL(10,2)) AS avg_order_value
    FROM dbo.cleaned_transactions
    GROUP BY customer_id
),
engagement_metrics AS (
    -- calculating engagement metrics per customer from the interactions table
    SELECT
        customer_id,
        COUNT(interaction_id) AS total_interactions,
        SUM(duration_seconds) AS total_duration_seconds,
        COUNT(DISTINCT interaction_type) AS unique_interaction_types,
        COUNT(DISTINCT channel) AS unique_channels
    FROM dbo.cleaned_interactions
    WHERE channel IS NOT NULL
    GROUP BY customer_id
),
engagement_scored AS (
    -- normalizing and scoring engagement metrics
    SELECT
        customer_id,
        CAST(
            (CAST(total_interactions AS FLOAT) / MAX(total_interactions) OVER() * 0.40) +
            (CAST(total_duration_seconds AS FLOAT) / MAX(total_duration_seconds) OVER() * 0.30) +
            (CAST(unique_interaction_types AS FLOAT) / MAX(unique_interaction_types) OVER() * 0.20) +
            (CAST(unique_channels AS FLOAT) / MAX(unique_channels) OVER() * 0.10)
        AS DECIMAL(10,2)) AS engagement_score
    FROM engagement_metrics
),
combined AS (
    -- combining all metrics and normalizing to 0-1 scale
    SELECT
        t.customer_id,
        c.full_name,
        t.total_spent,
        t.purchase_frequency,
        t.avg_order_value,
        e.engagement_score
    FROM transaction_metrics t
    JOIN dbo.cleaned_customers AS c 
        ON t.customer_id = c.customer_id
    JOIN engagement_scored AS e 
        ON t.customer_id = e.customer_id
),
normalized AS (
    -- normalizing each metric to a 0-1 scale before combining
    SELECT
        customer_id,
        full_name,
        total_spent,
        purchase_frequency,
        avg_order_value,
        engagement_score,
        CAST(total_spent AS FLOAT) / MAX(total_spent) OVER() AS norm_spent,
        CAST(purchase_frequency AS FLOAT) / MAX(purchase_frequency) OVER() AS norm_frequency,
        CAST(avg_order_value AS FLOAT) / MAX(avg_order_value) OVER() AS norm_aov,
        CAST(engagement_score AS FLOAT) / MAX(engagement_score) OVER() AS norm_engagement
    FROM combined
)

SELECT
    customer_id,
    full_name,
    total_spent,
    purchase_frequency,
    avg_order_value,
    engagement_score,
    CAST(
        (norm_spent * 0.40) +
        (norm_frequency * 0.30) +
        (norm_engagement * 0.20) +
        (norm_aov * 0.10)
    AS DECIMAL(10,2)) AS customer_rank_score
FROM normalized
ORDER BY customer_rank_score DESC;
