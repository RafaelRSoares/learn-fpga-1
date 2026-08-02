from pathlib import Path

import pandas as pd


TEST_FILE = Path("data/vehicle_test.csv")
PREDICTIONS_FILE = Path(
    "results/vehicle_reference_predictions.csv"
)
OUTPUT_FILE = Path("exports/vehicle_test_vectors.h")

NON_FEATURE_COLUMNS = {
    "sample_id",
    "class",
    "class_id",
}


def main() -> None:
    test_df = pd.read_csv(TEST_FILE)
    predictions_df = pd.read_csv(PREDICTIONS_FILE)

    if len(test_df) != len(predictions_df):
        raise ValueError(
            "Quantidade de previsões diferente do conjunto de teste."
        )

    if not test_df["sample_id"].equals(
        predictions_df["sample_id"]
    ):
        raise ValueError(
            "A ordem das amostras não coincide."
        )

    feature_columns = [
        column
        for column in test_df.columns
        if column not in NON_FEATURE_COLUMNS
    ]

    if len(feature_columns) != 18:
        raise ValueError(
            f"Esperadas 18 features, encontradas {len(feature_columns)}"
        )

    lines = [
        "#ifndef VEHICLE_TEST_VECTORS_H",
        "#define VEHICLE_TEST_VECTORS_H",
        "",
        "#include <stdint.h>",
        "",
        f"#define VEHICLE_TEST_COUNT {len(test_df)}",
        "",
        "static const float vehicle_test_features"
        "[VEHICLE_TEST_COUNT][VEHICLE_FEATURE_COUNT] = {",
    ]

    for _, row in test_df.iterrows():
        values = ", ".join(
            f"{float(row[column]):.1f}f"
            for column in feature_columns
        )

        lines.append(f"    {{{values}}},")

    lines.extend(
        [
            "};",
            "",
            "static const uint8_t vehicle_test_labels"
            "[VEHICLE_TEST_COUNT] = {",
        ]
    )

    labels = ", ".join(
        str(int(value))
        for value in test_df["class_id"]
    )

    lines.append(f"    {labels}")
    lines.append("};")

    lines.extend(
        [
            "",
            "static const uint8_t vehicle_python_predictions"
            "[VEHICLE_TEST_COUNT] = {",
        ]
    )

    predictions = ", ".join(
        str(int(value))
        for value
        in predictions_df["python_prediction"]
    )

    lines.append(f"    {predictions}")
    lines.append("};")

    lines.extend(
        [
            "",
            "#endif",
            "",
        ]
    )

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    OUTPUT_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )

    print(f"Arquivo gerado: {OUTPUT_FILE}")
    print(f"Amostras: {len(test_df)}")
    print(f"Features: {len(feature_columns)}")


if __name__ == "__main__":
    main()