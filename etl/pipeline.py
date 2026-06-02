import logging
import os

from etl.extract import extract_data
from etl.transform import clean_online_retail, clean_shipping
from etl.load import save_data

os.makedirs("logs", exist_ok=True)
os.makedirs("data/silver", exist_ok=True)

logging.basicConfig(
    filename="logs/pipeline.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    encoding="utf-8"
)


def run_pipeline():

    logging.info("=" * 60)
    logging.info("Pipeline v2 démarré")
    logging.info("=" * 60)

    # ── EXTRACT ──────────────────────────────────────────────
    data_df, train_df = extract_data()

    # ── TRANSFORM ────────────────────────────────────────────

    # Online Retail → 3 fichiers Silver distincts
    online_identified, online_full, online_returns = clean_online_retail(data_df)

    # Shipping
    train_clean = clean_shipping(train_df)

    # ── LOAD ─────────────────────────────────────────────────

    # ST2 — RFM / CLV : transactions identifiées uniquement
    save_data(online_identified, "data/silver/online_retail_identified.csv")

    # ST3, ST4 — Catalogue / Marge : toutes transactions valides
    save_data(online_full, "data/silver/online_retail_full.csv")

    # ST4 — Retours / Annulations isolés
    save_data(online_returns, "data/silver/online_retail_returns.csv")

    # Shipping nettoyé
    save_data(train_clean, "data/silver/train_clean.csv")

    logging.info("Pipeline v2 terminé avec succès")
    logging.info("Fichiers Silver produits :")
    logging.info("  → online_retail_identified.csv  (ST2 RFM/CLV)")
    logging.info("  → online_retail_full.csv         (ST3 Catalogue, ST4 Marge)")
    logging.info("  → online_retail_returns.csv      (ST4 Retours)")
    logging.info("  → train_clean.csv                (ST1, ST2, ST4 Shipping)")


if __name__ == "__main__":
    run_pipeline()