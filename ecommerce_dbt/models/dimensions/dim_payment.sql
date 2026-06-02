-- dim_payment
-- Source : train_clean.csv
-- 1 ligne = 1 mode de livraison distinct

select distinct
    Mode_of_Shipment    as shipment_mode

from read_csv(
    '../data/silver/train_clean.csv',
    types = {'Mode_of_Shipment': 'VARCHAR'}
)

where Mode_of_Shipment is not null