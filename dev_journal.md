# Development Journal

## 2026-05-24

Focused on the Operations page, reviewed the operational KPI definitions, and finalized the dashboard structure for portfolio publication.

### Final Dashboard Structure

- Added a dedicated `Home` page as the report entry point and navigation menu.
- Final visible report flow:
  - `Home`
  - `Executive Overview`
  - `Finance Overview`
  - `Operations Overview`
- Kept helper/tooltip pages hidden from view mode.
- Added or refined info bookmarks for Executive, Finance, and Operations pages.
- Added reset/info controls to improve dashboard usability and make the report easier to review as a portfolio artifact.
- Published the final dashboard version to Power BI Service and generated a public Power BI report link for portfolio use.

### Dashboard Design Updates

- Standardized the dashboard around a restrained business palette:
  - Executive accent: `#2E86DE`
  - Finance accent: `#8E44AD`
  - Operations accent: `#16A085`
- Preserved KPI status colors:
  - Good: `#2ECC71`
  - Attention: `#F1C40F`
  - Poor: `#E74C3C`
  - Neutral/long tail: `#A6A6A6`
- Refined donut chart colors for payment type and order status to avoid confusing categorical colors with SLA colors.
- Added concise visible guidance for key metrics while keeping full glossary/context inside the info bookmark panels.

### Data Acknowledgement

- Confirmed that the Olist source dataset does not include ordered quantity versus delivered quantity.
- Because of that, a true `In Full` metric cannot be directly calculated from the available data.
- Current `In Full` logic should be treated as a proxy based on delivered orders.
- OTIF should be documented as an approximate operational KPI, not a fully audited supply-chain OTIF metric.

### Modeling Implication

- The Operations dashboard should separate:
  - delivered/completion rate,
  - on-time delivery rate,
  - OTIF proxy.
- This prevents `On Time` and `OTIF` from being presented as independent metrics when they are currently equivalent under the existing SQL logic.
- Confirmed the corrected decomposition: `On-Time Delivered Rate * In Full Proxy = OTIF Proxy`.
- This matches the previous OTIF value before the metric split, because `(on-time delivered orders / delivered orders) * (delivered orders / total orders) = on-time delivered orders / total orders`.
- Documented that "proxy" means an approximate/substitute metric used when the dataset does not contain the fields required for a fully audited business definition.
- Decided not to call `On Time` a proxy, because on-time delivery is directly measurable from `order_delivered_customer_ts` and `order_estimated_delivery_date`.

### Updated KPI References

```text
OTIF Proxy:
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

### Finance Finalization

- Finalized the Finance Overview around revenue, payments, payment gap, average order value, and multi-payment behavior.
- Kept Payment Gap as a reconciliation indicator rather than a profit metric.
- Added a Payment Gap reference line to the trend chart for interpretation.
- Documented Payment Gap interpretation:
  - Good: `<=0.5%`
  - Attention: `0.5%-2%`
  - Poor: `>2%`
- Finalized Product Revenue Pareto as:
  - `Pareto Analysis - Top 80% Revenue vs Remaining Revenue`
- Kept Pareto interpretation separate from ABC:
  - Top 80% revenue drivers are highlighted as priority revenue categories.
  - Remaining categories are treated as long tail.

### Operations Finalization

- Finalized the Operations Overview around orders, OTIF proxy, on-time delivery rate, cancellation rate, and average delivery days.
- Added an OTIF versus On-Time Delivery trend with target reference.
- Added an Operations ABC table based on categorized order volume by product category group.
- Documented ABC thresholds:
  - `A`: up to 80% cumulative categorized orders.
  - `B`: 80% to 95% cumulative categorized orders.
  - `C`: above 95% cumulative categorized orders.
- Documented that the Orders KPI counts all distinct orders, while the ABC table uses categorized order measures.
- Noted that a small variance of around 1% to 3% versus total orders is expected due to non-categorized records.
- Removed analytical ambiguity by blanking ABC Class on the table total row.

### Source Control Notes

- The report is now intended to be committed through PBIP/TMDL files.
- `.pbix` remains a local binary artifact and should not be committed unless intentionally required for distribution.
- Power BI-generated static resources used by the PBIP report should be committed when they are referenced by report visuals.

## 2026-05-21

Focused on making the Power BI project more portfolio-ready and easier to review in GitHub.

### Dashboard Updates

- Refined the Executive Overview page with a clearer mix of KPIs, monthly trend, state ranking, category table, and toggleable distribution analysis.
- Designed the Finance page around five core cards: gross revenue, total payments, payment gap %, average order value, and multi-payment %.
- Added a dynamic rolling-period approach for Finance analysis using 3, 6, 12, 18, and 24-month selections.
- Built a product category revenue Pareto view with an 80% target reference.
- Added conditional Pareto column coloring to highlight the product categories that contribute to the first 80% of revenue.

### Semantic Model Updates

- Added/used dedicated dimensions for cleaner business labels:
  - `d_PaymentType`
  - `d_OrderStatus`
  - `d_State`
- Added a Brazilian state dimension with state code, state name, region, country, map location, latitude, and longitude.
- Added region/state hierarchy planning for slicer use.
- Updated product category analysis to use item-level revenue where category context is required.
- Added product category group logic to reduce raw category complexity from 73 categories to 16 business-friendly groups.
- Preserved products without source category under `Uncategorized`.

### KPI Rules And Palette

Standard status palette:

```text
Green:  #2ECC71
Yellow: #F1C40F
Red:    #E74C3C
Gray:   #A6A6A6
```

KPI references:

```text
OTIF:
0% to 80%      Red / Poor
80% to 90%     Yellow / Attention
90% to 100%    Green / Good

Delivery Days:
0 to 10 days   Green / Good
11 to 15 days  Yellow / Attention
15+ days       Red / Poor

Cancel Rate:
0% to 1%       Green / Good
1% to 3%       Yellow / Attention
3%+            Red / Poor
```

### Source Control Notes

- PBIP/TMDL files are the preferred GitHub artifacts for the Power BI dashboard.
- `.pbi/` cache folders and local Power BI settings should remain ignored.
- The `.pbix` file is still a local binary artifact and should only be committed intentionally if a downloadable report file is required.
