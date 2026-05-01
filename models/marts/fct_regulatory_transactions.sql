SELECT  t.transaction_id,
        t.customer_id,
        t.amount_GBP,
        t.currency_route,
        t.transaction_date,
        c.customer_type,
        c.current_address_country
FROM {{ ref('stg_transactions') }} t
INNER JOIN {{ ref('stg_customers') }} c 
ON t.customer_id = c.customer_id
