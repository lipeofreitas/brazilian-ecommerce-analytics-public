USE BrazilianEcommerceAnalytics;
GO


CREATE OR ALTER VIEW gold.fact_orders AS
-- 1) Order-level base (dates, status)
WITH s_o AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_ts,
        o.order_approved_ts,
        o.order_delivered_carrier_ts,
        o.order_delivered_customer_ts,
        o.order_estimated_delivery_date,

        -- Date keys (yyyymmdd) for BI ready
        CONVERT(INT, FORMAT(TRY_CONVERT(datetime2(0), o.order_purchase_ts), 'yyyyMMdd')) AS purchase_date_key,
        CONVERT(INT, FORMAT(TRY_CONVERT(datetime2(0), o.order_estimated_delivery_date), 'yyyyMMdd')) AS estimated_delivery_date_key,
        CONVERT(INT, FORMAT(TRY_CONVERT(datetime2(0), o.order_delivered_customer_ts), 'yyyyMMdd')) AS delivered_date_key,
        
        -- Approval time calculation
        CASE
            WHEN o.order_purchase_ts IS NOT NULL
             AND o.order_approved_ts IS NOT NULL
            THEN DATEDIFF(HOUR, o.order_purchase_ts, o.order_approved_ts)
            ELSE NULL
        END AS approval_delay_hours

    FROM silver.orders AS o
),

-- 2) Aggregate items to order grain
s_i AS (
    SELECT
        oi.order_id,
        COUNT(*) AS items_count,
        SUM(ISNULL(oi.price, 0)) AS items_value,
        SUM(ISNULL(oi.freight_value, 0)) AS freight_value,
        SUM(ISNULL(oi.price, 0) + ISNULL(oi.freight_value, 0)) AS gross_revenue,

        -- optional: earliest/latest shipping limit dates at order level
        MIN(oi.shipping_limit_ts) AS first_shipping_limit_ts,
        MAX(oi.shipping_limit_ts) AS last_shipping_limit_ts
    FROM silver.order_items AS oi
    GROUP BY oi.order_id
),

-- 3) Aggregate payments to order grain
s_p AS (
    SELECT
        op.order_id,

        -- Total payment
        SUM(ISNULL(op.payment_value, 0)) AS total_payment_value,

        -- Counts
        COUNT(*) AS payment_rows,
        COUNT(DISTINCT op.payment_type) AS payment_methods_count,
        MAX(op.payment_installments) AS max_installments,

        -- Payment breakdown
        SUM(CASE WHEN op.payment_type = 'credit_card' THEN op.payment_value ELSE 0 END) AS payment_value_credit_card,
        SUM(CASE WHEN op.payment_type = 'boleto' THEN op.payment_value ELSE 0 END) AS payment_value_boleto,
        SUM(CASE WHEN op.payment_type = 'debit_card' THEN op.payment_value ELSE 0 END) AS payment_value_debit_card,
        SUM(CASE WHEN op.payment_type = 'voucher' THEN op.payment_value ELSE 0 END) AS payment_value_voucher,
        SUM(CASE WHEN op.payment_type = 'not_defined' THEN op.payment_value ELSE 0 END) AS payment_value_not_defined,
        SUM(CASE 
                WHEN op.payment_type NOT IN ('credit_card','boleto','debit_card','voucher','not_defined')
                THEN op.payment_value ELSE 0
            END) AS payment_value_other

    FROM silver.order_payments AS op
    GROUP BY op.order_id
)



-- 4) Combine all with simple LEFT JOINs (no ranking, one row per order)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,

    -- Date keys
    o.purchase_date_key,
    o.estimated_delivery_date_key,
    o.delivered_date_key,

    -- Timestamps (keep for detailed analysis)
    o.order_purchase_ts,
    o.order_approved_ts,
    o.order_delivered_carrier_ts,
    o.order_delivered_customer_ts,
    o.order_estimated_delivery_date,

    -- Item totals (order level)
    ISNULL(i.items_count, 0) AS items_count,
    CAST(ISNULL(i.items_value, 0) AS DECIMAL(18,2)) AS items_value,
    CAST(ISNULL(i.items_value, 0) / NULLIF(ISNULL(i.items_count, 0), 0) AS DECIMAL(18,2)) AS avg_item_price,
    CAST(ISNULL(i.freight_value, 0) AS DECIMAL(18,2)) AS freight_value,
    CAST(ISNULL(i.gross_revenue, 0) AS DECIMAL(18,2)) AS gross_revenue,

    -- Payment totals (order level)
    CAST(ISNULL(p.total_payment_value, 0) AS DECIMAL(18,2)) AS total_payment_value,
    ISNULL(p.payment_methods_count, 0) AS payment_methods_count,
    ISNULL(p.payment_rows, 0) AS payment_rows,
    ISNULL(p.max_installments, NULL) AS max_installments,

    -- Payment gap (simple revenue vs payment comparison, not accounting for refunds, discounts, etc.)
    CAST(ISNULL(p.total_payment_value, 0) - ISNULL(i.gross_revenue, 0) AS DECIMAL(18,2)) AS payment_minus_revenue,

    -- Payment breakdown
    CAST(ISNULL(p.payment_value_credit_card, 0) AS DECIMAL(18,2)) AS payment_value_credit_card,
    CAST(ISNULL(p.payment_value_boleto, 0) AS DECIMAL(18,2)) AS payment_value_boleto,
    CAST(ISNULL(p.payment_value_debit_card, 0) AS DECIMAL(18,2)) AS payment_value_debit_card,
    CAST(ISNULL(p.payment_value_voucher, 0) AS DECIMAL(18,2)) AS payment_value_voucher,
    CAST(ISNULL(p.payment_value_not_defined, 0) AS DECIMAL(18,2)) AS payment_value_not_defined,
    CAST(ISNULL(p.payment_value_other, 0) AS DECIMAL(18,2)) AS payment_value_other,
    -- Payment winner value
    (
        SELECT MAX(v)
        FROM (VALUES
            (ISNULL(p.payment_value_credit_card,0)),
            (ISNULL(p.payment_value_boleto,0)),
            (ISNULL(p.payment_value_debit_card,0)),
            (ISNULL(p.payment_value_voucher,0)),
            (ISNULL(p.payment_value_not_defined,0)),
            (ISNULL(p.payment_value_other,0))
        ) AS value_table(v)
    ) AS payment_value_winner,

    -- Payment winner type
    CASE
        WHEN ISNULL(p.payment_value_credit_card,0) >= ISNULL(p.payment_value_boleto,0)
        AND ISNULL(p.payment_value_credit_card,0) >= ISNULL(p.payment_value_debit_card,0)
        AND ISNULL(p.payment_value_credit_card,0) >= ISNULL(p.payment_value_voucher,0)
        AND ISNULL(p.payment_value_credit_card,0) >= ISNULL(p.payment_value_not_defined,0)
        AND ISNULL(p.payment_value_credit_card,0) >= ISNULL(p.payment_value_other,0)
            THEN 'credit_card'

        WHEN ISNULL(p.payment_value_boleto,0) >= ISNULL(p.payment_value_debit_card,0)
        AND ISNULL(p.payment_value_boleto,0) >= ISNULL(p.payment_value_voucher,0)
        AND ISNULL(p.payment_value_boleto,0) >= ISNULL(p.payment_value_not_defined,0)
        AND ISNULL(p.payment_value_boleto,0) >= ISNULL(p.payment_value_other,0)
            THEN 'boleto'

        WHEN ISNULL(p.payment_value_debit_card,0) >= ISNULL(p.payment_value_voucher,0)
        AND ISNULL(p.payment_value_debit_card,0) >= ISNULL(p.payment_value_not_defined,0)
        AND ISNULL(p.payment_value_debit_card,0) >= ISNULL(p.payment_value_other,0)
            THEN 'debit_card'

        WHEN ISNULL(p.payment_value_voucher,0) >= ISNULL(p.payment_value_not_defined,0)
        AND ISNULL(p.payment_value_voucher,0) >= ISNULL(p.payment_value_other,0)
            THEN 'voucher'

        WHEN ISNULL(p.payment_value_not_defined,0) >= ISNULL(p.payment_value_other,0)
            THEN 'not_defined'

        ELSE 'other'
    END AS payment_type_winner,

    -- Lead times & other KPIs
       -- Stage duration in days
    DATEDIFF(DAY, order_purchase_ts, order_delivered_carrier_ts) AS warehouse_days,

    CASE
        WHEN o.order_purchase_ts IS NOT NULL AND o.order_approved_ts IS NOT NULL
        THEN DATEDIFF(HOUR, o.order_purchase_ts, o.order_approved_ts)
        ELSE NULL
    END AS approval_delay_hours,

    CASE
        WHEN o.order_purchase_ts IS NOT NULL AND o.order_delivered_customer_ts IS NOT NULL
        THEN DATEDIFF(DAY, o.order_purchase_ts, o.order_delivered_customer_ts)
        ELSE NULL
    END AS delivery_days,

    CASE
        WHEN o.order_delivered_carrier_ts IS NOT NULL AND o.order_delivered_customer_ts IS NOT NULL
        THEN DATEDIFF(DAY, o.order_delivered_carrier_ts, o.order_delivered_customer_ts)
        ELSE NULL
    END AS last_mile_days,

    -- Fulfillment flags
    CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END AS is_cancelled,

    -- In-Full (simple definition for this dataset): delivered = in full
    CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END AS is_in_full,

    -- On-Time -> delivered on/before estimated date
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_ts IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND o.order_delivered_customer_ts <= o.order_estimated_delivery_date
        THEN 1 ELSE 0
    END AS is_on_time,

    -- Is Late flag
    CASE
        WHEN order_delivered_customer_ts IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
         AND order_delivered_customer_ts > order_estimated_delivery_date
        THEN 1 ELSE 0
    END AS is_late,

    -- Late delivery days (func is_late repeated, no CTE)
    CASE
        WHEN order_delivered_customer_ts > order_estimated_delivery_date
         AND order_delivered_customer_ts IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
        THEN DATEDIFF(
                DAY,
                order_estimated_delivery_date,
                order_delivered_customer_ts
            )
        ELSE 0
    END AS late_delivery_days,

    -- OTIF: On-Time AND In-Full
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_ts IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND o.order_delivered_customer_ts <= o.order_estimated_delivery_date
        THEN 1 ELSE 0
    END AS is_otif,

    CASE
        WHEN order_status = 'canceled'
         AND order_delivered_carrier_ts IS NULL
        THEN 1 ELSE 0
    END AS cancelled_before_shipment,

    CASE
        WHEN approval_delay_hours < 1 THEN '<1h'
        WHEN approval_delay_hours <= 6 THEN '1–6h'
        WHEN approval_delay_hours <= 12 THEN '6–12h'
        WHEN approval_delay_hours <= 24 THEN '12–24h'
        ELSE '24h+'
    END AS approval_speed_bucket


FROM s_o AS o
LEFT JOIN s_i AS i
    ON i.order_id = o.order_id
LEFT JOIN s_p AS p
    ON p.order_id = o.order_id;
GO
