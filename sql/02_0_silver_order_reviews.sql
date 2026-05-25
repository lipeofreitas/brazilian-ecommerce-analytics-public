USE BrazilianEcommerceAnalytics;
GO


-- Order Reviews
CREATE OR ALTER VIEW silver.order_reviews AS
SELECT
  order_id,
  review_id,
  review_score,
  review_comment_message,
  TRY_CAST(review_creation_date AS datetime2(0)) AS review_creation_date,
  TRY_CAST(review_answer_timestamp AS datetime2(0)) AS review_answer_ts
FROM bronze.olist_order_reviews_dataset;
GO