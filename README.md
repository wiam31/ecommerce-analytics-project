# E-Commerce Analytics Project

## Description

Ce projet a pour objectif d'explorer, nettoyer et préparer des données e-commerce afin de construire un pipeline analytique fiable et réutilisable.

Le travail est organisé selon une architecture Médaillon (Bronze → Silver → Gold) et s'appuie sur deux jeux de données complémentaires couvrant à la fois les transactions commerciales et les opérations logistiques.

Les principales étapes du projet sont :

* **L1 : Data Profiling** – Analyse de la qualité et de la structure des données ;
* **L2 : Data Cleaning** – Nettoyage, traitement des anomalies et préparation des données ;
* **L3 : Data Modeling** – Construction des tables analytiques ;
* **L4 : Analytics & Business Insights** – Production d'indicateurs et analyses métier.

---

## Datasets utilisés

### 1. Online Retail Dataset

**Fichier :** `data.csv`

Ce dataset contient les transactions d'une entreprise de vente en ligne :

* Numéros de facture
* Produits vendus
* Quantités
* Prix unitaires
* Dates de transaction
* Identifiants clients
* Pays

Ce jeu de données est utilisé pour les analyses de ventes, la segmentation RFM, le calcul de la Customer Lifetime Value (CLV) et l'étude du catalogue produits.

### 2. E-Commerce Shipping Dataset

**Fichier :** `Train.csv`

Ce dataset contient des informations logistiques et de satisfaction client :

* Coût des produits
* Remises appliquées
* Nombre d'achats précédents
* Évaluation client
* Mode d'expédition
* Respect des délais de livraison

Il est utilisé pour l'analyse de la performance logistique et des facteurs influençant la satisfaction client.

---

## Technologies utilisées

* Python 3.11
* Pandas
* NumPy
* Matplotlib
* Seaborn
* Plotly
* Jupyter Notebook
* ydata-profiling
* dbt
* Git

---

## L1 – Data Profiling

### Objectif

Comprendre la structure et la qualité des données avant toute transformation.

### Analyses réalisées

* Étude des dimensions des datasets
* Analyse des types de données
* Détection des valeurs manquantes
* Détection des doublons
* Analyse statistique descriptive
* Identification des valeurs aberrantes
* Analyse des distributions
* Génération de rapports automatiques avec ydata-profiling

### Livrables

* Rapports HTML de profiling
* Synthèses de qualité des données
* Statistiques descriptives
* Recommandations de nettoyage

---

## L2 – Data Cleaning

### Objectif

Transformer les données brutes en données cohérentes et exploitables tout en minimisant la perte d'information.

### Nettoyage du dataset Online Retail

Les opérations suivantes sont appliquées :

* Suppression des doublons ;
* Isolation des factures annulées (préfixe `C`) dans un fichier dédié ;
* Exclusion des codes spéciaux (`POST`, `D`, `C2`, `M`, `BANK CHARGES`, `AMAZONFEE`) ;
* Suppression des prix unitaires invalides ;
* Traitement des valeurs aberrantes par capping (méthode IQR) ;
* Conversion de `InvoiceDate` au format datetime ;
* Création de la variable `TotalRevenue`.

Trois fichiers Silver sont produits :

* `online_retail_full.csv`
* `online_retail_identified.csv`
* `online_retail_returns.csv`

### Nettoyage du dataset Shipping

Les opérations suivantes sont appliquées :

* Suppression des doublons ;
* Imputation des valeurs manquantes numériques par la médiane ;
* Imputation des valeurs manquantes catégorielles par le mode ;
* Traitement des valeurs aberrantes par capping ;
* Vérification de la cohérence des types de données.

Le fichier Silver produit est :

* `train_clean.csv`

---

## Documentation des décisions

L'ensemble des choix de nettoyage est documenté dans le fichier :

```text
DECISIONS.md
```

Ce document détaille :

* les règles de nettoyage appliquées ;
* les justifications métier ;
* les choix d'imputation ;
* le traitement des valeurs aberrantes ;
* les impacts sur la qualité des données ;
* les taux de perte observés.

---

## Architecture du projet

```text
data/
│
├── bronze/
│   ├── data.csv
│   └── Train.csv
│
├── silver/
│   ├── online_retail_full.csv
│   ├── online_retail_identified.csv
│   ├── online_retail_returns.csv
│   └── train_clean.csv
│
└── gold/
```

---

## Résultats

Après nettoyage :

| Dataset       | Fichier Silver               | Perte    |
| ------------- | ---------------------------- | -------- |
| Online Retail | online_retail_full.csv       | 3.44 %   |
| Online Retail | online_retail_identified.csv | 27.82 %* |
| Shipping      | train_clean.csv              | 0.00 %   |

* Cette perte est principalement liée à l'absence de `CustomerID` sur certaines transactions et est inévitable pour les analyses RFM et CLV.

---

## Installation et exécution

### Création de l'environnement virtuel

```bash
python -m venv venv
```

### Activation de l'environnement

Sous Windows :

```bash
venv\Scripts\activate
```

### Installation des dépendances

```bash
pip install -r requirements.txt
```

### Lancement de Jupyter Notebook

```bash
jupyter notebook
```

---

## Auteur

Projet réalisé dans le cadre du module E-Commerce Analytics, avec une approche orientée qualité des données, analyse métier et construction d'un pipeline analytique reproductible.
