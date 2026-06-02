select distinct
    cast(InvoiceDate as date) as date_id,
    year(cast(InvoiceDate as date)) as year,
    month(cast(InvoiceDate as date)) as month,
    day(cast(InvoiceDate as date)) as day
from read_csv_auto('../data/silver/online_retail_clean.csv')