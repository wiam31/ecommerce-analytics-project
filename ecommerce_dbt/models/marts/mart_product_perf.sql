select
    StockCode as product_id,
    Description,
    sum(Quantity) as total_quantity_sold,
    sum(Quantity * UnitPrice) as total_revenue
from read_csv_auto('../data/silver/online_retail_clean.csv')
group by StockCode, Description