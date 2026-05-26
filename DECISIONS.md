# 📊 DECISIONS DE NETTOYAGE — L2 E-COMMERCE ANALYTICS

## 1. Objectif

Ce document décrit les décisions prises pour transformer les données brutes en données propres et exploitables dans un pipeline ETL (Bronze → Silver → Gold).

L’objectif est d’assurer :
- la qualité des données
- la cohérence métier
- la reproductibilité du pipeline

---

## 2. Dataset Online Retail (data.csv)

### 🔴 Doublons supprimés
- Des lignes dupliquées ont été supprimées
- Elles représentaient des transactions redondantes

👉 Impact : réduction du bruit dans les analyses de ventes

---

### 🔴 Valeurs manquantes
- `CustomerID` : suppression des lignes manquantes
- `Description` : suppression des lignes manquantes

👉 Justification :
Ces champs sont essentiels pour identifier le client et le produit.

---

### 🔴 Factures annulées
- Suppression des factures commençant par `C`

👉 Justification :
Ces transactions représentent des retours ou annulations et faussent l’analyse des ventes.

---

### 🔴 Quantités invalides
- Suppression des valeurs `Quantity <= 0`

👉 Justification :
Une quantité nulle ou négative n’a pas de sens métier.

---

### 🔴 Prix invalides
- Suppression des valeurs `UnitPrice <= 0`

👉 Justification :
Un produit ne peut pas avoir un prix nul ou négatif.

---

### 🔴 Outliers (Quantité & Prix)
- Détection et suppression des valeurs extrêmes (méthode IQR)

👉 Impact :
Réduction des biais sur les analyses de chiffre d’affaires

---

## 3. Dataset E-Commerce Shipping (Train.csv)

### 🔴 Doublons supprimés
- Suppression des lignes identiques

---

### 🔴 Valeurs manquantes
- Variables numériques → imputation par la médiane
- Variables catégorielles → imputation par le mode

👉 Justification :
- la médiane est robuste aux outliers
- le mode conserve la valeur la plus fréquente

---

### 🔴 Outliers
- Suppression des outliers dans :
  - `Prior_purchases`
  - `Discount_offered`

👉 Impact :
Amélioration de la stabilité des modèles prédictifs

---

### 🔴 Conversion des dates
- Conversion en format `datetime`

👉 Objectif :
Uniformisation et préparation pour feature engineering

---

## 4. Impact global du nettoyage

### 📉 Perte de données
- Dataset Online Retail : ~17.74%
- Dataset Shipping : ~27.53%

👉 Cette perte est volontaire et contrôlée afin de garantir la qualité des données finales.

---

## 5. Pipeline ETL

Le pipeline suit une architecture structurée :

- **Bronze** : données brutes
- **Silver** : données nettoyées
- **Gold** : données prêtes pour analyse et modélisation

✔ Propriétés du pipeline :
- idempotent
- reproductible
- logué

---

## 6. Conclusion

Ces décisions permettent de garantir :
- une meilleure qualité des données
- une réduction des biais statistiques
- un dataset fiable pour l’analyse et le machine learning
- un pipeline industriel propre et reproductible