SELECT  
  -- assign the correct datatypes and needed-only columns
    COALESCE(SAFE_CAST(b AS int64), -1) AS transaction_id, -- defensive coding, dummy value to flag any null transaction ids
    COALESCE(SAFE_CAST(c AS int64), -1) AS customer_id, -- defensive coding, dummy value to flag any null customer ids
    COALESCE(SAFE_CAST(d AS float64), 0) AS amount_GBP, -- sum ignores nulls but safer that way
    COALESCE(e, "Unknown --> Unknown") AS currency_route, -- coalesce for all to create a clear audit trail for missing data
    SAFE_CAST(f AS DATE) AS transaction_date
FROM 
    {{ ref('Transactions') }}  -- the raw data source
WHERE 
    trim(b) != 'transaction_id' -- remove unecessary row
    -- catch exceptions for data integrity for primary and foreign keys
    AND b IS NOT NULL
    AND lower(b) != 'null'
    AND c IS NOT NULL
    AND lower(c) != 'null'
    