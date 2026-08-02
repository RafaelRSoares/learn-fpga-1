from pathlib import Path

import joblib
import numpy as np
import pandas as pd


MODEL_FILE = Path(
    "models/vehicle_rf_4trees_depth3.joblib"
)
TEST_FILE = Path(
    "data/vehicle_test.csv"
)
REFERENCE_FILE = Path(
    "results/vehicle_reference_predictions.csv"
)

OUTPUT_DIR = Path(
    "exports/cesar_vehicle"
)

TREE_HEX_FILE = OUTPUT_DIR / "vehicle_tree_memory.hex"
FEATURE_HEX_FILE = OUTPUT_DIR / "vehicle_features_x2.hex"
EXPECTED_HEX_FILE = OUTPUT_DIR / "vehicle_expected.hex"
NODES_HEADER_FILE = OUTPUT_DIR / "vehicle_forest_nodes.h"
TEST_HEADER_FILE = OUTPUT_DIR / "vehicle_test_vectors_x2.h"
REPORT_FILE = OUTPUT_DIR / "vehicle_export_report.txt"


TREE_COUNT = 4
TREE_DEPTH = 3
NODES_PER_TREE = 15
FEATURE_COUNT = 18
CLASS_COUNT = 4

MAX_FEATURE_ID = 31
MAX_THRESHOLD_X2 = 2047


def leaf_class(estimator, node_id: int) -> int:
    """Return the class predicted at a scikit-learn leaf."""

    values = estimator.tree_.value[node_id][0]
    class_position = int(np.argmax(values))

    class_id = int(
        estimator.classes_[class_position]
    )

    if not 0 <= class_id < CLASS_COUNT:
        raise ValueError(
            f"Classe inválida no nó {node_id}: {class_id}"
        )

    return class_id


def pack_node(
    feature_id: int,
    threshold_x2: int,
    class_id: int,
) -> int:
    """
    Pack one node using the adapted César format:

        [31:27] feature_id
        [26:16] threshold_x2
        [15:8]  class_id
        [7:0]   reserved
    """

    if not 0 <= feature_id <= MAX_FEATURE_ID:
        raise ValueError(
            f"Feature fora de 5 bits: {feature_id}"
        )

    if not 0 <= threshold_x2 <= MAX_THRESHOLD_X2:
        raise ValueError(
            "Threshold fora de 11 bits: "
            f"{threshold_x2}"
        )

    if not 0 <= class_id < CLASS_COUNT:
        raise ValueError(
            f"Classe inválida: {class_id}"
        )

    return (
        (feature_id << 27)
        | (threshold_x2 << 16)
        | (class_id << 8)
    )


def fill_leaf_subtree(
    memory: list[int],
    heap_position: int,
    class_id: int,
) -> None:
    """
    Fill a complete remaining subtree with the same class.

    The César accelerator always performs exactly three
    comparisons. When sklearn creates an early leaf, all
    descendant positions must therefore produce the same class.
    """

    if heap_position >= NODES_PER_TREE:
        return

    memory[heap_position] = pack_node(
        feature_id=0,
        threshold_x2=0,
        class_id=class_id,
    )

    fill_leaf_subtree(
        memory,
        heap_position * 2 + 1,
        class_id,
    )

    fill_leaf_subtree(
        memory,
        heap_position * 2 + 2,
        class_id,
    )


def export_sklearn_node(
    estimator,
    sklearn_node: int,
    heap_position: int,
    memory: list[int],
) -> None:
    """
    Convert sklearn's tree structure to the 15-position
    heap structure used by the César accelerator.
    """

    if heap_position >= NODES_PER_TREE:
        raise ValueError(
            "A árvore ultrapassou a profundidade suportada."
        )

    tree = estimator.tree_

    left_child = int(
        tree.children_left[sklearn_node]
    )
    right_child = int(
        tree.children_right[sklearn_node]
    )

    is_leaf = (
        left_child == right_child
        or left_child < 0
        or right_child < 0
    )

    if is_leaf:
        class_id = leaf_class(
            estimator,
            sklearn_node,
        )

        fill_leaf_subtree(
            memory,
            heap_position,
            class_id,
        )
        return

    feature_id = int(
        tree.feature[sklearn_node]
    )
    threshold = float(
        tree.threshold[sklearn_node]
    )

    if not 0 <= feature_id < FEATURE_COUNT:
        raise ValueError(
            f"Feature inválida: {feature_id}"
        )

    threshold_x2_float = threshold * 2.0
    threshold_x2 = int(
        round(threshold_x2_float)
    )

    if not np.isclose(
        threshold_x2_float,
        threshold_x2,
        atol=1e-5,
    ):
        raise ValueError(
            "Threshold não pode ser representado exatamente "
            f"com escala 2: {threshold}"
        )

    if not 0 <= threshold_x2 <= MAX_THRESHOLD_X2:
        raise ValueError(
            "Threshold não cabe no campo de 11 bits: "
            f"{threshold} -> {threshold_x2}"
        )

    # The class field is irrelevant for an internal node.
    memory[heap_position] = pack_node(
        feature_id=feature_id,
        threshold_x2=threshold_x2,
        class_id=0,
    )

    export_sklearn_node(
        estimator,
        left_child,
        heap_position * 2 + 1,
        memory,
    )

    export_sklearn_node(
        estimator,
        right_child,
        heap_position * 2 + 2,
        memory,
    )


def export_forest(model) -> list[int]:
    if len(model.estimators_) != TREE_COUNT:
        raise ValueError(
            f"Esperadas {TREE_COUNT} árvores, "
            f"encontradas {len(model.estimators_)}."
        )

    forest_memory: list[int] = []

    for tree_index, estimator in enumerate(
        model.estimators_
    ):
        if estimator.tree_.max_depth > TREE_DEPTH:
            raise ValueError(
                f"Árvore {tree_index} tem profundidade "
                f"{estimator.tree_.max_depth}."
            )

        tree_memory = [
            0 for _ in range(NODES_PER_TREE)
        ]

        export_sklearn_node(
            estimator=estimator,
            sklearn_node=0,
            heap_position=0,
            memory=tree_memory,
        )

        forest_memory.extend(tree_memory)

    expected_size = (
        TREE_COUNT * NODES_PER_TREE
    )

    if len(forest_memory) != expected_size:
        raise RuntimeError(
            f"Memória gerada com {len(forest_memory)} "
            f"palavras; esperado: {expected_size}."
        )

    return forest_memory


def decode_node(word: int) -> tuple[int, int, int]:
    feature_id = (word >> 27) & 0x1F
    threshold_x2 = (word >> 16) & 0x7FF
    class_id = (word >> 8) & 0xFF

    return (
        feature_id,
        threshold_x2,
        class_id,
    )


def simulate_tree(
    forest_memory: list[int],
    tree_index: int,
    features_x2: np.ndarray,
) -> int:
    node_position = 0
    tree_base = tree_index * NODES_PER_TREE

    for _ in range(TREE_DEPTH):
        word = forest_memory[
            tree_base + node_position
        ]

        feature_id, threshold_x2, _ = (
            decode_node(word)
        )

        feature_value_x2 = int(
            features_x2[feature_id]
        )

        if feature_value_x2 <= threshold_x2:
            node_position = (
                node_position * 2 + 1
            )
        else:
            node_position = (
                node_position * 2 + 2
            )

    leaf_word = forest_memory[
        tree_base + node_position
    ]

    _, _, class_id = decode_node(
        leaf_word
    )

    return class_id


def simulate_forest(
    forest_memory: list[int],
    features_x2: np.ndarray,
) -> int:
    tree_predictions = [
        simulate_tree(
            forest_memory,
            tree_index,
            features_x2,
        )
        for tree_index in range(TREE_COUNT)
    ]

    votes = np.bincount(
        tree_predictions,
        minlength=CLASS_COUNT,
    )

    # np.argmax preserves the lowest class in ties.
    return int(np.argmax(votes))


def write_tree_hex(
    forest_memory: list[int],
) -> None:
    TREE_HEX_FILE.write_text(
        "\n".join(
            f"{word:08X}"
            for word in forest_memory
        )
        + "\n",
        encoding="ascii",
    )


def write_feature_hex(
    features_x2: np.ndarray,
) -> None:
    lines = []

    for row in features_x2:
        for value in row:
            lines.append(
                f"{int(value) & 0xFFFFFFFF:08X}"
            )

    FEATURE_HEX_FILE.write_text(
        "\n".join(lines) + "\n",
        encoding="ascii",
    )


def write_expected_hex(
    predictions: np.ndarray,
) -> None:
    EXPECTED_HEX_FILE.write_text(
        "\n".join(
            f"{int(value):X}"
            for value in predictions
        )
        + "\n",
        encoding="ascii",
    )


def write_nodes_header(
    forest_memory: list[int],
) -> None:
    lines = [
        "#ifndef VEHICLE_FOREST_NODES_H",
        "#define VEHICLE_FOREST_NODES_H",
        "",
        "#include <stdint.h>",
        "",
        "#define VEHICLE_TREE_COUNT 4",
        "#define VEHICLE_NODES_PER_TREE 15",
        "#define VEHICLE_TOTAL_NODES 60",
        "",
        "static const uint32_t vehicle_forest_nodes"
        "[VEHICLE_TOTAL_NODES] = {",
    ]

    for index, word in enumerate(forest_memory):
        comma = "," if index < len(forest_memory) - 1 else ""

        lines.append(
            f"    0x{word:08X}u{comma}"
        )

    lines.extend(
        [
            "};",
            "",
            "#endif",
            "",
        ]
    )

    NODES_HEADER_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )


def write_test_header(
    features_x2: np.ndarray,
    expected: np.ndarray,
    labels: np.ndarray,
) -> None:
    sample_count = len(features_x2)

    lines = [
        "#ifndef VEHICLE_TEST_VECTORS_X2_H",
        "#define VEHICLE_TEST_VECTORS_X2_H",
        "",
        "#include <stdint.h>",
        "",
        "#define VEHICLE_FEATURE_COUNT 18",
        f"#define VEHICLE_TEST_COUNT {sample_count}",
        "",
        "static const uint16_t vehicle_test_features_x2"
        "[VEHICLE_TEST_COUNT][VEHICLE_FEATURE_COUNT] = {",
    ]

    for row in features_x2:
        values = ", ".join(
            str(int(value))
            for value in row
        )

        lines.append(f"    {{{values}}},")

    lines.extend(
        [
            "};",
            "",
            "static const uint8_t vehicle_expected_predictions"
            "[VEHICLE_TEST_COUNT] = {",
            "    "
            + ", ".join(
                str(int(value))
                for value in expected
            ),
            "};",
            "",
            "static const uint8_t vehicle_true_labels"
            "[VEHICLE_TEST_COUNT] = {",
            "    "
            + ", ".join(
                str(int(value))
                for value in labels
            ),
            "};",
            "",
            "#endif",
            "",
        ]
    )

    TEST_HEADER_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )


def main() -> None:
    package = joblib.load(MODEL_FILE)

    if not isinstance(package, dict):
        raise TypeError(
            "O arquivo joblib deveria conter um dicionário."
        )

    model = package["model"]
    feature_columns = list(
        package["feature_columns"]
    )

    if len(feature_columns) != FEATURE_COUNT:
        raise ValueError(
            f"Esperadas {FEATURE_COUNT} features, "
            f"encontradas {len(feature_columns)}."
        )

    test_df = pd.read_csv(TEST_FILE)
    reference_df = pd.read_csv(REFERENCE_FILE)

    if len(test_df) != len(reference_df):
        raise ValueError(
            "O conjunto de teste e a referência possuem "
            "tamanhos diferentes."
        )

    if not test_df["sample_id"].equals(
        reference_df["sample_id"]
    ):
        raise ValueError(
            "A ordem das amostras não coincide."
        )

    raw_features = test_df[
        feature_columns
    ].to_numpy(dtype=np.float64)

    rounded_features = np.rint(
        raw_features
    )

    if not np.allclose(
        raw_features,
        rounded_features,
        atol=1e-8,
    ):
        raise ValueError(
            "Foram encontradas features não inteiras."
        )

    integer_features = rounded_features.astype(
        np.int64
    )

    if np.any(integer_features < 0):
        raise ValueError(
            "Foram encontradas features negativas."
        )

    features_x2 = integer_features * 2

    if np.any(features_x2 > MAX_THRESHOLD_X2):
        maximum = int(features_x2.max())

        raise ValueError(
            "Uma feature multiplicada por 2 não cabe "
            f"em 11 bits. Maior valor: {maximum}"
        )

    reference_predictions = reference_df[
        "python_prediction"
    ].to_numpy(dtype=np.int64)

    true_labels = test_df[
        "class_id"
    ].to_numpy(dtype=np.int64)

    forest_memory = export_forest(model)

    packed_predictions = np.asarray(
        [
            simulate_forest(
                forest_memory,
                features_x2[sample_index],
            )
            for sample_index in range(
                len(features_x2)
            )
        ],
        dtype=np.int64,
    )

    equal_count = int(
        np.count_nonzero(
            packed_predictions
            == reference_predictions
        )
    )

    accuracy_count = int(
        np.count_nonzero(
            packed_predictions
            == true_labels
        )
    )

    sample_count = len(test_df)

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    write_tree_hex(forest_memory)
    write_feature_hex(features_x2)
    write_expected_hex(reference_predictions)
    write_nodes_header(forest_memory)

    write_test_header(
        features_x2,
        reference_predictions,
        true_labels,
    )

    report_lines = [
        "Exportação Vehicle para acelerador do César",
        "==========================================",
        "",
        f"Árvores: {len(model.estimators_)}",
        f"Features: {len(feature_columns)}",
        f"Amostras de teste: {sample_count}",
        f"Palavras da floresta: {len(forest_memory)}",
        "",
        "Profundidades: "
        + str(
            [
                estimator.tree_.max_depth
                for estimator in model.estimators_
            ]
        ),
        "Nós sklearn: "
        + str(
            [
                estimator.tree_.node_count
                for estimator in model.estimators_
            ]
        ),
        "",
        "Maior feature original: "
        f"{int(integer_features.max())}",
        "Maior feature x2: "
        f"{int(features_x2.max())}",
        "",
        "Equivalência memória César x Python: "
        f"{equal_count}/{sample_count}",
        "Acurácia do modelo empacotado: "
        f"{accuracy_count}/{sample_count} "
        f"= {100.0 * accuracy_count / sample_count:.2f}%",
        "",
    ]

    REPORT_FILE.write_text(
        "\n".join(report_lines),
        encoding="utf-8",
    )

    print("\n".join(report_lines))

    if equal_count != sample_count:
        mismatches = np.flatnonzero(
            packed_predictions
            != reference_predictions
        )

        print("Primeiras divergências:")

        for index in mismatches[:10]:
            print(
                f"  amostra {index}: "
                f"empacotado={packed_predictions[index]}, "
                f"referência={reference_predictions[index]}"
            )

        raise RuntimeError(
            "A memória exportada não é equivalente "
            "à referência Python."
        )

    print("Arquivos gerados:")
    print(f"  {TREE_HEX_FILE}")
    print(f"  {FEATURE_HEX_FILE}")
    print(f"  {EXPECTED_HEX_FILE}")
    print(f"  {NODES_HEADER_FILE}")
    print(f"  {TEST_HEADER_FILE}")
    print(f"  {REPORT_FILE}")


if __name__ == "__main__":
    main()