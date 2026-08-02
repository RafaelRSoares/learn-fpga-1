from pathlib import Path

import pandas as pd


INPUT_FILE = Path("data/vehicle_silhouettes.csv")
OUTPUT_FILE = Path("data/vehicle_clean.csv")
REMOVED_FILE = Path("data/vehicle_removed_rows.csv")

VALID_CLASSES = {"van", "saab", "bus", "opel"}


def main() -> None:
    df = pd.read_csv(INPUT_FILE)

    print(f"Linhas originais: {len(df)}")
    print(f"Colunas: {len(df.columns)}")
    print("\nClasses encontradas:")
    print(df["class"].value_counts(dropna=False))

    # Uma linha do arquivo possui COMPACTNESS ausente e "204"
    # aparecendo indevidamente como classe.
    invalid_class = ~df["class"].isin(VALID_CLASSES)
    missing_value = df.isna().any(axis=1)
    invalid_rows = invalid_class | missing_value

    removed = df.loc[invalid_rows].copy()
    clean = df.loc[~invalid_rows].copy()

    # Confirma que sobraram apenas as quatro classes esperadas.
    assert set(clean["class"].unique()) == VALID_CLASSES
    assert not clean.isna().any().any()
    assert len(clean.columns) == 19  # 18 features + classe

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    clean.to_csv(OUTPUT_FILE, index=False)
    removed.to_csv(REMOVED_FILE, index=False)

    print(f"\nLinhas válidas: {len(clean)}")
    print(f"Linhas removidas: {len(removed)}")
    print(f"Arquivo limpo: {OUTPUT_FILE}")
    print(f"Linhas removidas: {REMOVED_FILE}")

    print("\nDistribuição final:")
    print(clean["class"].value_counts())


if __name__ == "__main__":
    main()