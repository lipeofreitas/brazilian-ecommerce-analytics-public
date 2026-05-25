-- Order Payments
CREATE OR ALTER VIEW silver.order_payments AS
WITH s_o_pay AS (
    SELECT
        order_id,
        payment_sequential,

        -- Clean
        NULLIF(UPPER(LTRIM(RTRIM(payment_type))), '') AS payment_type,
        TRY_CAST(payment_installments AS INT) AS payment_installments,
        TRY_CAST(payment_value AS DECIMAL(12,2)) AS payment_value
    FROM bronze.olist_order_payments_dataset
)
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,

    CASE
        WHEN payment_value IS NULL THEN NULL
        WHEN payment_value < 0 THEN 0
        ELSE payment_value
    END AS payment_value
FROM s_o_pay;
GO
