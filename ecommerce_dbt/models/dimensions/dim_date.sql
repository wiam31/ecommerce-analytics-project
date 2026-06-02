-- dim_date
-- Source : online_retail_full.csv
-- 1 ligne = 1 jour du calendrier

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_full.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
)

select distinct
    cast(InvoiceDate as date)                   as date_id,
    year(cast(InvoiceDate as date))             as year,
    month(cast(InvoiceDate as date))            as month,
    day(cast(InvoiceDate as date))              as day,
    dayofweek(cast(InvoiceDate as date))        as day_of_week,
    weekofyear(cast(InvoiceDate as date))       as week_of_year,
    quarter(cast(InvoiceDate as date))          as quarter

from source