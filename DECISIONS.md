# 📊 DECISIONS DE NETTOYAGE — L2 E-COMMERCE ANALYTICS

## 1. Objectif

Ce document décrit les décisions prises lors du nettoyage des datasets afin de transformer les données brutes en données exploitables pour l’analyse et la modélisation.

---

## 2. Dataset Online Retail (data.csv)

### 🔴 Doublons supprimés
Les lignes dupliquées ont été supprimées car elles représentent des enregistrements redondants de transactions.

---

### 🔴 Valeurs manquantes
- `CustomerID` supprimé si manquant
- `Description` supprimé si manquant

👉 Justification :
Ces champs sont essentiels pour identifier le client et le produit.

---

### 🔴 Factures annulées
Les factures commençant par "C" ont été supprimées.

👉 Justification :
Elles représentent des transactions annulées et ne sont pas utiles pour l’analyse des ventes.

---

### 🔴 Quantités invalides
Les valeurs `Quantity <= 0` ont été supprimées.

👉 Justification :
Une quantité négative ou nulle n’a pas de sens métier.

---

### 🔴 Prix invalides
Les valeurs `UnitPrice <= 0` ont été supprimées.

👉 Justification :
Un produit ne peut pas avoir un prix nul ou négatif.

---

### 🔴 Dates invalides
Les dates incorrectes ont été supprimées après conversion.

---

## 3. Dataset E-Commerce Shipping (Train.csv)

### 🔴 Doublons supprimés
Les lignes identiques ont été supprimées pour éviter la redondance.

---

### 🔴 Valeurs manquantes
Les valeurs manquantes ont été traitées comme suit :

- Variables numériques → médiane
- Variables catégorielles → mode

👉 Justification :
- médiane → robuste aux outliers
- mode → valeur la plus fréquente

---

### 🔴 Conversion des dates
Toutes les colonnes contenant des dates ont été converties en format datetime.

---

## 4. Résultat global

- Données nettoyées et normalisées
- Réduction des incohérences
- Dataset prêt pour analyse et modélisation

---

## 5. Conclusion

Ces décisions permettent de garantir :
- une meilleure qualité des données
- une analyse plus fiable
- une base propre pour le pipeline data (Bronze → Silver → Gold)