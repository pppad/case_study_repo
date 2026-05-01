SELECT  
  -- assign the correct datatypes and needed-only columns
    SAFE_CAST(b AS int64) AS transaction_id,
    SAFE_CAST(c AS int64) AS customer_id,
    SAFE_CAST(d AS float64) AS amount_GBP,
    e AS currency_route,
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
    