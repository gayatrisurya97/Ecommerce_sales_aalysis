CREATE TABLE feature_superstore AS
SELECT 
    *,
    
    -- 1️.Profit Margin
    profit / NULLIF(sales, 0) AS profit_margin,
    
    -- 2️. Sales Per Unit
    sales / NULLIF(quantity, 0) AS sales_per_unit,
    
    -- 3️.Discount Level Category
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low'
        WHEN discount <= 0.5 THEN 'Medium'
        ELSE 'High'
    END AS discount_level,
    
    -- 4️.Loss Flag
    CASE
        WHEN profit < 0 THEN 1
        ELSE 0
    END AS is_loss,
    
    -- 5️.High Value Order Flag
    CASE
        WHEN sales > 500 THEN 1
        ELSE 0
    END AS is_high_value,
    
    -- 6️.Region-Category Combination
    region || '_' || category AS region_category

FROM clean_delays;
--avg-region-profit
ALTER TABLE feature_superstore
ADD COLUMN avg_region_profit NUMERIC;

UPDATE feature_superstore f
SET avg_region_profit = sub.avg_profit
FROM (
    SELECT region, AVG(profit) AS avg_profit
    FROM clean_superstore
    GROUP BY region
) sub
WHERE f.region = sub.region;
--profit_rank
ALTER TABLE feature_superstore
ADD COLUMN profit_rank INTEGER;

UPDATE feature_superstore f
SET profit_rank = sub.rank
FROM (
    SELECT 
        ctid,
        RANK() OVER (PARTITION BY region ORDER BY profit DESC) AS rank
    FROM feature_superstore
) sub
WHERE f.ctid = sub.ctid;