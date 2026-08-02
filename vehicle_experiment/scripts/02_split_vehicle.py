from pathlib import Path

import pandas as pd
from sklearn.model_selection import train_test_split


INPUT_FILE = Path("data/vehicle_clean.csv")
TRAIN_FILE = Path("data/vehicle_train.csv")
TEST_FILE = Path("data/vehicle_test.csv")

CLASS_TO_ID = {
    "van": 0,
    "saab": 1,
    "bus": 2,
    "opel": 3,
}


def main() -> None:
    df = pd.read_csv(INPUT_FILE)

    # Cria um identificador permanente antes da divisão.
    df.insert(0, "sample_id", range(len(df)))
    df["class_id"] = df["class"].map(CLASS_TO_ID)

    train_df, test_df = train_test_split(
        df,
        test_size=0.20,
        random_state=42,
        stratify=df["class_id"],
    )

    # Ordenação apenas para tornar os arquivos determinísticos e fáceis de comparar.
    train_df = train_df.sort_values("sample_id").reset_index(drop=True)
    test_df = test_df.sort_values("sample_id").reset_index(drop=True)

    train_df.to_csv(TRAIN_FILE, index=False)
    test_df.to_csv(TEST_FILE, index=False)

    print(f"Treino: {len(train_df)} amostras")
    print(f"Teste: {len(test_df)} amostras")

    print("\nClasses no treino:")
    print(train_df["class"].value_counts())

    print("\nClasses no teste:")
    print(test_df["class"].value_counts())


if __name__ == "__main__":
    main()