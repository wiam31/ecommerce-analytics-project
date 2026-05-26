import logging

from etl.extract import extract_data
from etl.transform import clean_dataframe
from etl.load import save_data

logging.basicConfig(
    filename="logs/pipeline.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    encoding="utf-8"
)

def run_pipeline():

    logging.info("Pipeline démarré")

    data_df, train_df = extract_data()

    data_clean = clean_dataframe(data_df)
    train_clean = clean_dataframe(train_df)

    save_data(
        data_clean,
        "data/silver/data_cleaned.csv"
    )

    save_data(
        train_clean,
        "data/silver/train_cleaned.csv"
    )

    logging.info("Pipeline terminé")

if __name__ == "__main__":
    run_pipeline()