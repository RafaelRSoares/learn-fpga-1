from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)


MODEL_FILE = Path(
    "models/vehicle_rf_4trees_depth3.joblib"
)
TEST_FILE = Path("data/vehicle_test.csv")

OUTPUT_FILE = Path(
    "results/vehicle_reference_predictions.csv"
)
METRICS_FILE = Path(
    "results/vehicle_hard_vote_metrics.txt"
)

NON_FEATURE_COLUMNS = {
    "sample_id",
    "class",
    "class_id",
}


def predict_hard_vote(model, features):
    tree_predictions = np.asarray(
        [
            estimator.predict(features).astype(np.int64)
            for estimator in model.estimators_
        ]
    )

    predictions = []

    for sample_index in range(tree_predictions.shape[1]):
        votes = np.bincount(
            tree_predictions[:, sample_index],
            minlength=4,
        )

        predictions.append(int(np.argmax(votes)))

    return np.asarray(predictions, dtype=np.int64)


def main() -> None:
    package = joblib.load(MODEL_FILE)
    model = package["model"]
    feature_columns = package["feature_columns"]

    test_df = pd.read_csv(TEST_FILE)

    X_test = test_df[feature_columns]
    y_test = test_df["class_id"].to_numpy()

    sklearn_predictions = model.predict(
        X_test
    ).astype(np.int64)

    hard_vote_predictions = predict_hard_vote(
        model,
        X_test,
    )

    sklearn_accuracy = accuracy_score(
        y_test,
        sklearn_predictions,
    )

    hard_vote_accuracy = accuracy_score(
        y_test,
        hard_vote_predictions,
    )

    output = test_df[
        ["sample_id", "class", "class_id"]
    ].copy()

    output["python_prediction"] = (
        hard_vote_predictions
    )

    output["sklearn_prediction"] = (
        sklearn_predictions
    )

    output["correct"] = (
        output["class_id"]
        == output["python_prediction"]
    )

    output.to_csv(
        OUTPUT_FILE,
        index=False,
    )

    report = classification_report(
        y_test,
        hard_vote_predictions,
        labels=[0, 1, 2, 3],
        target_names=[
            "van",
            "saab",
            "bus",
            "opel",
        ],
        digits=4,
        zero_division=0,
    )

    matrix = confusion_matrix(
        y_test,
        hard_vote_predictions,
        labels=[0, 1, 2, 3],
    )

    different = np.count_nonzero(
        sklearn_predictions
        != hard_vote_predictions
    )

    metrics = (
        f"Acurácia scikit-learn: "
        f"{sklearn_accuracy:.6f}\n"
        f"Acurácia votação ROAR: "
        f"{hard_vote_accuracy:.6f}\n"
        f"Diferenças entre regras: "
        f"{different}/{len(test_df)}\n\n"
        f"Relatório da votação ROAR:\n"
        f"{report}\n"
        f"Matriz de confusão:\n"
        f"{matrix}\n"
    )

    METRICS_FILE.write_text(
        metrics,
        encoding="utf-8",
    )

    print(metrics)
    print(f"Referência atualizada: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()