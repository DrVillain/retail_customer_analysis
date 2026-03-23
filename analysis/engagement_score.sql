-- Engagement Score: calculates a single engagement score per customer based on their interactions
-- metrics are normalized to a 0-1 scale before combining to ensure fair weighting
-- NULL channels are filtered out since they cannot be attributed to any channel

-- Engagement Score Breakdown:
-- 40% Total Interactions        - measures how active the customer is
-- 30% Total Duration            - measures how much time the customer spends
-- 20% Unique Interaction Types  - measures how diverse their interactions are
-- 10% Unique Channels           - measures how many channels they use

WITH engagement_metrics AS (
    -- calculating raw engagement metrics per customer
    SELECT
        i.customer_id,
        c.full_name,
        COUNT(i.interaction_id) AS total_interactions,
        SUM(i.duration_seconds) AS total_duration_seconds,
        COUNT(DISTINCT i.interaction_type) AS unique_interaction_types,
        COUNT(DISTINCT i.channel) AS unique_channels
    FROM dbo.cleaned_interactions AS i
    JOIN dbo.cleaned_customers AS c 
        ON i.customer_id = c.customer_id
    GROUP BY i.customer_id, c.full_name
),
normalized AS (
    -- normalizing each metric to a 0-1 scale so they can be combined fairly
    SELECT
        customer_id,
        full_name,
        CAST(total_interactions AS FLOAT) / MAX(total_interactions) OVER() AS norm_interactions,
        CAST(total_duration_seconds AS FLOAT) / MAX(total_duration_seconds) OVER() AS norm_duration,
        CAST(unique_interaction_types AS FLOAT) / MAX(unique_interaction_types) OVER() AS norm_interaction_types,
        CAST(unique_channels AS FLOAT) / MAX(unique_channels) OVER() AS norm_channels
    FROM engagement_metrics
)

SELECT
    customer_id,
    full_name,
    -- combining normalized metrics into a single engagement score
    CAST(
        (norm_interactions * 0.40) +
        (norm_duration * 0.30) +
        (norm_interaction_types * 0.20) +
        (norm_channels * 0.10)
    AS DECIMAL(10,2)) AS engagement_score
FROM normalized
ORDER BY engagement_score DESC;
