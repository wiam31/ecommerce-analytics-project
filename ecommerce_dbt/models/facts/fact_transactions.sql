-- fact_transactions
-- Source : online_retail_full.csv
-- 1 ligne = 1 ligne de facture de vente

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_full.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
)

select
    InvoiceNo                               as invoice_no,
    StockCode                               as product_id,
    cast(InvoiceDate as timestamp)          as invoice_date,
    year(cast(InvoiceDate as date))         as year,
    month(cast(InvoiceDate as date))        as month,
    Quantity                                as quantity,
    UnitPrice                               as unit_price,
    Quantity * UnitPrice                    as total_revenue,
    Country                                 as country,
    case
        when CustomerID is not null
        then cast(CustomerID as integer)
        else null
    end                                     as customer_id

from source