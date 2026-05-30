# 📊 E-commerce Analytics Project 

## 📌 Description

Ce projet a pour objectif d’analyser et de nettoyer deux datasets e-commerce afin de produire des données propres et exploitables pour des analyses ou modèles futurs.

Le projet est structuré en deux étapes principales :

- **L1 : Data Profiling (analyse exploratoire de la qualité des données)**
- **L2 : Data Cleaning (nettoyage et prise de décisions)**

---

## 📊 Datasets utilisés

### 1. Online Retail Dataset
- Fichier : `data.csv`
- Contenu : transactions e-commerce (factures, produits, clients)

### 2. E-Commerce Shipping Dataset
- Fichier : `Train.csv`
- Contenu : données logistiques et satisfaction client

---

## ⚙️ Technologies utilisées

- Python 3.11
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Plotly
- Jupyter Notebook
- ydata-profiling

---

## 🔍 L1 — Data Profiling

Objectif : comprendre la qualité des données.

### Analyses réalisées :
- Dimensions des datasets
- Types des colonnes
- Valeurs manquantes
- Doublons
- Statistiques descriptives
- Détection d’outliers (IQR)
- Génération de rapports HTML avec ydata-profiling

### Livrables :
- Rapports HTML de profiling
- Tableaux récapitulatifs
- Fichiers d’analyse de qualité

---

## 🧹 L2 — Data Cleaning

Objectif : transformer les données brutes en données propres.

### Nettoyage Online Retail :
- Suppression des doublons
- Suppression des commandes annulées (InvoiceNo commençant par "C")
- Suppression des lignes avec Quantity ≤ 0
- Suppression des lignes avec UnitPrice ≤ 0
- Suppression des valeurs manquantes (CustomerID, Description)
- Conversion de InvoiceDate en format datetime

### Nettoyage Shipping Dataset :
- Suppression des doublons
- Imputation des valeurs manquantes :
  - Médiane pour variables numériques
  - Mode pour variables catégorielles
- Conversion des colonnes de type date

---

## 📄 DECISIONS.md

Toutes les décisions de nettoyage sont documentées dans `DECISIONS.md`, incluant :
- Les règles appliquées
- Les justifications métier
- Les choix d’imputation
- Les transformations effectuées

---

## 💾 Résultats finaux

Les datasets nettoyés sont stockés dans :

- `data/bronze/online_retail_clean.csv`
- `data/bronze/train_clean.csv`

---

## 🚀 Installation et exécution

### 1. Créer l’environnement virtuel
```bash
python -m venv venv
venv\Scripts\activate

pip install -r requirements.txt
jupyter notebook
