#include <stdint.h>
#include <stdio.h>

#include "../exports/vehicle_forest_model.h"
#include "../exports/vehicle_test_vectors.h"

int main(void) {
    uint32_t matches_python = 0;
    uint32_t correct_labels = 0;

    for (uint32_t sample = 0;
         sample < VEHICLE_TEST_COUNT;
         sample++) {

        uint8_t prediction = vehicle_rf_predict(
            vehicle_test_features[sample]
        );

        uint8_t expected_python =
            vehicle_python_predictions[sample];

        uint8_t expected_label =
            vehicle_test_labels[sample];

        if (prediction == expected_python) {
            matches_python++;
        }
        else {
            printf(
                "Divergencia na amostra %u: "
                "C=%u, Python=%u\n",
                sample,
                prediction,
                expected_python
            );
        }

        if (prediction == expected_label) {
            correct_labels++;
        }
    }

    printf(
        "\nEquivalencia C x Python: %u/%u\n",
        matches_python,
        VEHICLE_TEST_COUNT
    );

    printf(
        "Acuracia C: %u/%u = %.2f%%\n",
        correct_labels,
        VEHICLE_TEST_COUNT,
        100.0 * correct_labels / VEHICLE_TEST_COUNT
    );

    return matches_python == VEHICLE_TEST_COUNT
        ? 0
        : 1;
}