-- !!! the Code below contains the following major caveats: gross/net clarification. Revise according to signed-off requirements !!!

SELECT  t.transaction_id,
        t.customer_id,
        t.amount_gbp_gross,
        t.amount_gbp_net, 
        t.currency_route,
        t.transaction_date,
        c.customer_type,
        c.current_address_country
FROM        {{ ref('stg_transactions') }} t
INNER JOIN  {{ ref('stg_customers') }} c 
        ON t.customer_id = c.customer_id
