select
    Discount_offered,
    count(*) as nb_orders,
    avg(Cost_of_the_Product) as avg_product_cost,
    avg("Reached.on.Time_Y.N") as delivery_rate
from read_csv_auto('../data/silver/train_clean.csv')
group by Discount_offered