from pathlib import Path
import struct

import pandas as pd


TEST_FILE = Path("data/vehicle_test.csv")
PREDICTIONS_FILE = Path(
    "results/vehicle_reference_predictions.csv"
)

OUTPUT_FEATURES = Path(
    "exports/verilog/vehicle_features.hex"
)
OUTPUT_EXPECTED = Path(
    "exports/verilog/vehicle_expected.hex"
)
OUTPUT_SAMPLE_IDS = Path(
    "exports/verilog/vehicle_sample_ids.txt"
)

NON_FEATURE_COLUMNS = {
    "sample_id",
    "class",
    "class_id",
}


def float_to_hex(value: float) -> str:
    """
    Converte um float Python para IEEE 754 de 32 bits,
    no mesmo formato usado pelas entradas do Verilog.
    """
    packed = struct.pack(">f", float(value))
    integer = struct.unpack(">I", packed)[0]
    return f"{integer:08x}"


def main() -> None:
    test_df = pd.read_csv(TEST_FILE)
    predictions_df = pd.read_csv(PREDICTIONS_FILE)

    if len(test_df) != len(predictions_df):
        raise ValueError(
            "Teste e previsões têm quantidades diferentes."
        )

    if not test_df["sample_id"].equals(
        predictions_df["sample_id"]
    ):
        raise ValueError(
            "A ordem dos sample_id não coincide."
        )

    feature_columns = [
        column
        for column in test_df.columns
        if column not in NON_FEATURE_COLUMNS
    ]

    if len(feature_columns) != 18:
        raise ValueError(
            f"Esperadas 18 features, encontradas "
            f"{len(feature_columns)}"
        )

    OUTPUT_FEATURES.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    feature_lines = []

    for _, row in test_df.iterrows():
        for column in feature_columns:
            feature_lines.append(
                float_to_hex(row[column])
            )

    expected_lines = [
        f"{int(value):x}"
        for value
        in predictions_df["python_prediction"]
    ]

    sample_id_lines = [
        str(int(value))
        for value in test_df["sample_id"]
    ]

    OUTPUT_FEATURES.write_text(
        "\n".join(feature_lines) + "\n",
        encoding="utf-8",
    )

    OUTPUT_EXPECTED.write_text(
        "\n".join(expected_lines) + "\n",
        encoding="utf-8",
    )

    OUTPUT_SAMPLE_IDS.write_text(
        "\n".join(sample_id_lines) + "\n",
        encoding="utf-8",
    )

    print(f"Amostras: {len(test_df)}")
    print(f"Features por amostra: {len(feature_columns)}")
    print(
        f"Palavras de feature: {len(feature_lines)}"
    )
    print(f"Features: {OUTPUT_FEATURES}")
    print(f"Esperados: {OUTPUT_EXPECTED}")
    print(f"IDs: {OUTPUT_SAMPLE_IDS}")


if __name__ == "__main__":
    main()