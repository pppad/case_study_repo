SELECT 
    -- assign the correct datatypes and needed-only columns
    -- defensive coding for better Audit trail is used with SAFE_CAST to Null any surprises and COALESCE to dummy those NULLS
    COALESCE(SAFE_CAST(b AS int64), -1) AS customer_id, 
    COALESCE(c, 'Unknown') AS customer_type, 
    COALESCE(d, 'Unknown') AS current_address_country,
    SAFE_CAST(e AS DATE) AS customer_since_date
FROM 
    {{ ref('Customer') }} -- source: customer csv seed
WHERE 
    -- remove unecessary row
    trim(b) != 'customer_id'
    -- catch exceptions for data integrity for primary key
    AND b IS NOT NULL
    AND lower(b) != 'null'

-- multi-layered validation approach: 
-- using WHERE filters to exclude unidentifiable records at the source, 
-- and COALESCE logic within the transform layer to ensure pipeline stability and technical auditability