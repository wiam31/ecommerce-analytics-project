select
    InvoiceNo,
    cast(CustomerID as integer) as customer_id,
    StockCode as product_id,
    Quantity,
    UnitPrice,
    TotalPrice,
    cast(InvoiceDate as timestamp) as invoice_date
from read_csv_auto('../data/silver/online_retail_returns.csv')