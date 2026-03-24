-- Popular Products: breaks down revenue, units sold and transactions by product and category
-- ordered by product category alphabetically and then by revenue within each category
-- NULL categories are pushed to the bottom
-- intended to identify best selling products and categories for business insights

SELECT
    product_category,
    product_name,
    CAST(SUM(quantity * price * (1 - discount_applied/100.0)) AS DECIMAL(10,2)) AS product_revenue,
    SUM(quantity) AS product_units_sold,
    COUNT(transaction_id) AS product_transactions

FROM dbo.cleaned_transactions
GROUP BY product_category, product_name
ORDER BY 
    CASE WHEN product_category IS NULL THEN 1 ELSE 0 END,
    product_revenue DESC,
    product_category;
