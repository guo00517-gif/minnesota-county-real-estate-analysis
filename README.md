# Minnesota County Real Estate Investment Analysis

### [**View Interactive Dashboard on Tableau Public**](https://public.tableau.com/app/profile/jeffery.guo/viz/MinnesotaCountyReal%20EstateInvestmentAnalysis/MinnesotaCountyRealEstateInvestmentAnalysisFeb2026)

## Project Objective
Developed a high-fidelity investment matrix to identify market inefficiencies and "Buy" signals across Minnesota. This project identifies high-yield opportunities by correlating median sale prices with inventory liquidity and YoY price growth.

## Technical Workflow (ETL & Analysis)
* **Data Staging:** Processed a high-volume raw dataset (8M+ rows) from Redfin.
* **SQL Engineering:** Utilized **PostgreSQL** to perform ETL operations, bypassing Excel's row limitations to aggregate monthly housing metrics at the county level.
* **Visualization:** Designed a three-tier interactive dashboard in **Tableau** using a geographic Z-pattern layout for rapid executive decision-making.
* **Data Integrity:** Implemented a filtering logic where 7 low-volume counties were excluded to ensure statistical reliability and prevent outliers from skewing investment signals.

## Data Sources
* **Primary Transaction Data:** [Redfin Data Center](https://www.redfin.com/news/data-center/)
* **Market Validation:** [Zillow Research](https://www.zillow.com/research/data/)