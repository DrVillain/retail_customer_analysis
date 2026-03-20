-- Interaction Types: counts the total interactions by type and channel
-- NULL interaction types are labeled as 'Other' since they cannot be assumed
-- NULL channels are filtered out since they cannot be attributed to any channel
-- ordered by interaction type and then by total interactions within each type

SELECT
    COALESCE(interaction_type, 'Other') AS interaction_type,
    channel,
    COUNT(interaction_id) AS total_interactions
FROM dbo.cleaned_interactions
WHERE channel IS NOT NULL
GROUP BY interaction_type, channel
ORDER BY
    interaction_type, total_interactions DESC;
