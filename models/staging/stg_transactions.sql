SELECT  
    -- assign the correct datatypes and needed-only columns
    -- defensive coding for better Audit trail is used with SAFE_CAST to Null any surprises and COALESCE to dummy those NULLS
    COALESCE(SAFE_CAST(b AS int64), -1) AS transaction_id,
    COALESCE(SAFE_CAST(c AS int64), -1) AS customer_id,
    COALESCE(ABS(SAFE_CAST(d AS float64)), 0) AS amount_GBP,  -- Filter out zero-value rows
    COALESCE(e, "Unknown --> Unknown") AS currency_route,
    SAFE_CAST(f AS DATE) AS transaction_date
FROM 
    {{ ref('Transactions') }} -- source: transactions csv seed
WHERE 
    -- remove unecessary row
    trim(b) != 'transaction_id' 
    -- catch exceptions for data integrity for primary and foreign keys
    AND b IS NOT NULL
    AND lower(b) != 'null'
    AND c IS NOT NULL
    AND lower(c) != 'null'
    -- we don't need any amounts that are 0 since this would inflate the population unecessarily
    AND SAFE_CAST(d AS float64) != 0

-- multi-layered validation approach: 
-- using WHERE filters to exclude unidentifiable records at the source, 
-- and COALESCE logic within the transform layer to ensure pipeline stability and technical auditability