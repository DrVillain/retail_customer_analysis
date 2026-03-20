-- Channel Preference: calculates the total interactions and percentage share for each channel
-- NULL channels are filtered out since they cannot be attributed to any channel
-- percentage is calculated using a window function to get the share of each channel
-- out of the total interactions across all channels
-- ordered from most to least used channel

SELECT
    channel,
    COUNT(interaction_id) AS total_interactions,
    CAST(COUNT(interaction_id) * 100.0 / SUM(COUNT(interaction_id)) 
        OVER() AS DECIMAL(10,2)) AS percentage
FROM dbo.cleaned_interactions
WHERE channel IS NOT NULL
GROUP BY channel
ORDER BY total_interactions DESC;
