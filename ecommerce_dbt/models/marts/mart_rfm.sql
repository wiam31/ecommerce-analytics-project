-- mart_rfm
-- Source : online_retail_identified.csv
-- 1 ligne = 1 client avec scores R, F, M, segment et CLV

with source as (
    select *
    from read_csv(
        '../data/silver/online_retail_identified.csv',
        types = {'InvoiceNo': 'VARCHAR', 'CustomerID': 'VARCHAR', 'StockCode': 'VARCHAR'}
    )
),

reference_date as (
    select max(cast(InvoiceDate as date)) + interval '1' day as ref_date
    from source
),

customer_stats as (
    select
        cast(CustomerID as integer)                     as customer_id,
        max(cast(InvoiceDate as date))                  as last_purchase_date,
        count(distinct InvoiceNo)                       as frequency,
        round(sum(Quantity * UnitPrice), 2)             as monetary
    from source
    group by CustomerID
),

rfm_raw as (
    select
        cs.customer_id,
        cs.last_purchase_date,
        cs.frequency,
        cs.monetary,
        datediff('day', cs.last_purchase_date, rd.ref_date) as recency
    from customer_stats cs
    cross join reference_date rd
),

rfm_scores as (
    select
        customer_id,
        last_purchase_date,
        recency,
        frequency,
        monetary,
        case
            when recency <= 30  then 5
            when recency <= 60  then 4
            when recency <= 90  then 3
            when recency <= 180 then 2
            else 1
        end as r_score,
        case
            when frequency >= 10 then 5
            when frequency >= 6  then 4
            when frequency >= 4  then 3
            when frequency >= 2  then 2
            else 1
        end as f_score,
        ntile(5) over (order by monetary) as m_score
    from rfm_raw
),

rfm_segmented as (
    select
        *,
        cast(r_score as varchar) ||
        cast(f_score as varchar) ||
        cast(m_score as varchar) as rfm_score,
        case
            when r_score >= 4 and f_score >= 4 and m_score >= 4 then 'Champions'
            when f_score >= 3 and m_score >= 3                   then 'Loyal Customers'
            when r_score >= 3 and f_score <= 2                   then 'Potential Loyalists'
            when r_score >= 4 and f_score = 1                    then 'New Customers'
            when r_score <= 2 and f_score >= 3                   then 'At Risk'
            when r_score <= 2 and f_score <= 2                   then 'Hibernating'
            when r_score = 1  and f_score = 1 and m_score = 1   then 'Lost'
            else 'Others'
        end as segment
    from rfm_scores
)

select
    customer_id,
    last_purchase_date,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_score,
    segment,
    round(
    (
        (monetary / nullif(frequency, 0))
        * (frequency / 13.0 * 12)
        * 2.0
    ),
    2
) as clv

from rfm_segmented