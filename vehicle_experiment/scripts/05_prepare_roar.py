from pathlib import Path
import shutil

import pandas as pd


TRAIN_FILE = Path("data/vehicle_train.csv")
TEST_FILE = Path("data/vehicle_test.csv")
SOURCE_TREES_DIR = Path("trees/vehicle")

# Como as pastas estão lado a lado, ".." volta para a pasta.
ROAR_DIR = Path("../ROAR-development")

ROAR_DATASET_FILE = ROAR_DIR / "datasets" / "vehicle.csv"
ROAR_TREES_DIR = ROAR_DIR / "trees" / "vehicle.csv"

NON_FEATURE_COLUMNS = {
    "sample_id",
    "class",
    "class_id",
}


def main() -> None:
    train_df = pd.read_csv(TRAIN_FILE)
    test_df = pd.read_csv(TEST_FILE)

    all_df = pd.concat(
        [train_df, test_df],
        ignore_index=True,
    )

    feature_columns = [
        column
        for column in all_df.columns
        if column not in NON_FEATURE_COLUMNS
    ]

    if len(feature_columns) != 18:
        raise ValueError(
            f"Esperadas 18 features, encontradas {len(feature_columns)}"
        )

    # Este arquivo é usado pelo ROAR para descobrir:
    # - quantidade de features;
    # - nomes das features;
    # - quantidade de classes.
    roar_dataset = all_df[feature_columns].copy()
    roar_dataset["label"] = all_df["class_id"].astype(int)

    ROAR_DATASET_FILE.parent.mkdir(parents=True, exist_ok=True)
    ROAR_TREES_DIR.mkdir(parents=True, exist_ok=True)

    roar_dataset.to_csv(
        ROAR_DATASET_FILE,
        index=False,
    )

    # Remove somente árvores anteriores desse dataset.
    for old_file in ROAR_TREES_DIR.glob("tree*.txt"):
        old_file.unlink()

    for tree_file in sorted(SOURCE_TREES_DIR.glob("tree*.txt")):
        destination = ROAR_TREES_DIR / tree_file.name
        shutil.copy2(tree_file, destination)
        print(f"Copiado: {tree_file} -> {destination}")

    copied_trees = list(ROAR_TREES_DIR.glob("tree*.txt"))

    if len(copied_trees) != 4:
        raise RuntimeError(
            f"Esperadas 4 árvores, copiadas {len(copied_trees)}"
        )

    print(f"\nDataset do ROAR: {ROAR_DATASET_FILE}")
    print(f"Árvores do ROAR: {ROAR_TREES_DIR}")


if __name__ == "__main__":
    main()