-- Query 1: Current median price by county (most recent month)
SELECT 
    region,
    median_sale_price,
    median_dom
FROM redfin_clean
WHERE period_begin = (SELECT MAX(period_begin) FROM redfin_clean)
ORDER BY median_sale_price DESC;

-- Query 2: Statewide median price for reference
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY median_sale_price) AS mn_median_price
FROM redfin_clean
WHERE period_begin = '2026-02-01';

-- Query 3: Year-over-year price change by county
SELECT 
    curr.region,
    curr.median_sale_price AS price_2026,
    prev.median_sale_price AS price_2025,
    ROUND(
        (curr.median_sale_price - prev.median_sale_price) 
        / prev.median_sale_price * 100, 1
    ) AS yoy_pct_change
FROM redfin_clean curr
JOIN redfin_clean prev 
    ON curr.region = prev.region
    AND prev.period_begin = '2025-02-01'
WHERE curr.period_begin = '2026-02-01'
ORDER BY yoy_pct_change DESC;

-- Query 4: Seller's market filter (low inventory = high demand)
SELECT 
    region,
    inventory,
    homes_sold,
    ROUND(inventory::NUMERIC / NULLIF(homes_sold, 0), 1) AS months_of_supply
FROM redfin_clean
WHERE period_begin = '2026-02-01'
  AND homes_sold > 0
ORDER BY months_of_supply ASC;

-- Query 5: Rank counties by affordability within each region
SELECT 
    region,
    median_sale_price,
    months_of_supply,
    RANK() OVER (
        ORDER BY median_sale_price ASC
    ) AS affordability_rank
FROM redfin_clean
WHERE period_begin = '2026-02-01'
ORDER BY affordability_rank ASC;

-- Query 6: Percent rank statewide by value
SELECT 
    region,
    median_sale_price,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY median_sale_price)::NUMERIC * 100, 1
    ) AS value_percentile
FROM redfin_clean
WHERE period_begin = '2026-02-01'
ORDER BY value_percentile ASC;

-- Query 7: CTE - Counties with high growth AND below state median (Buy Signal)
WITH yoy_growth AS (
    SELECT 
        curr.region,
        curr.median_sale_price AS current_price,
        ROUND(
            (curr.median_sale_price - prev.median_sale_price) 
            / prev.median_sale_price * 100, 1
        ) AS yoy_growth_pct
    FROM redfin_clean curr
    JOIN redfin_clean prev 
        ON curr.region = prev.region
        AND prev.period_begin = '2025-02-01'
    WHERE curr.period_begin = '2026-02-01'
),
state_median AS (
    SELECT PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY median_sale_price) AS median_val
    FROM redfin_clean
    WHERE period_begin = '2026-02-01'
)
SELECT 
    g.region,
    g.current_price,
    g.yoy_growth_pct,
    s.median_val AS state_median,
    'Buy Signal' AS flag
FROM yoy_growth g, state_median s
WHERE g.current_price < s.median_val
  AND g.yoy_growth_pct > 5
ORDER BY g.yoy_growth_pct DESC;

-- Query 8: CASE - Segment all counties into market tiers
SELECT 
    region,
    median_sale_price,
    median_dom,
    CASE 
        WHEN median_sale_price < 150000 THEN 'Affordable'
        WHEN median_sale_price BETWEEN 150000 AND 250000 THEN 'Mid-Market'
        WHEN median_sale_price BETWEEN 250001 AND 400000 THEN 'Premium'
        ELSE 'Luxury'
    END AS market_tier,
    CASE
        WHEN median_dom < 30 THEN 'Hot'
        WHEN median_dom BETWEEN 30 AND 60 THEN 'Balanced'
        ELSE 'Cool'
    END AS market_temp
FROM redfin_clean
WHERE period_begin = '2026-02-01'
ORDER BY median_sale_price DESC;