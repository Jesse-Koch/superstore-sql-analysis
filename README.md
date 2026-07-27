# Superstore Sales Analysis (SQL / MySQL)

## Overview
End-to-end SQL analysis of the Kaggle Superstore dataset, examining sales, profit, discounting, and customer behavior to identify prodit drivers. All analysis was performed in MySQL using aggregations, CTEs, and window functions.

## Tools
- MySQL (data cleaning, querying, analysis)

## Dataset
Kaggle Superstore Sales dataset - 9,994 order line items including order id, order/ship dates, customer imformation, location data, product information, sales, quantity, discount, and profit.

## Data Cleaning
The raw CSV required several fixes before analysis:
- **Character encoding**: source file used Latin1/Windows-1252 encoding, causing `Invalid utf8mb4 character string` errors on import. Resolved with `CHARACTER SET latin1` in the `LOAD DATA` statement.
- **Mixed date formats**: `order_date` and `ship_date` contained two inconsistent formats (`MM/DD/YYYY` and `MM-DD-YY`) within the same column. Resolved by loading dates as raw text, then using `REGEXP` to detect each format and `STR_TO_DATE()` to convert conditionally, verifying zero `NULL` results before finalizing the columns as proper `DATE` types.

## Key Findings

### 1. Revenue vs. profit
The top revenue product (Canon imageCLASS 2200 Advanced Copier) is also the top profit product. However, several other high-revenue products are unprofitable. For example, the Cisco TelePresence System EX90 generated $22,638 in sales but a **loss of -$1,811**.

### 2. Effect of discounting on profits
Yes, sharply. Orders discounted below ~20-25% are consistently profitable. Orders discounted **30% or higher consistently lose money**, with losses deepening as discount increases (e.g. average profit per order falls to -$310 at the 50% discount tier).

### 3. Region rank by profitability
| Region | Revenue | Profit Margin |
|---|---|---|
| West | $725K | 14.94% |
| East | $679K | 13.48% |
| South | $392K | 11.93% |
| Central | $501K | **7.92%** |

Central has the weakest profit margin.

### 4. Why Central underperforms
Central applies the highest average discount of any region (**24%**, vs. 10.9% in West) which is consistent with the discount-profitability relationship found in #2.

### 5. Profitability among customer segments
Consumer generates the most revenue and order volume but has the **lowest profit margin (11.55%)**. Home Office, the smallest segment, has the **highest margin (14.03%)**.

### 6. Why Consumer segment underperforms
Unlike the regional finding, discount rates are nearly identical across the three customer segments (~15%), which rules out discounting as the cause. The actual driver is **product mix**: Consumer buys relatively more Furniture (the lowest-margin category across all segments, 1.79-3.31%), and even within shared categories like Office Supplies, Consumer transactions are less profitable (15.48%) than Home Office (20.84%).

### 7. Seasonal sales trends
- **September, November, and December** consistently show the largest sales spikes (back-to-school and holiday-driven)
- **January and February** consistently show sharp drops following the year-end peak
- Despite seasonal swings, cumulative revenue grew steadily year over year (~$484K by end of 2014 to ~$2.3M by end of 2017)

### 8. Top customers
9 of the top 10 customers by revenue are solidly profitable. One, Sean Miller, shows an overall loss, but this traces back to a single large, heavily-discounted order (the same Cisco TelePresence unit from finding #1), not a pattern across his other purchases.

## Central Insight
Excessive discounting (30%+) is the primary driver of lost profit across this dataset; at the product, regional, and individual customer level. The one exception is the Consumer segment, where product mix explains weaker margins (not discounts)

## Recommendations
1. Cap discounts at ~20-25% **(lower limits on products bringing in low profits)**
2. Make necessary changes to the discounting policy in the Central region.
3. Evaluate whether market spending on Consumer segment products could be adjusted toward higher-margin categories/segments.
4. Use the confirmed seasonal pattern (Sept/Nov/Dec peaks, Jan/Feb troughs) for any future inventory and staffing planning.

## Files
- `superstore_analysis.sql` - all queries used in the analysis
- `Sample - Superstore_1.csv` - Raw dataset 
- `README.md` - this description
