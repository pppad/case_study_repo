WITH R1 AS(
    SELECT  SUM(amount_gbp) AS cross_currency_GBP_UK
    FROM    {{ ref('fct_regulatory_transactions') }} -- inside the marts model
    WHERE   current_address_country IN ('UK', 'GBR') -- normalised to prevent under-reporting
        AND currency_route LIKE '%GBP%'
        -- SPLIT(column, ' delimiter '): This turns the string into an Array (a list) -->['GBP', 'USD'], 0 = 1st item, 1 = 2nd etc.
        AND SPLIT(currency_route, ' --> ')[OFFSET(0)] != SPLIT(currency_route, ' --> ')[OFFSET(1)]
        AND Transaction_date BETWEEN '2022-04-01' AND '2023-08-01'
        
), 
R2 AS (
    SELECT  SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] != SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp
                    ELSE 0
                END) AS cross_currency_GBP_USA,
            SUM(CASE WHEN SPLIT(currency_route, ' --> ')[OFFSET(0)] = SPLIT(currency_route, ' --> ')[OFFSET(1)] 
                    THEN amount_gbp
                    ELSE 0
                END) AS same_currency_GBP_USA,   
    FROM    {{ ref('fct_regulatory_transactions') }} -- inside the marts model
    WHERE   current_address_country = 'USA'  -- ip is missing from the Transactions file hence will not be included here
        AND Transaction_date BETWEEN '2022-04-01' AND '2023-08-01'
)
-- We turn the final outputs to Long Data for better consumption from Vizualisation tools 
SELECT 'R1 (Cross Currency GBP - UK)' AS Metric, cross_currency_GBP_UK AS amount_gbp
FROM R1
UNION ALL
SELECT 'R2a (Cross Currency GBP - USA)' AS Metric, cross_currency_GBP_USA AS amount_gbp
FROM R2
UNION ALL
SELECT 'R2a (Same Currency GBP - USA)' AS Metric, same_currency_GBP_USA AS amount_gbp
FROM R2
ORDER BY Metric ASC

--- "UK" includes normalized "GBR" data
--- "US" scoping was limited to address data due to the lack of IP logs in the provided source files
--- Totals are based on Absolute Values (handled in Staging) to ensure the regulator sees all financial activity (e.g reversals)
