-- fact_returns
-- Source : online_retail_returns.csv (factures préfixées C)
-- 1 ligne = 1 retour client

select
    InvoiceNo                               as invoice_no,
    StockCode                               as product_id,
    cast(InvoiceDate as timestamp)          as invoice_date,
    year(cast(InvoiceDate as date))         as year,
    month(cast(InvoiceDate as date))        as month,
    abs(Quantity)                           as quantity_returned,
    UnitPrice                               as unit_price,
    abs(Quantity) * UnitPrice               as return_value,
    Country                                 as country,
    case
        when CustomerID is not null
        then cast(CustomerID as integer)
        else null
    end                                     as customer_id

from read_csv_auto('../data/silver/online_retail_returns.csv')