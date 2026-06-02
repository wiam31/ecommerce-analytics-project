select
    cast(CustomerID as integer) as customer_id,
    max(Country) as country
from read_csv_auto('../data/silver/online_retail_clean.csv')
where CustomerID is not null
group by CustomerID