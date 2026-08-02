#include <femtorv32.h>
#include <stdint.h>

#include "vehicle_forest_nodes.h"
#include "vehicle_test_vectors_x2.h"


#define IO_DBG_ADDR IO_BIT_TO_OFFSET(14)
#define IO_DBG_DATA IO_BIT_TO_OFFSET(15)

#define DBG_REG_SAMPLE   0u
#define DBG_REG_EXPECTED 1u
#define DBG_REG_PRED     2u
#define DBG_REG_CYCLES   3u
#define DBG_REG_CORRECT  4u

static uint32_t rf_custom_result(void) {
    uint32_t result;

    asm volatile(
        ".word 0x0000050b\n"
        "mv %0, a0\n"
        : "=r"(result)
        :
        : "a0", "memory"
    );

    return result;
}


/*
 * Retorna o sinal ready do acelerador.
 *
 * CUSTOM-0:
 *   funct3 = 001
 *   rd     = a0
 */
static uint32_t rf_custom_status(void) {
    uint32_t status;

    asm volatile(
        ".word 0x0000150b\n"
        "mv %0, a0\n"
        : "=r"(status)
        :
        : "a0", "memory"
    );

    return status;
}


/*
 * Inicia uma inferência.
 *
 * CUSTOM-0:
 *   funct3 = 010
 */
static void rf_custom_start(void) {
    asm volatile(
        ".word 0x0000200b\n"
        :
        :
        : "memory"
    );
}


/*
 * Escreve uma feature no banco indexado do acelerador.
 *
 * CUSTOM-0:
 *   funct3 = 011
 *   rs1/a0 = índice da feature, de 0 a 17
 *   rs2/a1 = valor da feature multiplicado por 2
 *
 * Palavra RISC-V:
 *   0x00B5300B
 */
static void rf_custom_feature_write(
    uint32_t feature_index,
    uint32_t feature_value_x2
) {
    asm volatile(
        "mv a0, %0\n"
        "mv a1, %1\n"
        ".word 0x00B5300B\n"
        :
        : "r"(feature_index),
          "r"(feature_value_x2)
        : "a0", "a1", "memory"
    );
}


/*
 * Escreve uma palavra na memória programável das árvores.
 *
 * CUSTOM-0:
 *   funct3 = 111
 *   rs1/a0 = endereço do nó
 *   rs2/a1 = palavra empacotada do nó
 */
static void rf_custom_tree_write(
    uint32_t address,
    uint32_t node_data
) {
    asm volatile(
        "mv a0, %0\n"
        "mv a1, %1\n"
        ".word 0x00B5700B\n"
        :
        : "r"(address),
          "r"(node_data)
        : "a0", "a1", "memory"
    );
}


/*
 * Carrega as quatro árvores.
 *
 * São quatro árvores com 15 posições cada:
 *
 *   árvore 0: endereços  0 a 14
 *   árvore 1: endereços 15 a 29
 *   árvore 2: endereços 30 a 44
 *   árvore 3: endereços 45 a 59
 */
static void rf_load_vehicle_forest(void) {
    for (
        uint32_t address = 0;
        address < VEHICLE_TOTAL_NODES;
        ++address
    ) {
        rf_custom_tree_write(
            address,
            vehicle_forest_nodes[address]
        );
    }
}


/*
 * Classifica uma amostra Vehicle.
 *
 * Os valores do header já estão multiplicados por 2.
 * Portanto, o firmware não realiza conversão em ponto flutuante.
 */
static uint32_t rf_classify_vehicle(
    const uint16_t features_x2[VEHICLE_FEATURE_COUNT]
) {
    for (
        uint32_t feature_index = 0;
        feature_index < VEHICLE_FEATURE_COUNT;
        ++feature_index
    ) {
        rf_custom_feature_write(
            feature_index,
            (uint32_t)features_x2[feature_index]
        );
    }

    rf_custom_start();

    /*
     * Após start, ready baixa enquanto a FSM processa e
     * volta para 1 quando result está disponível.
     */
    while ((rf_custom_status() & 1u) == 0u) {
    }

    return rf_custom_result();
}


/*
 * Exibe um valor nos quatro LEDs inferiores.
 */
static void show_led_value(
    uint32_t value,
    uint32_t delay_count
) {
    LEDS(value & 0xFu);

    for (
        volatile uint32_t i = 0;
        i < delay_count;
        ++i
    ) {
    }

    LEDS(0);

    for (
        volatile uint32_t i = 0;
        i < 150000u;
        ++i
    ) {
    }
}


/*
 * Pisca todos os LEDs duas vezes para separar as etapas.
 */
static void show_separator(void) {
    for (uint32_t i = 0; i < 2u; ++i) {
        LEDS(0xFu);

        for (
            volatile uint32_t j = 0;
            j < 300000u;
            ++j
        ) {
        }

        LEDS(0);

        for (
            volatile uint32_t j = 0;
            j < 300000u;
            ++j
        ) {
        }
    }
}

static void debug_write(
    uint32_t register_index,
    uint32_t value
) {
    /*
     * Primeiro seleciona o registrador.
     * Depois escreve o dado.
     */
    IO_OUT(IO_DBG_ADDR, register_index);
    IO_OUT(IO_DBG_DATA, value);
}

static void debug_write_inference(
    uint32_t sample_index,
    uint32_t expected_prediction,
    uint32_t hardware_prediction,
    uint32_t correct_count,
    uint32_t inference_cycles
) {
    debug_write(
        DBG_REG_SAMPLE,
        sample_index
    );

    debug_write(
        DBG_REG_EXPECTED,
        expected_prediction
    );

    debug_write(
        DBG_REG_PRED,
        hardware_prediction
    );

    debug_write(
        DBG_REG_CORRECT,
        correct_count
    );

    debug_write(
        DBG_REG_CYCLES,
        inference_cycles
    );
}


int main(void) {
    uint32_t reference_matches;
    uint32_t label_matches;
    uint32_t last_cycles;

    /*
     * carrega memoria das arvores
     */
    rf_load_vehicle_forest();

    while (1) {
        reference_matches = 0;
        label_matches = 0;
        last_cycles = 0;

        for (
            uint32_t sample_index = 0;
            sample_index < VEHICLE_TEST_COUNT;
            ++sample_index
        ) {
            uint32_t before = cycles();

            uint32_t prediction = rf_classify_vehicle(
                vehicle_test_features_x2[sample_index]
            );

            uint32_t after = cycles();

            last_cycles = after - before;

            /*
             * Hardware versus referência Python hard-vote.
             *   169 de 169.
             */
            if (
                (prediction & 3u)
                == vehicle_expected_predictions[sample_index]
            ) {
                ++reference_matches;
            }

            /*
             * Previsão versus classe real do dataset.
             *   107 de 169.
             */
            if (
                (prediction & 3u)
                == vehicle_true_labels[sample_index]
            ) {
                ++label_matches;
            }

            debug_write_inference(
            sample_index,
            vehicle_expected_predictions[sample_index],
            prediction & 3u,
            reference_matches,
            last_cycles
            );

            show_led_value(
                1u << (prediction & 3u),
                500000u
            );
        }

        show_separator();

        show_led_value(
            reference_matches & 0xFu,
            1200000u
        );

        show_led_value(
            label_matches & 0xFu,
            1200000u
        );

        show_led_value(
            last_cycles & 0xFu,
            1200000u
        );

        for (
            volatile uint32_t i = 0;
            i < 1500000u;
            ++i
        ) {
        }
    }

    return 0;
}