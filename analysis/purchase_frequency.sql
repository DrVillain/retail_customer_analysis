-- Purchase Frequency: counts how many transactions each customer has made
-- higher frequency indicates a more loyal and active customer
-- joined with the customers table to include the customer name
-- ordered from most to least frequent buyers

SELECT
    t.customer_id,
    c.full_name,
    COUNT(t.transaction_id) AS purchase_frequency
FROM dbo.cleaned_transactions AS t
JOIN dbo.cleaned_customers AS c 
    ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.full_name
ORDER BY purchase_frequency DESC;
