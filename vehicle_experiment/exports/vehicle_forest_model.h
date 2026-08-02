#ifndef VEHICLE_FOREST_MODEL_H
#define VEHICLE_FOREST_MODEL_H

#include <stdint.h>

#define VEHICLE_FEATURE_COUNT 18
#define VEHICLE_CLASS_COUNT 4
#define VEHICLE_TREE_COUNT 4

typedef struct {
    uint8_t is_leaf;
    int8_t feature_id;
    float threshold;
    int16_t left_child;
    int16_t right_child;
    uint8_t class_id;
} RFNode;

static const RFNode vehicle_tree_0[15] = {
    {0, 11, 382.0f, 1, 8, 0},
    {0, 5, 8.5f, 2, 5, 0},
    {0, 1, 41.5f, 3, 4, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 3, 129.0f, 6, 7, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {0, 5, 7.5f, 9, 12, 0},
    {0, 5, 6.5f, 10, 11, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 0, 103.5f, 13, 14, 0},
    {1, -1, 0.0f, -1, -1, 3},
    {1, -1, 0.0f, -1, -1, 1},
};

static const RFNode vehicle_tree_1[15] = {
    {0, 11, 384.5f, 1, 8, 0},
    {0, 0, 87.5f, 2, 5, 0},
    {0, 8, 18.5f, 3, 4, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 3, 165.5f, 6, 7, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 5, 7.5f, 9, 12, 0},
    {0, 4, 62.5f, 10, 11, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 0, 103.5f, 13, 14, 0},
    {1, -1, 0.0f, -1, -1, 3},
    {1, -1, 0.0f, -1, -1, 1},
};

static const RFNode vehicle_tree_2[15] = {
    {0, 3, 166.5f, 1, 8, 0},
    {0, 10, 165.5f, 2, 5, 0},
    {0, 0, 90.5f, 3, 4, 0},
    {1, -1, 0.0f, -1, -1, 3},
    {1, -1, 0.0f, -1, -1, 0},
    {0, 5, 8.5f, 6, 7, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 0},
    {0, 9, 172.5f, 9, 12, 0},
    {0, 2, 77.5f, 10, 11, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 1},
    {0, 17, 188.0f, 13, 14, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 3},
};

static const RFNode vehicle_tree_3[13] = {
    {0, 8, 18.5f, 1, 6, 0},
    {0, 0, 81.5f, 2, 3, 0},
    {1, -1, 0.0f, -1, -1, 3},
    {0, 15, 19.5f, 4, 5, 0},
    {1, -1, 0.0f, -1, -1, 0},
    {1, -1, 0.0f, -1, -1, 1},
    {0, 17, 190.5f, 7, 10, 0},
    {0, 1, 41.5f, 8, 9, 0},
    {1, -1, 0.0f, -1, -1, 1},
    {1, -1, 0.0f, -1, -1, 2},
    {0, 5, 7.5f, 11, 12, 0},
    {1, -1, 0.0f, -1, -1, 2},
    {1, -1, 0.0f, -1, -1, 3},
};

static const RFNode *const vehicle_forest[VEHICLE_TREE_COUNT] = {
    vehicle_tree_0,
    vehicle_tree_1,
    vehicle_tree_2,
    vehicle_tree_3,
};

static inline uint8_t vehicle_evaluate_tree(
    const RFNode *tree,
    const float features[VEHICLE_FEATURE_COUNT]
) {
    int16_t node_id = 0;

    while (!tree[node_id].is_leaf) {
        const RFNode *node = &tree[node_id];

        if (features[node->feature_id] <= node->threshold) {
            node_id = node->left_child;
        }
        else {
            node_id = node->right_child;
        }
    }

    return tree[node_id].class_id;
}

static inline uint8_t vehicle_rf_predict(
    const float features[VEHICLE_FEATURE_COUNT]
) {
    uint8_t votes[VEHICLE_CLASS_COUNT] = {0, 0, 0, 0};

    for (uint8_t tree_id = 0;
         tree_id < VEHICLE_TREE_COUNT;
         tree_id++) {

        uint8_t prediction = vehicle_evaluate_tree(
            vehicle_forest[tree_id],
            features
        );

        votes[prediction]++;
    }

    /*
     * Usamos somente >, e não >=.
     * Assim, em empate, permanece a classe de menor
     * índice, como na votação utilizada no Verilog.
     */
    uint8_t winner = 0;

    for (uint8_t class_id = 1;
         class_id < VEHICLE_CLASS_COUNT;
         class_id++) {

        if (votes[class_id] > votes[winner]) {
            winner = class_id;
        }
    }

    return winner;
}

#endif
