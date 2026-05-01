SELECT 
    -- assign the correct datatypes and needed-only columns
    SAFE_CAST(b AS int64) AS customer_id,
    c AS customer_type,
    d AS current_address_country,
    SAFE_CAST(e AS DATE) AS customer_since_date
FROM 
    {{ ref('Customer') }}  -- the raw data source
    -- remove unecessary row
WHERE 
    trim(b) != 'customer_id'
    -- catch exceptions for data integrity for primary key
    AND b IS NOT NULL
    AND lower(b) != 'null'