USE BrazilianEcommerceAnalytics;
GO

-- Customers
CREATE OR ALTER VIEW silver.customers AS
WITH s_customers AS (
    SELECT
        customer_id,
        customer_unique_id,

        -- Clean
        NULLIF(UPPER(TRIM(customer_city)), '')  AS customer_city,
        NULLIF(UPPER(TRIM(customer_state)), '') AS customer_state,

        TRY_CAST(customer_zip_code_prefix AS INT) AS customer_zip_code_prefix

    FROM bronze.olist_customers_dataset
)
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix,

    -- Flag zip prefixes with 4 or fewer characters (DQ)
    CASE
        WHEN customer_zip_code_prefix IS NULL THEN NULL
        WHEN LEN(customer_zip_code_prefix) <= 4 THEN 1
        ELSE 0
    END AS customer_zip_code_prefix_digits_flag
FROM s_customers;
GO
