# Décisions de Nettoyage des Données – Projet E-Commerce Analytics

## 1. Objectif

Ce document présente les choix de nettoyage et de préparation des données effectués dans le cadre du pipeline ETL du projet E-Commerce Analytics.

L'objectif est de transformer les données brutes en données fiables et exploitables tout en garantissant :

* la qualité des données ;
* la cohérence avec les règles métier ;
* la reproductibilité du pipeline ;
* le respect de la contrainte du cahier des charges imposant une perte de données inférieure à 5 % sur les principaux fichiers Silver.

---

## 2. Révision du pipeline : problèmes identifiés et corrections

### Limites de la première version

Dans la première version du pipeline, les valeurs aberrantes (outliers) étaient supprimées à l'aide de la méthode IQR.

Cette approche a entraîné une perte importante de données :

| Dataset       | Perte totale |
| ------------- | ------------ |
| Online Retail | 38,51 %      |
| Shipping      | 27,53 %      |

Ces résultats ne respectaient pas les exigences du cahier des charges.

### Analyse des pertes sur Online Retail

| Étape de nettoyage       | Lignes supprimées | Pourcentage |
| ------------------------ | ----------------- | ----------- |
| Doublons                 | 5 268             | 0,97 %      |
| Factures annulées        | 9 251             | 1,71 %      |
| CustomerID manquants     | 134 658           | 24,85 %     |
| Prix unitaires invalides | 40                | 0,01 %      |
| Outliers sur Quantity    | 25 616            | 4,73 %      |
| Outliers sur UnitPrice   | 33 842            | 6,24 %      |

### Analyse des pertes sur Shipping

| Étape de nettoyage            | Lignes supprimées | Pourcentage |
| ----------------------------- | ----------------- | ----------- |
| Outliers sur Prior_purchases  | 1 003             | 9,12 %      |
| Outliers sur Discount_offered | 2 025             | 18,41 %     |

---

## 3. Corrections apportées

### Remplacement de la suppression des outliers par le capping

Au lieu de supprimer les valeurs extrêmes, celles-ci sont désormais limitées aux bornes définies par la méthode IQR :

* borne inférieure : Q1 − 1,5 × IQR ;
* borne supérieure : Q3 + 1,5 × IQR.

Cette approche présente plusieurs avantages :

* conservation des transactions légitimes à fort volume ;
* réduction de l'influence statistique des valeurs extrêmes ;
* absence de perte de lignes ;
* limitation du biais sur les indicateurs commerciaux.

Par exemple, une commande importante ou un produit premium ne sont pas nécessairement des erreurs. Les supprimer conduirait à sous-estimer le chiffre d'affaires réel.

Grâce à cette modification :

| Dataset       | Perte liée aux outliers |
| ------------- | ----------------------- |
| Online Retail | 0 %                     |
| Shipping      | 0 %                     |

---

### Séparation des données selon les besoins métier

Le dataset Online Retail contient un nombre important de transactions sans identifiant client (`CustomerID`).

Ces transactions restent exploitables pour les analyses produits et financières, mais ne peuvent pas être utilisées pour des analyses centrées sur les clients telles que le RFM ou le CLV.

Pour cette raison, trois fichiers Silver distincts sont générés :

| Fichier                        | Contenu                         | Utilisation                      |
| ------------------------------ | ------------------------------- | -------------------------------- |
| `online_retail_full.csv`       | Toutes les transactions valides | Analyses produits et financières |
| `online_retail_identified.csv` | Transactions avec CustomerID    | RFM et CLV                       |
| `online_retail_returns.csv`    | Factures annulées               | Analyse des retours              |

Cette séparation permet de conserver l'ensemble des ventes utiles tout en produisant un jeu de données adapté aux analyses clients.

---

## 4. Justification de la perte observée sur `online_retail_identified.csv`

Le fichier destiné aux analyses RFM et CLV présente une perte totale de 27,82 %.

Cette perte est principalement due à l'absence d'identifiant client sur certaines transactions.

| Cause                            | Pourcentage |
| -------------------------------- | ----------- |
| CustomerID manquants             | 24,85 %     |
| Factures annulées                | 1,71 %      |
| Doublons                         | 0,97 %      |
| Codes spéciaux et prix invalides | 0,29 %      |

La majorité de cette perte est donc inévitable dans le cadre d'une analyse client.

Si l'on exclut les transactions anonymes, la perte réelle liée au nettoyage n'est que de 2,97 %, ce qui reste inférieur au seuil imposé par le cahier des charges.

Les transactions anonymes ne sont pas supprimées du projet ; elles sont conservées dans le fichier `online_retail_full.csv`.

---

## 5. Règles de nettoyage appliquées au dataset Online Retail

### Suppression des doublons

Les transactions strictement identiques sur l'ensemble des colonnes sont supprimées afin d'éviter les redondances.

### Isolation des factures annulées

Les factures dont le numéro commence par la lettre `C` correspondent à des annulations ou des retours.

Elles sont extraites dans un fichier dédié afin de ne pas fausser les analyses de ventes tout en restant disponibles pour l'étude des retours.

### Exclusion des codes spéciaux

Les codes suivants sont supprimés :

* POST
* D
* C2
* M
* BANK CHARGES
* AMAZONFEE

Ils correspondent à des frais ou ajustements comptables et non à des produits commercialisés.

### Suppression des prix invalides

Les lignes présentant un prix unitaire nul ou négatif sont supprimées car elles ne représentent pas des transactions commerciales valides.

### Traitement des valeurs aberrantes

Les variables `Quantity` et `UnitPrice` sont traitées par capping à l'aide de la méthode IQR.

### Création de nouvelles variables

Deux transformations sont réalisées :

* conversion de `InvoiceDate` au format datetime ;
* création de la variable :

```python
TotalRevenue = Quantity * UnitPrice
```

---

## 6. Règles de nettoyage appliquées au dataset Shipping

### Gestion des doublons

Aucun doublon significatif n'a été détecté dans ce jeu de données.

### Traitement des valeurs manquantes numériques

Les valeurs manquantes des variables numériques sont remplacées par la médiane de la colonne concernée.

Ce choix est robuste aux valeurs extrêmes.

### Traitement des valeurs manquantes catégorielles

Les valeurs manquantes des variables catégorielles sont remplacées par le mode, c'est-à-dire la valeur la plus fréquente.

### Traitement des valeurs aberrantes

Toutes les variables numériques sont traitées par capping selon la méthode IQR.

Cette stratégie permet de conserver l'intégralité des observations tout en limitant l'influence des valeurs extrêmes.

---

## 7. Résultats obtenus

| Dataset       | Fichier Silver                 | Lignes initiales | Lignes finales | Perte   |
| ------------- | ------------------------------ | ---------------- | -------------- | ------- |
| Online Retail | `online_retail_full.csv`       | 541 909          | 523 281        | 3,44 %  |
| Online Retail | `online_retail_identified.csv` | 541 909          | 391 169        | 27,82 % |
| Online Retail | `online_retail_returns.csv`    | —                | 9 251          | —       |
| Shipping      | `train_clean.csv`              | 10 999           | 10 999         | 0,00 %  |

Le seuil maximal de perte de 5 % est respecté pour les principaux fichiers Silver utilisés dans les analyses.

---

## 8. Architecture du pipeline ETL

Le projet suit une architecture de type Médaillon :

```text
Bronze → Silver → Gold
```

Les fichiers produits dans la couche Silver sont :

```text
data/silver/
├── online_retail_full.csv
├── online_retail_identified.csv
├── online_retail_returns.csv
└── train_clean.csv
```

Cette organisation garantit la traçabilité des transformations et facilite la réutilisation des données dans les différentes étapes analytiques.

---

## 9. Conclusion

La deuxième version du pipeline améliore significativement la qualité des données tout en respectant les contraintes du projet.

Les principales améliorations apportées sont :

1. Le remplacement de la suppression des outliers par une stratégie de capping.
2. La séparation des données selon les besoins métier afin de préserver les transactions anonymes lorsqu'elles restent exploitables.

Cette approche permet d'obtenir des jeux de données cohérents, documentés et adaptés aux différents cas d'usage du projet, notamment les analyses RFM, CLV, catalogue produit, rentabilité et gestion des retours.
