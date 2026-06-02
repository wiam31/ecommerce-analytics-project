select
    Customer_care_calls,
    count(*) as total_customers,
    avg(Prior_purchases) as avg_prior_purchases,
    avg("Reached.on.Time_Y.N") as on_time_rate
from read_csv_auto('../data/silver/train_clean.csv')
group by Customer_care_calls