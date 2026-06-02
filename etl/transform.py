import logging
import pandas as pd


# =========================================================
# STRATÉGIE DE NETTOYAGE — DÉCISION DOCUMENTÉE
#
# Problème initial : suppression des outliers par IQR
# entraînait 38.51% de perte sur Online Retail et 27.53%
# sur Shipping, bien au-delà du seuil < 5% du CDC.
#
# Corrections apportées (v2) :
#
# 1. OUTLIERS → CAPPING au lieu de suppression
#    Raisonnement : les valeurs extrêmes sont réelles
#    (ex. commande professionnelle de 10 000 unités).
#    Les supprimer introduit un biais sur le CA total.
#    On les plafonne à Q3 + 1.5*IQR pour conserver
#    la ligne tout en limitant l'influence sur les stats.
#    Impact : perte outliers réduite de ~11% → 0%.
#
# 2. CustomerID NULS → fichier séparé (anonymes)
#    Raisonnement : 24.85% des transactions Online Retail
#    n'ont pas de CustomerID. Ces lignes sont inutilisables
#    pour RFM/CLV (ST2) mais parfaitement valides pour
#    l'analyse catalogue (ST3) et marge (ST4).
#    On produit deux fichiers Silver distincts :
#      - online_retail_identified.csv  → RFM/CLV (ST2)
#      - online_retail_full.csv        → ST3, ST4 (toutes lignes)
#    Impact : perte Online Retail identifié passe de
#    38.51% → 27.54% (pertes légitimes uniquement :
#    doublons, annulations, prix invalides).
#    Pour le pipeline principal (full), perte < 5%.
# =========================================================


def cap_outliers(df, col):
    """
    Plafonne les valeurs extrêmes d'une colonne numérique
    à Q1 - 1.5*IQR et Q3 + 1.5*IQR.
    Ne supprime aucune ligne.
    """
    Q1 = df[col].quantile(0.25)
    Q3 = df[col].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - 1.5 * IQR
    upper = Q3 + 1.5 * IQR

    n_capped = ((df[col] < lower) | (df[col] > upper)).sum()

    if n_capped > 0:
        logging.info(
            f"{n_capped} valeurs cappées dans '{col}' "
            f"[{lower:.2f} – {upper:.2f}] (IQR)"
        )

    df[col] = df[col].clip(lower, upper)
    return df


def clean_online_retail(df):
    """
    Nettoyage spécifique Online Retail (data.csv).
    Retourne deux DataFrames :
      - df_identified : lignes avec CustomerID (pour RFM/CLV)
      - df_full       : toutes lignes valides (pour ST3, ST4)
    """
    initial_rows = len(df)
    logging.info(f"[Online Retail] Départ : {initial_rows:,} lignes")

    # 1. Doublons
    before = len(df)
    df = df.drop_duplicates()
    logging.info(
        f"[Online Retail] Doublons supprimés : "
        f"{before - len(df):,} ({(before - len(df))/initial_rows*100:.2f}%)"
    )

    # 2. Factures annulées (retours — préfixe 'C')
    #    Conservées dans un fichier retours séparé (ST4)
    returns_mask = df["InvoiceNo"].astype(str).str.startswith("C")
    df_returns = df[returns_mask].copy()
    df = df[~returns_mask]
    logging.info(
        f"[Online Retail] Factures annulées isolées : "
        f"{len(df_returns):,} ({len(df_returns)/initial_rows*100:.2f}%)"
    )

    # 3. Codes produits spéciaux à exclure (CDC §2.1)
    special_codes = ["POST", "D", "C2", "M", "BANK CHARGES", "AMAZONFEE"]
    before = len(df)
    df = df[~df["StockCode"].astype(str).isin(special_codes)]
    logging.info(
        f"[Online Retail] Codes spéciaux exclus : "
        f"{before - len(df):,}"
    )

    # 4. UnitPrice invalide
    before = len(df)
    df = df[df["UnitPrice"] > 0]
    logging.info(
        f"[Online Retail] UnitPrice <= 0 supprimés : "
        f"{before - len(df):,}"
    )

    # 5. Capping outliers (au lieu de suppression)
    df = cap_outliers(df, "Quantity")
    df = cap_outliers(df, "UnitPrice")

    # 6. Feature engineering de base
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
    df["TotalRevenue"] = df["Quantity"] * df["UnitPrice"]

    # 7. df_full = toutes lignes valides (ST3, ST4)
    df_full = df.copy()
    loss_full = (initial_rows - len(df_full)) / initial_rows * 100
    logging.info(
        f"[Online Retail FULL] Lignes finales : {len(df_full):,} "
        f"— Perte : {loss_full:.2f}%"
    )

    # 8. df_identified = lignes avec CustomerID (ST2 RFM/CLV)
    df_identified = df.dropna(subset=["CustomerID"]).copy()
    df_identified["CustomerID"] = df_identified["CustomerID"].astype(int)
    loss_id = (initial_rows - len(df_identified)) / initial_rows * 100
    logging.info(
        f"[Online Retail IDENTIFIED] Lignes finales : {len(df_identified):,} "
        f"— Perte : {loss_id:.2f}% "
        f"(dont 24.85% de transactions anonymes, inévitable pour RFM)"
    )

    return df_identified, df_full, df_returns


def clean_shipping(df):
    """
    Nettoyage spécifique E-Commerce Shipping (Train.csv).
    Capping outliers au lieu de suppression.
    """
    initial_rows = len(df)
    logging.info(f"[Shipping] Départ : {initial_rows:,} lignes")

    # 1. Doublons
    before = len(df)
    df = df.drop_duplicates()
    logging.info(
        f"[Shipping] Doublons supprimés : {before - len(df):,}"
    )

    # 2. Valeurs manquantes numériques → médiane
    numeric_cols = df.select_dtypes(include="number").columns
    for col in numeric_cols:
        missing = df[col].isnull().sum()
        if missing > 0:
            median = df[col].median()
            df[col] = df[col].fillna(median)
            logging.info(
                f"[Shipping] {missing} nulls imputés (médiane={median:.2f}) dans '{col}'"
            )

    # 3. Valeurs manquantes catégorielles → mode
    cat_cols = df.select_dtypes(include="object").columns
    for col in cat_cols:
        missing = df[col].isnull().sum()
        if missing > 0:
            mode = df[col].mode()[0]
            df[col] = df[col].fillna(mode)
            logging.info(
                f"[Shipping] {missing} nulls imputés (mode='{mode}') dans '{col}'"
            )

    # 4. Capping outliers (au lieu de suppression)
    #    Prior_purchases et Discount_offered étaient les seules
    #    colonnes avec des outliers significatifs dans le pipeline v1
    for col in numeric_cols:
        df = cap_outliers(df, col)

    final_rows = len(df)
    loss = (initial_rows - final_rows) / initial_rows * 100
    logging.info(
        f"[Shipping] Lignes finales : {final_rows:,} — Perte : {loss:.2f}%"
    )

    return df


# Fonction générique conservée pour compatibilité
def clean_dataframe(df):
    """
    Nettoyage générique (capping, doublons, imputation médiane).
    Utiliser clean_online_retail() et clean_shipping() en priorité.
    """
    initial_rows = len(df)

    before = len(df)
    df = df.drop_duplicates()
    logging.info(f"{before - len(df)} doublons supprimés")

    numeric_cols = df.select_dtypes(include="number").columns
    for col in numeric_cols:
        missing = df[col].isnull().sum()
        if missing > 0:
            df[col] = df[col].fillna(df[col].median())
            logging.info(f"{missing} nulls imputés (médiane) dans {col}")

    for col in numeric_cols:
        df = cap_outliers(df, col)

    loss = (initial_rows - len(df)) / initial_rows * 100
    logging.info(f"Perte totale : {loss:.2f}%")

    return df