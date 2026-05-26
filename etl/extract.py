import pandas as pd

def extract_data():
    data_df = pd.read_csv(
        "data/bronze/data.csv",
        encoding="latin1"
    )

    train_df = pd.read_csv(
        "data/bronze/Train.csv",
        encoding="latin1"
    )

    return data_df, train_df