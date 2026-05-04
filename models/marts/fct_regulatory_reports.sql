-- !!! Code in this page requires further clarification and adjustments, points documented below. !!!

WITH R1 AS(
    SELECT  SUM(amount_gbp_gross) AS cross_currency_gbp_UK_gross, -- !!! Once Compliance signs-off remove this or below line as appropriate !!!
            SUM(amount_gbp_net) AS cross_currency_gbp_UK_net
    FROM    {{ ref('fct_regulatory_transactions') }} -- inside the marts model
    WHERE   current_address_country IN ('UK', 'GBR') -- !!! potentially Substitute with IP address or Customer address at time of transaction when available !!! , proxy normalised to prevent under-reporting,
        AND currency_route LIKE '%GBP%'
        -- SPLIT(column, ' delimiter '): This turns the string into an Array (a list) -->['GBP', 'USD'], 0 = 1st item, 1 = 2nd etc.
        AND SPLIT(currency_route, ' --> ')[OFFSET(0)] != SPLIT(currency_route, ' --> ')[OFFSET(1)]
        AND Transaction_date BETWEEN '2022-04-01' AND '2023-08-01'
        
), 
R2 AS (
    SELECT  
            -- ! Once Compliance signs-off remove unecessary metrics as appropriate !
            SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] != SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp_gross
                    ELSE 0
                END) AS cross_currency_GBP_USA_gross, 
            SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] = SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp_gross
                    ELSE 0
                END) AS same_currency_GBP_USA_gross, 
            SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] != SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp_net
                    ELSE 0
                END) AS cross_currency_GBP_USA_net, 
            SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] = SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp_net
                    ELSE 0
                END) AS same_currency_GBP_USA_net,  
    FROM    {{ ref('fct_regulatory_transactions') }} -- inside the marts model
    WHERE   current_address_country = 'USA'  -- !!! This requirement is ambiguous, once clarified add the IP address from transactions or the historic address from customer !!!
        AND Transaction_date BETWEEN '2022-04-01' AND '2023-08-01'
)
-- We turn the final outputs to Long Data for better consumption from Vizualisation tools 
-- To be able to present the data we include both and once clarified will be adjusted as necessary
SELECT 'R1 (cross_uk_Gross)' AS Metric, cross_currency_GBP_UK_gross AS amount_gbp
FROM R1
UNION ALL
SELECT 'R1 (cross_uk_Net)' AS Metric, cross_currency_GBP_UK_net AS amount_gbp
FROM R1
UNION ALL
SELECT 'R2a (cross_us_Gross)' AS Metric, cross_currency_GBP_USA_gross AS amount_gbp
FROM R2
UNION ALL
SELECT 'R2b (same_us_Gross)' AS Metric, same_currency_GBP_USA_gross AS amount_gbp
FROM R2
UNION ALL
SELECT 'R2a (cross_us_Net)' AS Metric, cross_currency_GBP_USA_net AS amount_gbp
FROM R2
UNION ALL
SELECT 'R2b (same_us_Net)' AS Metric, same_currency_GBP_USA_net AS amount_gbp
FROM R2
ORDER BY Metric ASC
