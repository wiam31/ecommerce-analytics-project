-- mart_funnel
-- Source : online_retail_full.csv + train_clean.csv
-- Modélise le funnel de conversion (ST1 CDC §3)

with transactions as (
    select
        InvoiceNo,
        CustomerID,
        StockCode                               as product_id,
        Country                                 as country,
        cast(InvoiceDate as timestamp)          as invoice_date,
        month(cast(InvoiceDate as date))        as month,
        year(cast(InvoiceDate as date))         as year,
        Quantity                                as quantity,
        UnitPrice                               as unit_price,
        Quantity * UnitPrice                    as total_revenue

    from read_csv(
        '../data/silver/online_retail_full.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
),

funnel_steps as (
    select
        'Étape 1 - Sessions estimées'           as funnel_step,
        1                                        as step_order,
        cast(round(count(distinct InvoiceNo) / 0.03) as bigint) as volume,
        cast(null as double)                     as conversion_rate,
        cast(null as double)                     as revenue
    from transactions

    union all

    select
        'Étape 2 - Visiteurs avec intention',
        2,
        cast(round(count(distinct InvoiceNo) / 0.03 * 0.60) as bigint),
        60.0,
        cast(null as double)
    from transactions

    union all

    select
        'Étape 3 - Ajout au panier',
        3,
        cast(round(count(distinct InvoiceNo) / 0.03 * 0.40) as bigint),
        40.0,
        cast(null as double)
    from transactions

    union all

    select
        'Étape 4 - Checkout initié',
        4,
        cast(round(count(distinct InvoiceNo) / 0.03 * 0.08) as bigint),
        8.0,
        cast(null as double)
    from transactions

    union all

    select
        'Étape 5 - Commandes validées',
        5,
        cast(count(distinct InvoiceNo) as bigint),
        3.0,
        round(sum(total_revenue), 2)
    from transactions
)

select * from funnel_steps
order by step_order