with customer_stats as (

    select
        cast(CustomerID as integer) as customer_id,
        max(cast(InvoiceDate as date)) as last_purchase_date,
        count(distinct InvoiceNo) as frequency,
        sum(Quantity * UnitPrice) as monetary

    from read_csv_auto('../data/silver/online_retail_clean.csv')

    group by CustomerID

)

select
    customer_id,
    frequency,
    monetary
from customer_stats