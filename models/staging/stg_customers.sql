-- multi-layered validation approach:
-- using WHERE filters to exclude unidentifiable records at the source,
-- SAFE_CAST & COALESCE logic within the transform layer to ensure pipeline stability and technical auditability
-- ROWNUMBER() to deduplicate customers having the same ID

WITH raw_customers AS (
    SELECT * FROM {{ ref('Customer') }} -- source: customer csv seed
),

cleaned_customers AS (
    SELECT 
        -- assign the correct datatypes and needed-only columns
        -- SAFE_CAST to Null unexpected values and COALESCE to flag them
        COALESCE(SAFE_CAST(b AS int64), -1) AS customer_id, 
        COALESCE(c, 'Unknown') AS customer_type, 
        COALESCE(d, 'Unknown') AS current_address_country,
        SAFE_CAST(e AS DATE) AS customer_since_date
    FROM 
        raw_customers
    WHERE 
        -- remove unecessary row
        trim(b) != 'customer_id'
        -- catch Null exceptions, ensures data integrity for primary key
        AND b IS NOT NULL
        AND lower(b) != 'null'
), 

deduplicated_customers AS (
    SELECT  
    -- restarts a counter for each customer_id; orders by date to prioritize the most recent entry
            ROW_NUMBER() OVER ( PARTITION BY customer_id
                                ORDER BY customer_since_date DESC
                            ) AS row_idx,
            *
    FROM cleaned_customers
)

SELECT 
    customer_id,
    customer_type, 
    current_address_country,
    customer_since_date
FROM deduplicated_customers
WHERE row_idx = 1 -- Only keep the first record per ID