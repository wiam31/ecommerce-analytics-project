select
    StockCode as product_id,
    max(Description) as product_name,
    avg(UnitPrice) as avg_unit_price
from read_csv_auto('../data/silver/online_retail_clean.csv')
group by StockCode