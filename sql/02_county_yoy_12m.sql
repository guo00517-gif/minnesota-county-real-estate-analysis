-- Last 12 months (Jun 2025-May 2026) vs prior 12 months, by county
-- All Residential only (fixes cross-matching of property types)
-- Price = sales-weighted average of monthly medians (approximation; Redfin only publishes monthly medians)
-- Minimum 50 sales per year in both periods (filters out small-sample noise)

CREATE VIEW county_yoy_12m AS
WITH periods AS (
    SELECT region,
           CASE WHEN period_begin BETWEEN '2025-06-01' AND '2026-05-01' THEN 'recent'
                WHEN period_begin BETWEEN '2024-06-01' AND '2025-05-01' THEN 'prior' END AS period,
           median_sale_price, homes_sold
    FROM redfin_mn
    WHERE property_type = 'All Residential'
      AND median_sale_price IS NOT NULL
      AND homes_sold IS NOT NULL
),
yearly AS (
    SELECT region, period, SUM(homes_sold) AS homes_sold,
           ROUND(SUM(median_sale_price * homes_sold) / SUM(homes_sold), 0) AS avg_price
    FROM periods
    WHERE period IS NOT NULL
    GROUP BY region, period
)
SELECT r.region,
       p.avg_price AS price_prior_12m,
       r.avg_price AS price_last_12m,
       p.homes_sold AS sold_prior_12m,
       r.homes_sold AS sold_last_12m,
       ROUND((r.avg_price - p.avg_price) / p.avg_price * 100, 1) AS yoy_pct_change
FROM yearly r
JOIN yearly p ON r.region = p.region AND p.period = 'prior'
WHERE r.period = 'recent'
  AND r.homes_sold >= 50
  AND p.homes_sold >= 50;

-- Check: 74 counties
SELECT * FROM county_yoy_12m ORDER BY yoy_pct_change DESC;