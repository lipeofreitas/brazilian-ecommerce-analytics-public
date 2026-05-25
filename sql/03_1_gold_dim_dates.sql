USE BrazilianEcommerceAnalytics;
GO

-- Create table once (only if it doesn't exist)
IF OBJECT_ID('gold.dim_date', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_date (
        date_key INT NOT NULL PRIMARY KEY,
        full_date DATE NOT NULL,
        day_number TINYINT NOT NULL,
        month_number TINYINT NOT NULL,
        month_name VARCHAR(20) NOT NULL,
        month_short_name CHAR(3) NOT NULL,
        year_number SMALLINT NOT NULL,
        quarter_number TINYINT NOT NULL,
        week_of_year TINYINT NOT NULL,
        iso_week_number TINYINT NOT NULL, -- ISO-8601 calendar (Weeks start on Monday, could have 53 weeks in a year)
        weekday_number TINYINT NOT NULL,
        weekday_name VARCHAR(20) NOT NULL,
        is_weekend BIT NOT NULL, -- 1 for Saturday/Sunday, 0 for weekdays
        first_day_of_month DATE NOT NULL,
        last_day_of_month DATE NOT NULL
    );
END
GO

-- Rebuild data safely every run
TRUNCATE TABLE gold.dim_date;
GO

DECLARE @start_date DATE = '2015-01-01';
DECLARE @end_date   DATE = '2030-12-31';

WITH dates AS (
    SELECT @start_date AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM dates
    WHERE d < @end_date
)
INSERT INTO gold.dim_date
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS date_key,
    d AS full_date,
    DAY(d) AS day_number,
    MONTH(d) AS month_number,
    DATENAME(MONTH, d) AS month_name,
    LEFT(DATENAME(MONTH, d), 3) AS month_short_name,
    YEAR(d) AS year_number,
    DATEPART(QUARTER, d) AS quarter_number,
    DATEPART(WEEK, d) AS week_of_year,
    DATEPART(ISO_WEEK, d) AS iso_week_number,
    DATEPART(WEEKDAY, d) AS weekday_number,
    DATENAME(WEEKDAY, d) AS weekday_name,
    CASE WHEN DATEPART(WEEKDAY, d) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,
    DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS first_day_of_month, -- Cleaner for BI: better than concat(string())
    EOMONTH(d) AS last_day_of_month
FROM dates
OPTION (MAXRECURSION 0); -- Remove default SQL or 100 interations for my current CTE
GO