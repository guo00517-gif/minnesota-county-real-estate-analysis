-- Step 1: staging table for Redfin's full US county file (all columns as text)
-- Source: Redfin Data Center, Housing Market Tracker, county, monthly
CREATE TABLE redfin_us_raw (
    period_begin TEXT, period_end TEXT, period_duration TEXT, region_type TEXT,
    region_type_id TEXT, table_id TEXT, is_seasonally_adjusted TEXT, region TEXT,
    city TEXT, state TEXT, state_code TEXT, property_type TEXT, property_type_id TEXT,
    median_sale_price TEXT, median_sale_price_mom TEXT, median_sale_price_yoy TEXT,
    median_list_price TEXT, median_list_price_mom TEXT, median_list_price_yoy TEXT,
    median_ppsf TEXT, median_ppsf_mom TEXT, median_ppsf_yoy TEXT,
    median_list_ppsf TEXT, median_list_ppsf_mom TEXT, median_list_ppsf_yoy TEXT,
    homes_sold TEXT, homes_sold_mom TEXT, homes_sold_yoy TEXT,
    pending_sales TEXT, pending_sales_mom TEXT, pending_sales_yoy TEXT,
    new_listings TEXT, new_listings_mom TEXT, new_listings_yoy TEXT,
    inventory TEXT, inventory_mom TEXT, inventory_yoy TEXT,
    months_of_supply TEXT, months_of_supply_mom TEXT, months_of_supply_yoy TEXT,
    median_dom TEXT, median_dom_mom TEXT, median_dom_yoy TEXT,
    avg_sale_to_list TEXT, avg_sale_to_list_mom TEXT, avg_sale_to_list_yoy TEXT,
    sold_above_list TEXT, sold_above_list_mom TEXT, sold_above_list_yoy TEXT,
    price_drops TEXT, price_drops_mom TEXT, price_drops_yoy TEXT,
    off_market_in_two_weeks TEXT, off_market_in_two_weeks_mom TEXT, off_market_in_two_weeks_yoy TEXT,
    parent_metro_region TEXT, parent_metro_region_metro_code TEXT, last_updated TEXT
);

-- Step 2: load the file (run in psql, not pgAdmin). Loaded 1,351,879 rows.
-- \copy redfin_us_raw FROM 'C:/path/to/county_market_tracker.tsv000' WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE '"')

-- Step 3: Minnesota table with real data types. Redfin writes missing values as 'NA'.
CREATE TABLE redfin_mn AS
SELECT
    period_begin::date                                        AS period_begin,
    region,
    property_type,
    NULLIF(NULLIF(median_sale_price, ''), 'NA')::numeric      AS median_sale_price,
    NULLIF(NULLIF(homes_sold, ''), 'NA')::numeric             AS homes_sold,
    NULLIF(NULLIF(new_listings, ''), 'NA')::numeric           AS new_listings,
    NULLIF(NULLIF(inventory, ''), 'NA')::numeric              AS inventory,
    NULLIF(NULLIF(months_of_supply, ''), 'NA')::numeric       AS months_of_supply,
    NULLIF(NULLIF(median_dom, ''), 'NA')::numeric             AS median_dom,
    NULLIF(NULLIF(avg_sale_to_list, ''), 'NA')::numeric       AS avg_sale_to_list,
    NULLIF(NULLIF(sold_above_list, ''), 'NA')::numeric        AS sold_above_list,
    NULLIF(NULLIF(price_drops, ''), 'NA')::numeric            AS price_drops
FROM redfin_us_raw
WHERE state_code = 'MN'
  AND is_seasonally_adjusted = 'false';

-- Check: 39,296 rows, 80 counties, Jan 2012 to May 2026
SELECT COUNT(*) AS rows, COUNT(DISTINCT region) AS counties,
       MIN(period_begin) AS first_month, MAX(period_begin) AS last_month
FROM redfin_mn;

-- Completeness check: All Residential counties per month (76-80 expected)
SELECT period_begin, COUNT(DISTINCT region) AS mn_counties
FROM redfin_mn
WHERE property_type = 'All Residential'
GROUP BY period_begin
ORDER BY period_begin DESC;