# Brazilian E-Commerce Analytics

End-to-end analytics project built with the Brazilian E-Commerce public dataset. The goal is to model a realistic analytics workflow from raw CSV ingestion to SQL Server transformations, dimensional modeling, data quality checks, and a Power BI dashboard with source-controlled semantic model files.

This project is designed as a portfolio case study for analytics engineering, business intelligence, SQL modeling, and Power BI development.

## Project Goals

- Build a reproducible analytics pipeline using a medallion architecture.
- Ingest raw marketplace data into SQL Server with Python.
- Create clean Silver-layer views for standardized, BI-safe data.
- Build Gold-layer fact and dimension models for reporting.
- Implement data quality checks and business logic in SQL.
- Expose Power BI report, semantic model, DAX measures, and Power Query code through source-controlled PBIP/TMDL files.

## Business Context

The dataset represents orders from a Brazilian e-commerce marketplace. The model supports analysis across:

- Revenue, freight, and payment behavior.
- Order volume and customer purchasing patterns.
- Delivery performance, late deliveries, and fulfillment lead times.
- Operational delivery metrics: delivered rate, on-time delivery rate, and OTIF proxy.
- Payment mix, installments, multi-payment orders, and reconciliation gaps.
- Geographic analysis by customer, seller, and ZIP code prefix.

## Architecture

The project follows a Bronze / Silver / Gold architecture.

```text
Raw CSV files
    -> Python ingestion
        -> SQL Server bronze schema
            -> SQL Silver views
                -> SQL Gold facts and dimensions
                    -> Power BI semantic model and dashboard
```

### Bronze

Raw CSV files from the public dataset are loaded into SQL Server with minimal transformation. This layer preserves the source structure and acts as the ingestion landing area.

### Silver

Silver views standardize and clean the raw data:

- Type normalization with `TRY_CAST` and `TRY_CONVERT`.
- Timestamp conversion for order and delivery events.
- Text cleanup for city, state, category, and payment fields.
- ZIP code prefix validation flags.
- Product completeness classification.
- Basic data quality flags such as zero-weight products and free shipping.

### Gold

Gold models are designed for dashboarding and analytics:

- `gold.fact_orders`: order-level fact table with revenue, freight, payments, lead times, cancellation flags, late delivery logic, and OTIF indicators.
- `gold.fact_order_items`: item-level fact table for product and seller-level analysis.
- `gold.dim_customers`: customer dimension with geographic enrichment.
- `gold.dim_sellers`: seller dimension with geographic enrichment.
- `gold.dim_product`: product dimension with product quality flags.
- `gold.dim_geography` and `gold.dim_geography_zip`: geographic dimensions for city, state, latitude, longitude, and ZIP prefix analysis.
- `gold.dim_date`: reusable calendar dimension for time intelligence.

## Power BI Dashboard

The Power BI report is published publicly through Power BI Service and source-controlled as a Power BI Project (`.pbip`). The binary `.pbix` file is intentionally excluded from this public repository.

The PBIP structure makes the report and semantic model readable in GitHub:

- Report definition files: `powerbi/BrazilianEcommerceAnalytics Dashboard.Report/`
- Semantic model TMDL files: `powerbi/BrazilianEcommerceAnalytics Dashboard.SemanticModel/`
- Power BI project file: `powerbi/BrazilianEcommerceAnalytics Dashboard.pbip`
- Power Query code: `powerbi/powerquery/`

Live dashboard:

- [View the published Power BI report](https://app.powerbi.com/view?r=eyJrIjoiMjhlMjIzOWItY2ZiNi00YWE4LWIwMDUtY2EyOWNiZmQ0ZjA0IiwidCI6IjY1OWNlMmI4LTA3MTQtNDE5OC04YzM4LWRjOWI2MGFhYmI1NyJ9&embedImagePlaceholder=true)

Dashboard pages include:

- Home
- Executive Overview
- Finance Overview
- Operations Overview
- Hidden tooltip/helper pages used for interactive report elements

### Home Page

The Home page acts as a clean navigation layer for the report:

- Minimal portfolio-ready entry page for the dashboard.
- Navigation buttons to Executive Overview, Finance Overview, and Operations Overview.
- Project metadata for the analytics stack and dataset source.
- Visual style aligned with the report palette and department-level page accents.

### Executive Overview Page

The Executive Overview page provides a high-level summary of marketplace performance:

- KPI cards for gross revenue, orders, OTIF proxy, cancellation rate, and average order value.
- Monthly revenue and order trend.
- Top states by gross revenue.
- Product category performance table using business-friendly category groups.
- Toggleable donut analysis for order status and payment type distribution.
- Reset and info controls for dashboard usability and metric definitions.

### Finance Overview Page

The Finance Overview page focuses on revenue, payment behavior, and reconciliation:

- KPI cards for gross revenue, total payments, payment gap %, average order value, and multi-payment %.
- Dynamic rolling revenue and payment gap analysis using selectable 3, 6, 12, 18, and 24-month windows.
- Product category revenue Pareto analysis highlighting the product categories that drive the first 80% of cumulative revenue.
- Payment type distribution and payment gap tracking.
- Finance-specific slicers such as date, region/state, product category, and payment type.
- Info bookmark with payment gap, Pareto, and finance KPI definitions.

### Operations Overview Page

The Operations Overview page focuses on fulfillment and delivery performance:

- KPI cards for orders, OTIF proxy, on-time delivery rate, cancellation rate, and average delivery days.
- OTIF proxy and on-time delivery trend with target reference.
- Order status and payment type distribution views.
- ABC analysis by categorized order volume and product category group.
- Delivery, OTIF, and cancellation performance by product category.
- Info bookmark explaining OTIF proxy logic, ABC analysis, categorized orders, and SLA references.

The semantic model includes DAX measures grouped by business area:

- Finance: gross revenue, total payments, freight amount, revenue per order, revenue per customer, payment gap, payment type share.
- KPI: cancel rate, OTIF proxy, on-time delivery rate, delivered rate / in-full proxy, approval delay, delivery lead time, warehouse days.
- Time intelligence: MTD, YTD, prior-year comparisons, YoY growth, cumulative revenue, dynamic rolling revenue and orders.
- Operations: delivery days, last-mile days, late delivery days, delivered orders, in-transit items.

## Modeling Decisions

Several modeling choices were added to make the dashboard more readable and portfolio-ready:

- Product categories were grouped from 73 raw categories into 16 executive-level category groups, reducing category complexity by 78.1%.
- Products without a source category are grouped under `Uncategorized`.
- Payment types and order statuses are modeled through dedicated dimensions for clean labels and stable slicers.
- Brazilian states are modeled through a dedicated state dimension with state code, state name, region, country, and latitude/longitude fields to reduce map geocoding ambiguity.
- Product-category measures use item-level revenue from `f_Order_items` to avoid repeating order-level totals across categories.
- The Finance Pareto view uses item-level gross revenue and highlights the product categories contributing to the first 80% of cumulative revenue; the remaining categories are treated as long tail.
- The Operations ABC table uses categorized order measures. The Orders KPI counts all distinct orders, while the ABC table counts orders that can be linked to a product category. A small variance of around 1% to 3% versus total orders is expected due to non-categorized records.
- The source dataset does not include ordered quantity versus delivered quantity. Because of that, a true `In Full` metric cannot be directly calculated; delivered orders are treated as an `In Full` proxy, and OTIF is documented as an approximate operational KPI rather than a fully audited supply-chain OTIF metric.
- The Operations model decomposes OTIF Proxy as `On-Time Delivered Rate * In Full Proxy`. This preserves the previous OTIF value while making the logic explicit: on-time delivered orders over delivered orders, multiplied by delivered orders over total orders, equals on-time delivered orders over total orders.
- In this project, "proxy" means an approximate or substitute metric used when the source dataset does not contain the fields required for the fully audited business definition.

## KPI References

The dashboard uses a consistent status palette for KPI interpretation:

```text
Green:  #2ECC71
Yellow: #F1C40F
Red:    #E74C3C
Gray:   #A6A6A6
```

Operational KPI thresholds:

```text
OTIF:
0% to 80%      Red / Poor
80% to 90%     Yellow / Attention
90% to 100%    Green / Good

On-Time Delivery Rate:
0% to 85%      Red / Poor
85% to 95%     Yellow / Attention
95% to 100%    Green / Good

Delivery Days:
0 to 10 days   Green / Good
11 to 15 days  Yellow / Attention
15+ days       Red / Poor

Cancel Rate:
0% to 1%       Green / Good
1% to 3%       Yellow / Attention
3%+            Red / Poor

Payment Gap:
0% to 0.5%     Green / Good
0.5% to 2%     Yellow / Attention
2%+            Red / Poor
```

Prioritization references:

```text
Revenue Pareto:
Top 80% revenue drivers  Green / Priority revenue categories
Remaining revenue        Gray / Long tail

Operations ABC:
A: up to 80% cumulative categorized orders      Green / Priority
B: 80% to 95% cumulative categorized orders     Yellow / Secondary
C: above 95% cumulative categorized orders      Gray / Long tail
```

## Repository Structure

```text
.
|-- data/
|   `-- 0. raw/                         # Raw CSV files are downloaded locally and not committed
|-- scripts/
|   `-- load_bronze.py                  # Loads CSV files into SQL Server bronze schema
|-- sql/
|   |-- 01_db_and_schema_creation.sql
|   |-- 02_0_silver_*.sql               # Silver-layer cleaning and standardization views
|   |-- 02_1_silver_data_quality.sql
|   |-- 02_2_other_silver_checks.sql
|   |-- 03_0_gold_*.sql                 # Gold dimensions and facts
|   |-- 03_1_gold_*.sql                 # Additional BI-ready facts and dimensions
|   `-- 03_2_gold_dim_state.sql         # Brazilian state dimension
|-- powerbi/
|   |-- BrazilianEcommerceAnalytics Dashboard.pbip
|   |-- BrazilianEcommerceAnalytics Dashboard.Report/
|   |-- BrazilianEcommerceAnalytics Dashboard.SemanticModel/
|   `-- powerquery/
|-- requirements.txt
|-- LICENSE
`-- README.md
```

## Tech Stack

- SQL Server 2022
- T-SQL
- Python
- pandas
- SQLAlchemy
- pyodbc
- Power BI Desktop
- Power BI Project files (`.pbip`)
- TMDL for semantic model source control
- Git and GitHub

## How to Reproduce

### 1. Create a Python environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install pandas numpy matplotlib sqlalchemy pyodbc
```

### 2. Prepare SQL Server

Create the database and schemas:

```sql
CREATE DATABASE BrazilianEcommerceAnalytics;
GO

USE BrazilianEcommerceAnalytics;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
```

### 3. Add raw data

Download the Brazilian E-Commerce public dataset and place the CSV files under the local folder below. Raw CSV files are not committed to this public repository.

```text
data/0. raw/
```

Expected files include:

- `olist_customers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_orders_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `product_category_name_translation.csv`

### 4. Load Bronze tables

Update the SQL Server connection settings in `scripts/load_bronze.py` if needed, then run:

```powershell
python scripts/load_bronze.py
```

### 5. Run SQL transformations

Run the SQL scripts in order:

```text
sql/02_0_silver_*.sql
sql/02_1_silver_data_quality.sql
sql/03_0_gold_*.sql
sql/03_1_gold_*.sql
```

The Silver scripts create standardized views. The Gold scripts create analytics-ready facts, dimensions, and supporting tables.

### 6. Open the Power BI project

Open the PBIP file in Power BI Desktop:

```text
powerbi/BrazilianEcommerceAnalytics Dashboard.pbip
```

Power BI local cache files under `.pbi/` are intentionally ignored by Git.

## Source Control Notes

The repository is configured to prioritize code and metadata over local/generated artifacts:

- PBIP, TMDL, SQL, Python, and Power Query files are source-controlled.
- Power BI cache files under `.pbi/` are ignored.
- Local virtual environments are ignored.
- Raw CSV files are ignored and should be downloaded locally from the public source dataset.
- `.pbix` files are treated as local binary artifacts and are intentionally excluded from the public repository.

## Portfolio Highlights

This project demonstrates:

- Analytics engineering workflow from ingestion to dashboard.
- SQL-based data modeling using fact and dimension tables.
- Data quality checks embedded in the transformation layer.
- Operational KPIs such as OTIF proxy, on-time delivery, late delivery, and lead times.
- Finance KPIs such as gross revenue, freight share, payment gap, and payment mix.
- Revenue Pareto and Operations ABC analysis for business prioritization.
- Interactive Power BI navigation using a Home page, reset controls, bookmarks, and info panels.
- Power BI semantic model versioning with PBIP/TMDL.
- DAX measures organized by Finance, KPI, Time, and Operations logic.

## License

This project is licensed under the terms of the repository license.
