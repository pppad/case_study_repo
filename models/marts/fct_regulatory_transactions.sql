SELECT  t.transaction_id,
        t.customer_id,
        t.amount_gbp_gross, -- this is pending Compliance and Regulator confirmation
        t.amount_gbp_net, -- this is pending Compliance and Regulator confirmation
        t.currency_route, -- potential issue if non-standard, continue examining its contents and potentially explore with Compliance if can provide in two separate columns (from and to) for clarity
        t.transaction_date,
        c.customer_type,
        c.current_address_country
FROM        {{ ref('stg_transactions') }} t
INNER JOIN  {{ ref('stg_customers') }} c 
        ON t.customer_id = c.customer_id
