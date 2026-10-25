# Minnesota County Real Estate Analysis

Which Minnesota counties are still affordable but rising in price? This project uses Redfin's county housing data and PostgreSQL to compare every county's home prices over the last 12 months against the 12 months before, then flags counties that are cheaper than the typical Minnesota county and growing more than 5% a year. I call these **Affordable & Rising** counties.

**Result:** 22 of 74 counties are Affordable & Rising (data through May 2026). Full list: [`data/county_affordable_rising.csv`](data/county_affordable_rising.csv).

*Dashboard: in progress (Power BI).*

## Data

- **Source:** [Redfin Data Center](https://www.redfin.com/news/data-center/), Housing Market Tracker, county level, monthly.
- The full US file is about 1.35 million rows (711 MB), which is too large for GitHub. Download it from the link above and load it with `sql/01_load_data.sql`.
- After filtering to Minnesota: 39,296 rows, 80 counties, January 2012 to May 2026.
- Each row is one county, one month and one property type (All Residential, Single Family, Townhouse, Condo/Co-op, Multi-Family).

## How it works

| File | What it does |
|---|---|
| `sql/01_load_data.sql` | Loads the raw Redfin file as text, then builds a clean Minnesota table with real dates and numbers. Redfin writes missing values as `NA`, so those are converted to NULL. |
| `sql/02_county_yoy_12m.sql` | View that compares each county's last 12 months (Jun 2025 to May 2026) with the prior 12 months. Uses All Residential only and requires 50+ sales in both periods. |
| `sql/03_affordable_rising.sql` | Flags counties priced below the Minnesota county median that are growing more than 5% year over year. |

**12-month price:** Redfin only publishes a median sale price per month, so the yearly price is a sales-weighted average of the monthly medians. It is an approximation of a true yearly median, not the exact value.

## What I fixed (October 2026)

The first version of this project gave misleading results. When I went back through it, I found three problems:

1. **Mixed property types.** The year-over-year comparison matched counties without matching property type, so a county's condo price could be compared against its single-family price from the year before. Some counties showed up four times with fake growth numbers (one at +491.7%). **Fix:** filter to `All Residential` only.
2. **Tiny samples.** A county with 1 sale one month and 2 the next can swing hundreds of percent. **Fix:** compare full 12-month periods instead of single months, and require at least 50 sales per year in both periods. This leaves 74 of the 80 counties.
3. **Incomplete data.** The original download was missing rows, including Hennepin County's most recent month. **Fix:** re-downloaded the complete Redfin file and checked that every month has 76 to 80 Minnesota counties.

| Version | Counties flagged |
|---|---|
| Original (mixed property types, single month) | 16 |
| Property-type fix, single month | 6 |
| Final (12-month comparison, complete data, 50+ sales) | 22 |

## Limitations and next steps

- 22 of 74 counties (about 30%) pass the test, so "more than 5% growth" may be too easy a bar. A better version would compare each county's growth against statewide growth.
- Monthly medians averaged together are an approximation of the true yearly median.
- Price growth alone doesn't account for rents, taxes or inventory. Adding months of supply and days on market would make the signal stronger.

## Tools

PostgreSQL 18, pgAdmin 4, Power BI Desktop (dashboard)