from pathlib import Path

import joblib
import pandas as pd
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report


TRAIN_FILE = Path("data/vehicle_train.csv")
TEST_FILE = Path("data/vehicle_test.csv")

MODEL_FILE = Path("models/vehicle_rf_4trees_depth3.joblib")
TREES_DIR = Path("trees/vehicle")
PREDICTIONS_FILE = Path("results/vehicle_reference_predictions.csv")
METRICS_FILE = Path("results/vehicle_python_metrics.txt")

NON_FEATURE_COLUMNS = {
    "sample_id",
    "class",
    "class_id",
}


def main() -> None:
    train_df = pd.read_csv(TRAIN_FILE)
    test_df = pd.read_csv(TEST_FILE)

    feature_columns = [
        column
        for column in train_df.columns
        if column not in NON_FEATURE_COLUMNS
    ]

    if len(feature_columns) != 18:
        raise ValueError(
            f"Esperadas 18 features, encontradas {len(feature_columns)}"
        )

    X_train = train_df[feature_columns]
    y_train = train_df["class_id"]

    X_test = test_df[feature_columns]
    y_test = test_df["class_id"]

    # Esta será a floresta oficial do experimento.
    model = RandomForestClassifier(
        n_estimators=4,
        max_depth=3,
        random_state=42,
        n_jobs=1,
    )

    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    MODEL_FILE.parent.mkdir(parents=True, exist_ok=True)
    TREES_DIR.mkdir(parents=True, exist_ok=True)
    PREDICTIONS_FILE.parent.mkdir(parents=True, exist_ok=True)

    package = {
        "model": model,
        "feature_columns": feature_columns,
        "class_to_id": {
            "van": 0,
            "saab": 1,
            "bus": 2,
            "opel": 3,
        },
        "id_to_class": {
            0: "van",
            1: "saab",
            2: "bus",
            3: "opel",
        },
        "n_estimators": 4,
        "max_depth": 3,
        "random_state": 42,
    }

    joblib.dump(package, MODEL_FILE)

    # Apaga somente arquivos DOT antigos, caso o script seja
    # executado novamente por acidente.
    for old_tree in TREES_DIR.glob("tree*.txt"):
        old_tree.unlink()

    for tree_index, estimator in enumerate(model.estimators_):
        output_file = TREES_DIR / f"tree{tree_index}.txt"

        # Não fornecemos feature_names aqui porque o parser do ROAR
        # espera comparações no formato x[0], x[1], ..., x[17].
        tree.export_graphviz(
            estimator,
            out_file=str(output_file),
        )

    output = test_df[
        ["sample_id", "class", "class_id"]
    ].copy()

    output["python_prediction"] = predictions
    output["correct"] = (
        output["class_id"] == output["python_prediction"]
    )

    output.to_csv(PREDICTIONS_FILE, index=False)

    report = classification_report(
        y_test,
        predictions,
        labels=[0, 1, 2, 3],
        target_names=["van", "saab", "bus", "opel"],
        digits=4,
        zero_division=0,
    )

    metrics_text = (
        f"Quantidade de features: {len(feature_columns)}\n"
        f"Quantidade de árvores: {model.n_estimators}\n"
        f"Profundidade máxima: {model.max_depth}\n"
        f"Random state: 42\n"
        f"Acurácia: {accuracy:.6f}\n\n"
        f"{report}\n"
    )

    METRICS_FILE.write_text(metrics_text, encoding="utf-8")

    print(metrics_text)
    print(f"Modelo oficial: {MODEL_FILE}")
    print(f"Árvores para o ROAR: {TREES_DIR}")
    print(f"Previsões de referência: {PREDICTIONS_FILE}")

    for tree_index, estimator in enumerate(model.estimators_):
        print(
            f"Árvore {tree_index}: "
            f"profundidade={estimator.tree_.max_depth}, "
            f"nós={estimator.tree_.node_count}, "
            f"folhas={estimator.tree_.n_leaves}"
        )


if __name__ == "__main__":
    main()