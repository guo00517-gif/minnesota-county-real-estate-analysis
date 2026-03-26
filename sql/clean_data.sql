-- Step 1: Check for nulls
SELECT 
    COUNT(*) AS total_rows,
    COUNT(median_sale_price) AS non_null_prices,
    COUNT(*) - COUNT(median_sale_price) AS null_prices,
    COUNT(median_dom) AS non_null_dom,
    COUNT(*) - COUNT(median_dom) AS null_dom
FROM redfin_mn_county;

-- Step 2: Check for outliers
SELECT 
    region,
    median_sale_price,
    period_begin
FROM redfin_mn_county
WHERE median_sale_price > 2000000
   OR median_sale_price < 50000
ORDER BY median_sale_price DESC;

-- Step 3: Create clean view
CREATE OR REPLACE VIEW redfin_clean AS
SELECT *
FROM redfin_mn_county
WHERE median_sale_price IS NOT NULL 
  AND region IS NOT NULL;