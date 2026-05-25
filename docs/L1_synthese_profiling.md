
# L1 — Synthèse du profiling des datasets

## Dossier projet

`c:\Users\Wiam Ougga\Downloads\ecommerce-analytics-project`

## Datasets analysés

- Online Retail : `data.csv`
- E-Commerce Shipping : `Train.csv`

## Résumé global

| dataset             |   nombre_lignes |   nombre_colonnes |   colonnes_avec_nulls |   total_valeurs_nulles |   nombre_doublons |   taux_doublons_% |   colonnes_numeriques |   colonnes_categorielles |
|:--------------------|----------------:|------------------:|----------------------:|-----------------------:|------------------:|------------------:|----------------------:|-------------------------:|
| Online Retail       |          541909 |                 8 |                     2 |                 136534 |              5268 |              0.97 |                     3 |                        5 |
| E-Commerce Shipping |           10999 |                12 |                     0 |                      0 |                 0 |              0    |                     8 |                        4 |

## Fichiers générés

- `profiling_online_retail.html`
- `profiling_shipping.html`
- `profiling_summary_l1.csv`
- `missing_values_online_retail.csv`
- `missing_values_shipping.csv`
- `outliers_online_retail.csv`
- `outliers_shipping.csv`
- `quality_checks_online_retail.csv`
- `quality_checks_shipping.csv`
- `schema_online_retail.csv`
- `schema_shipping.csv`

## Contrôles réalisés

- Dimensions des datasets
- Types des colonnes
- Taux de nullité
- Doublons
- Statistiques descriptives
- Outliers avec la méthode IQR
- Contrôles spécifiques Online Retail
- Contrôles spécifiques Shipping

## Remarque

Ce livrable L1 sert à observer la qualité des données brutes.
Les décisions de nettoyage seront documentées dans le livrable L2 `DECISIONS.md` et appliquées dans le pipeline Bronze vers Silver.
