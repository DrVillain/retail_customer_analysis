WITH cleaned_interactions AS
(
    SELECT
        -- pk is left as is
        interaction_id,

        -- fk is left as is
        customer_id,

        -- removing whitespaces from channel
        TRIM(channel) AS channel,

        -- removing whitespaces from interaction_type
        TRIM(interaction_type) AS interaction_type,

        -- keeping full datetime
        interaction_date,

        -- casting duration to INT and renaming to clarify the unit
        TRY_CAST(duration AS INT) AS duration_seconds,

        -- removing whitespaces from page_or_product
        TRIM(page_or_product) AS page_or_product,

        -- removing whitespaces from session_id
        TRIM(session_id) AS session_id

    FROM dbo.interactions
    
)

SELECT *
INTO cleaned_interactions
FROM cleaned_interactions
