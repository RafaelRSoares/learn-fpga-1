from pathlib import Path

import joblib
import numpy as np


MODEL_FILE = Path("models/vehicle_rf_4trees_depth3.joblib")
OUTPUT_FILE = Path("exports/vehicle_forest_model.h")


def format_float32(value: float) -> str:

    value32 = np.float32(value)
    text = f"{value32:.9g}"

    if "." not in text and "e" not in text.lower():
        text += ".0"

    return text + "f"


def export_tree(estimator, tree_index: int) -> str:
    tree = estimator.tree_

    lines = [
        f"static const RFNode vehicle_tree_{tree_index}"
        f"[{tree.node_count}] = {{"
    ]

    for node_id in range(tree.node_count):
        left = int(tree.children_left[node_id])
        right = int(tree.children_right[node_id])

        is_leaf = left == right

        if is_leaf:
            class_values = tree.value[node_id][0]
            class_id = int(np.argmax(class_values))

            feature_id = -1
            threshold = "0.0f"
            left_child = -1
            right_child = -1
        else:
            class_id = 0
            feature_id = int(tree.feature[node_id])

            # O ROAR normal usa ponto flutuante IEEE 754 de 32 bits.
            threshold = format_float32(tree.threshold[node_id])

            left_child = left
            right_child = right

        lines.append(
            "    {"
            f"{1 if is_leaf else 0}, "
            f"{feature_id}, "
            f"{threshold}, "
            f"{left_child}, "
            f"{right_child}, "
            f"{class_id}"
            "},"
        )

    lines.append("};")
    return "\n".join(lines)


def main() -> None:
    package = joblib.load(MODEL_FILE)

    model = package["model"]
    feature_columns = package["feature_columns"]

    if len(feature_columns) != 18:
        raise ValueError(
            f"Esperadas 18 features, encontradas {len(feature_columns)}"
        )

    if len(model.estimators_) != 4:
        raise ValueError(
            f"Esperadas 4 árvores, encontradas "
            f"{len(model.estimators_)}"
        )

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    sections = [
        "#ifndef VEHICLE_FOREST_MODEL_H",
        "#define VEHICLE_FOREST_MODEL_H",
        "",
        "#include <stdint.h>",
        "",
        "#define VEHICLE_FEATURE_COUNT 18",
        "#define VEHICLE_CLASS_COUNT 4",
        "#define VEHICLE_TREE_COUNT 4",
        "",
        "typedef struct {",
        "    uint8_t is_leaf;",
        "    int8_t feature_id;",
        "    float threshold;",
        "    int16_t left_child;",
        "    int16_t right_child;",
        "    uint8_t class_id;",
        "} RFNode;",
        "",
    ]

    for tree_index, estimator in enumerate(model.estimators_):
        sections.append(export_tree(estimator, tree_index))
        sections.append("")

    sections.extend(
        [
            "static const RFNode *const vehicle_forest"
            "[VEHICLE_TREE_COUNT] = {",
            "    vehicle_tree_0,",
            "    vehicle_tree_1,",
            "    vehicle_tree_2,",
            "    vehicle_tree_3,",
            "};",
            "",
            "static inline uint8_t vehicle_evaluate_tree(",
            "    const RFNode *tree,",
            "    const float features[VEHICLE_FEATURE_COUNT]",
            ") {",
            "    int16_t node_id = 0;",
            "",
            "    while (!tree[node_id].is_leaf) {",
            "        const RFNode *node = &tree[node_id];",
            "",
            "        if (features[node->feature_id] "
            "<= node->threshold) {",
            "            node_id = node->left_child;",
            "        }",
            "        else {",
            "            node_id = node->right_child;",
            "        }",
            "    }",
            "",
            "    return tree[node_id].class_id;",
            "}",
            "",
            "static inline uint8_t vehicle_rf_predict(",
            "    const float features[VEHICLE_FEATURE_COUNT]",
            ") {",
            "    uint8_t votes[VEHICLE_CLASS_COUNT] = "
            "{0, 0, 0, 0};",
            "",
            "    for (uint8_t tree_id = 0;",
            "         tree_id < VEHICLE_TREE_COUNT;",
            "         tree_id++) {",
            "",
            "        uint8_t prediction = vehicle_evaluate_tree(",
            "            vehicle_forest[tree_id],",
            "            features",
            "        );",
            "",
            "        votes[prediction]++;",
            "    }",
            "",
            "    /*",
            "     * Usamos somente >, e não >=.",
            "     * Assim, em empate, permanece a classe de menor",
            "     * índice, como na votação utilizada no Verilog.",
            "     */",
            "    uint8_t winner = 0;",
            "",
            "    for (uint8_t class_id = 1;",
            "         class_id < VEHICLE_CLASS_COUNT;",
            "         class_id++) {",
            "",
            "        if (votes[class_id] > votes[winner]) {",
            "            winner = class_id;",
            "        }",
            "    }",
            "",
            "    return winner;",
            "}",
            "",
            "#endif",
            "",
        ]
    )

    OUTPUT_FILE.write_text(
        "\n".join(sections),
        encoding="utf-8",
    )

    print(f"Header gerado em: {OUTPUT_FILE}")
    print(f"Features: {len(feature_columns)}")
    print(f"Árvores: {len(model.estimators_)}")

    for tree_index, estimator in enumerate(model.estimators_):
        print(
            f"Árvore {tree_index}: "
            f"nós={estimator.tree_.node_count}, "
            f"profundidade={estimator.tree_.max_depth}"
        )


if __name__ == "__main__":
    main()