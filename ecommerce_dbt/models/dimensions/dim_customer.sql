-- dim_customer
-- Source : online_retail_identified.csv
-- 1 ligne = 1 client unique

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_identified.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
)

select
    cast(CustomerID as integer)             as customer_id,
    max(Country)                            as country,
    count(distinct InvoiceNo)               as total_orders,
    min(cast(InvoiceDate as date))          as first_purchase_date,
    max(cast(InvoiceDate as date))          as last_purchase_date

from source
where CustomerID is not null
group by CustomerID