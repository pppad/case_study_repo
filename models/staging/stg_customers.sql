SELECT 
    -- assign the correct datatypes and needed-only columns
    COALESCE(SAFE_CAST(b AS int64), -1) AS customer_id, -- defensive coding, dummy value to flag any null customer ids 
    COALESCE(c, 'Unknown') AS customer_type, -- defensive coding, for better audit trail
    COALESCE(d, 'Unknown') AS current_address_country, -- defensive coding, for better audit trail
    SAFE_CAST(e AS DATE) AS customer_since_date
FROM 
    {{ ref('Customer') }}  -- the raw data source
    -- remove unecessary row
WHERE 
    trim(b) != 'customer_id'
    -- catch exceptions for data integrity for primary key
    AND b IS NOT NULL
    AND lower(b) != 'null'