-- Affordable & Rising: county priced below the median MN county AND growing more than 5% year over year
-- Uses the county_yoy_12m view (last 12 months vs prior 12 months, 50+ sales per year)
-- Result: 22 of 74 counties (Redfin data through May 2026)

WITH state_median AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_last_12m) AS median_price
    FROM county_yoy_12m
)
SELECT c.region,
       c.price_last_12m,
       ROUND(s.median_price) AS state_median,
       c.yoy_pct_change,
       c.sold_last_12m
FROM county_yoy_12m c
CROSS JOIN state_median s
WHERE c.price_last_12m < s.median_price
  AND c.yoy_pct_change > 5
ORDER BY c.yoy_pct_change DESC;