import logging
import pandas as pd


def clean_dataframe(df):

    initial_rows = len(df)

    # =========================================================
    # 🔁 1. Suppression des doublons
    # =========================================================
    before = len(df)
    duplicates = df.duplicated().sum()

    df = df.drop_duplicates()

    after = len(df)

    logging.info(f"{duplicates} doublons supprimés (lignes avant={before}, après={after})")

    # =========================================================
    # 🔁 2. Valeurs manquantes (imputation médiane)
    # =========================================================
    numeric_cols = df.select_dtypes(include='number').columns

    for col in numeric_cols:

        missing = df[col].isnull().sum()

        if missing > 0:

            median = df[col].median()
            df[col] = df[col].fillna(median)

            logging.info(
                f"{missing} valeurs manquantes imputées (médiane) dans {col}"
            )

    # =========================================================
    # 🔁 3. Suppression des outliers (IQR)
    # =========================================================
    numeric_cols = df.select_dtypes(include='number').columns

    for col in numeric_cols:

        before = len(df)

        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1

        lower = Q1 - 1.5 * IQR
        upper = Q3 + 1.5 * IQR

        df = df[(df[col] >= lower) & (df[col] <= upper)]

        removed = before - len(df)

        if removed > 0:
            logging.info(
                f"{removed} outliers supprimés dans {col} (IQR)"
            )

    # =========================================================
    # 🔁 4. Perte totale
    # =========================================================
    final_rows = len(df)

    loss_percent = (initial_rows - final_rows) / initial_rows * 100

    logging.info(f"Perte totale du dataset : {loss_percent:.2f}%")

    return df