-- dim_product
-- Source : online_retail_full.csv
-- 1 ligne = 1 SKU produit

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_full.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
)

select
    StockCode                   as product_id,
    max(Description)            as product_name,
    avg(UnitPrice)              as avg_unit_price,
    min(UnitPrice)              as min_unit_price,
    max(UnitPrice)              as max_unit_price

from source
where StockCode is not null
group by StockCode