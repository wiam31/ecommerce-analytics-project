-- mart_promo_impact
-- Source : train_clean.csv
-- 1 ligne = 1 commande avec décomposition complète de la marge (ST4 CDC §6.3)
--
-- Hypothèse frais de livraison documentée (CDC §6.3) :
--   Ship  : 0.002 £/g  (ex: 1000g = 2.00 £)
--   Flight: 0.005 £/g  (ex: 1000g = 5.00 £)
--   Road  : 0.001 £/g  (ex: 1000g = 1.00 £)
-- Source de référence : tarifs moyens transporteurs UK 2011

with source as (

    select *
    from read_csv(
        '../data/silver/train_clean.csv',
        types = {
            'ï»¿ID': 'INTEGER',
            'Mode_of_Shipment': 'VARCHAR',
            'Discount_offered': 'DOUBLE',
            'Cost_of_the_Product': 'DOUBLE',
            'Weight_in_gms': 'DOUBLE',
            'Customer_rating': 'INTEGER',
            'Customer_care_calls': 'INTEGER',
            'Product_importance': 'VARCHAR',
            'Reached.on.Time_Y.N': 'INTEGER'
        }
    )

)

select

    "ï»¿ID"                                   as order_id,
    Mode_of_Shipment                          as shipment_mode,
    Discount_offered                          as discount_pct,
    Cost_of_the_Product                       as product_cost,
    Weight_in_gms                             as weight_gms,
    Customer_rating                           as customer_rating,
    Customer_care_calls                       as care_calls,
    Product_importance                        as product_importance,
    "Reached.on.Time_Y.N"                     as on_time,

    -- Tranche de remise (CDC §6.4)
    case
        when Discount_offered = 0 then '0% - Prix plein'
        when Discount_offered <= 10 then '1-10% - Remise légère'
        when Discount_offered <= 25 then '11-25% - Remise significative'
        when Discount_offered <= 50 then '26-50% - Promotion forte'
        else '> 50% - Liquidation'
    end as discount_bracket,

    -- Revenu estimé
    round(
        Cost_of_the_Product
        / nullif(1 - Discount_offered / 100.0, 0),
        2
    ) as estimated_revenue,

    -- Marge brute
    round(
        (
            Cost_of_the_Product
            / nullif(1 - Discount_offered / 100.0, 0)
        ) - Cost_of_the_Product,
        2
    ) as gross_margin,

    -- Impact remise
    round(
        (
            Cost_of_the_Product
            / nullif(1 - Discount_offered / 100.0, 0)
        ) * (Discount_offered / 100.0),
        2
    ) as discount_impact,

    -- Frais livraison estimés
    round(
        Weight_in_gms *
        case Mode_of_Shipment
            when 'Ship' then 0.002
            when 'Flight' then 0.005
            when 'Road' then 0.001
            else 0.002
        end,
        2
    ) as shipping_cost,

    -- Marge nette
    round(
        (
            (
                Cost_of_the_Product
                / nullif(1 - Discount_offered / 100.0, 0)
                - Cost_of_the_Product
            )
            -
            (
                Cost_of_the_Product
                / nullif(1 - Discount_offered / 100.0, 0)
                * (Discount_offered / 100.0)
            )
            -
            (
                Weight_in_gms *
                case Mode_of_Shipment
                    when 'Ship' then 0.002
                    when 'Flight' then 0.005
                    when 'Road' then 0.001
                    else 0.002
                end
            )
        ),
        2
    ) as net_margin

from source