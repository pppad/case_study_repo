WITH raw_transactions AS (
    SELECT * FROM {{ ref('Transactions') }} -- source: transactions csv seed
),

cleaned_transactions AS (
    SELECT 
        -- assign the correct datatypes and needed-only columns
        -- SAFE_CAST to Null unexpected values and COALESCE to flag them
        COALESCE(SAFE_CAST(b AS int64), -1) AS transaction_id,
        COALESCE(SAFE_CAST(c AS int64), -1) AS customer_id,
        COALESCE(ABS(SAFE_CAST(d AS float64)), 0) AS amount_gbp,  -- Filter out zero-value rows, and calculate Gross activity instead of NET
        COALESCE(e, "Unknown --> Unknown") AS currency_route,
        SAFE_CAST(f AS DATE) AS transaction_date
    FROM raw_transactions
    WHERE 
        -- remove unecessary row
        trim(b) != 'transaction_id' 
        -- exclude amounts that may be 0 since this would inflate the population unecessarily
        AND SAFE_CAST(d AS float64) != 0
        -- catch Null exceptions, ensures data integrity for primary and foreign keys
        AND b IS NOT NULL
        AND lower(b) != 'null'
        AND c IS NOT NULL
        AND lower(c) != 'null'  
),

deduplicated_transactions AS (
    SELECT 
    -- restarts a counter for each transaction_id; orders by date to prioritize the most recent entry
        ROW_NUMBER() OVER ( PARTITION BY transaction_id
                            ORDER BY transaction_date DESC
                        ) AS row_idx,
        *
    FROM cleaned_transactions
)

SELECT
    transaction_id,
    customer_id,
    amount_gbp,
    currency_route,
    transaction_date
FROM deduplicated_transactions
WHERE row_idx = 1 -- Only keep the first record per ID

-- multi-layered validation approach: 
-- using WHERE filters to exclude unidentifiable records at the source, 
-- and COALESCE logic within the transform layer to ensure pipeline stability and technical auditability