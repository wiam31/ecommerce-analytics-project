-- mart_product_perf
-- Source : online_retail_full.csv + online_retail_returns.csv

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_full.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
),

returns as (
    select *
    from read_csv(
        '../data/silver/online_retail_returns.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
),

sales as (
    select
        StockCode                               as product_id,
        max(Description)                        as product_name,
        count(distinct InvoiceNo)               as nb_orders,
        sum(Quantity)                           as total_quantity_sold,
        round(sum(Quantity * UnitPrice), 2)     as total_revenue,
        round(avg(UnitPrice), 2)                as avg_price,
        min(cast(InvoiceDate as date))          as first_sale_date,
        max(cast(InvoiceDate as date))          as last_sale_date
    from source
    group by StockCode
),

ret as (
    select
        StockCode                               as product_id,
        sum(abs(Quantity))                      as total_quantity_returned,
        round(sum(abs(Quantity) * UnitPrice), 2) as total_return_value
    from returns
    group by StockCode
),

total_revenue as (
    select sum(Quantity * UnitPrice) as grand_total
    from source
)

select
    s.product_id,
    s.product_name,
    s.nb_orders,
    s.total_quantity_sold,
    s.total_revenue,
    s.avg_price,
    s.first_sale_date,
    s.last_sale_date,
    coalesce(r.total_quantity_returned, 0)  as total_quantity_returned,
    coalesce(r.total_return_value, 0)       as total_return_value,
    round(
    coalesce(r.total_quantity_returned, 0) * 100.0
    / nullif(s.total_quantity_sold, 0),
    2
) as return_rate_pct,
    round(s.total_revenue * 100.0 / t.grand_total, 4) as market_share_pct,
    case
        when sum(s.total_revenue) over (
            order by s.total_revenue desc
            rows between unbounded preceding and current row
        ) / t.grand_total <= 0.80 then 'A'
        when sum(s.total_revenue) over (
            order by s.total_revenue desc
            rows between unbounded preceding and current row
        ) / t.grand_total <= 0.95 then 'B'
        else 'C'
    end as abc_class

from sales s
left join ret r on s.product_id = r.product_id
cross join total_revenue t
order by s.total_revenue desc