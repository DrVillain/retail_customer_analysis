-- Average Order Value: calculates the average spent per transaction for each customer
-- price * quantity gives the total value of each transaction
-- AVG then averages that across all transactions per customer
-- ordered from highest to lowest average order value

SELECT
    t.customer_id,
    c.full_name,
    CAST(AVG(t.price * t.quantity) AS DECIMAL(10,2)) AS avg_order_value
FROM dbo.cleaned_transactions AS t
JOIN dbo.cleaned_customers AS c 
    ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.full_name
ORDER BY avg_order_value DESC;
