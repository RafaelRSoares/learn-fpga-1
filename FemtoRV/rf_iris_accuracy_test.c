#include <femtorv32.h>
#include <stdint.h>

#define NUM_SAMPLES 8

typedef struct {
    uint32_t f0;       // sepal length * 10
    uint32_t f1;       // sepal width  * 10
    uint32_t f2;       // petal length * 10
    uint32_t f3;       // petal width  * 10
    uint32_t expected; // 0=setosa, 1=versicolor, 2=virginica
} iris_sample_t;

/*
 * Amostras simplificadas do problema Iris.
 * Os valores estão multiplicados por 10 para evitar ponto flutuante.
 *
 * Classe 0: Setosa
 * Classe 1: Versicolor
 * Classe 2: Virginica
 */
static iris_sample_t samples[NUM_SAMPLES] = {
    {51, 35, 14,  2, 0}, // Setosa
    {49, 30, 14,  2, 0}, // Setosa
    {70, 32, 47, 14, 1}, // Versicolor
    {65, 28, 46, 15, 1}, // Versicolor
    {59, 32, 48, 18, 1}, // Versicolor
    {63, 33, 60, 25, 2}, // Virginica
    {67, 33, 57, 25, 2}, // Virginica
    {62, 34, 54, 23, 2}  // Virginica
};

static uint32_t rf_custom_result() {
    uint32_t r;

    asm volatile(
        ".word 0x0000050b\n"
        "mv %0, a0\n"
        : "=r"(r)
        :
        : "a0"
    );

    return r;
}

static uint32_t rf_custom_status() {
    uint32_t r;

    asm volatile(
        ".word 0x0000150b\n"
        "mv %0, a0\n"
        : "=r"(r)
        :
        : "a0"
    );

    return r;
}

static void rf_custom_start() {
    asm volatile(
        ".word 0x0000200b\n"
    );
}

static void rf_custom_feat0(uint32_t v) {
    asm volatile(
        "mv a0, %0\n"
        ".word 0x0005300b\n"
        :
        : "r"(v)
        : "a0"
    );
}

static void rf_custom_feat1(uint32_t v) {
    asm volatile(
        "mv a0, %0\n"
        ".word 0x0005400b\n"
        :
        : "r"(v)
        : "a0"
    );
}

static void rf_custom_feat2(uint32_t v) {
    asm volatile(
        "mv a0, %0\n"
        ".word 0x0005500b\n"
        :
        : "r"(v)
        : "a0"
    );
}

static void rf_custom_feat3(uint32_t v) {
    asm volatile(
        "mv a0, %0\n"
        ".word 0x0005600b\n"
        :
        : "r"(v)
        : "a0"
    );
}

static void rf_custom_tree_write(uint32_t addr, uint32_t data) {
    asm volatile(
        "mv a0, %0\n"
        "mv a1, %1\n"
        ".word 0x00B5700B\n"
        :
        : "r"(addr), "r"(data)
        : "a0", "a1"
    );
}

/*
 * Formato do nó usado pelo random_forest.v:
 *
 * bits [31:29] = índice da feature
 * bits [28:16] = threshold
 * bits [15:8]  = classe esquerda
 * bits [7:0]   = classe direita
 */
static uint32_t pack_node(
    uint32_t feature,
    uint32_t threshold,
    uint32_t left_class,
    uint32_t right_class
) {
    return ((feature & 7) << 29)
         | ((threshold & 0x1FFF) << 16)
         | ((left_class & 0xFF) << 8)
         | (right_class & 0xFF);
}

static void rf_load_node(uint32_t tree, uint32_t node, uint32_t data) {
    rf_custom_tree_write(tree * 15 + node, data);
}

/*
 * Floresta Iris simplificada.
 *
 * A regra principal é:
 *
 * se petal_length < 25:
 *     classe 0
 * senão se petal_width < 18:
 *     classe 1
 * senão se petal_length < 55:
 *     classe 1
 * senão:
 *     classe 2
 *
 * Como o hardware percorre sempre profundidade 3,
 * os nós intermediários são preenchidos para conduzir
 * a classificação até folhas coerentes.
 */
static void rf_load_iris_forest(void) {
    for(uint32_t t = 0; t < 4; t++) {
        // Nó 0: petal_length < 25 ? setosa : continua
        rf_load_node(t, 0, pack_node(2, 25, 0, 0));

        // Nó 1: subárvore esquerda, mantém classe 0
        rf_load_node(t, 1, pack_node(0, 999, 0, 0));

        // Nó 2: petal_width < 18 ? versicolor : continua
        rf_load_node(t, 2, pack_node(3, 18, 0, 0));

        // Nós 3 e 4: continuam levando para classe 0
        rf_load_node(t, 3, pack_node(0, 999, 0, 0));
        rf_load_node(t, 4, pack_node(0, 999, 0, 0));

        // Nó 5: lado petal_width < 18, leva para classe 1
        rf_load_node(t, 5, pack_node(0, 999, 0, 0));

        // Nó 6: petal_length < 55 ? versicolor : virginica
        rf_load_node(t, 6, pack_node(2, 55, 0, 0));

        // Folhas classe 0
        rf_load_node(t, 7,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 8,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 9,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 10, pack_node(0, 0, 0, 0));

        // Folhas classe 1
        rf_load_node(t, 11, pack_node(0, 0, 1, 1));
        rf_load_node(t, 12, pack_node(0, 0, 1, 1));
        rf_load_node(t, 13, pack_node(0, 0, 1, 1));

        // Folha classe 2
        rf_load_node(t, 14, pack_node(0, 0, 2, 2));
    }
}

static uint32_t rf_classify(uint32_t f0, uint32_t f1, uint32_t f2, uint32_t f3) {
    rf_custom_feat0(f0);
    rf_custom_feat1(f1);
    rf_custom_feat2(f2);
    rf_custom_feat3(f3);

    rf_custom_start();

    while((rf_custom_status() & 1) == 0) {
    }

    return rf_custom_result();
}

static void show_led_value(uint32_t value, uint32_t delay_count) {
    LEDS(value & 0xF);

    for(volatile uint32_t i = 0; i < delay_count; i++) {
    }

    LEDS(0);

    for(volatile uint32_t i = 0; i < 150000; i++) {
    }
}

static void show_separator() {
    for(uint32_t i = 0; i < 2; i++) {
        LEDS(0xF);

        for(volatile uint32_t j = 0; j < 300000; j++) {
        }

        LEDS(0);

        for(volatile uint32_t j = 0; j < 300000; j++) {
        }
    }
}

int main() {
    rf_load_iris_forest();

    while(1) {
        uint32_t correct = 0;
        uint32_t last_cycles = 0;

        for(uint32_t i = 0; i < NUM_SAMPLES; i++) {
            uint32_t before = cycles();

            uint32_t pred = rf_classify(
                samples[i].f0,
                samples[i].f1,
                samples[i].f2,
                samples[i].f3
            );

            uint32_t after = cycles();
            last_cycles = after - before;

            if((pred & 3) == samples[i].expected) {
                correct++;
            }

            // Mostra a classe prevista.
            // Classe 0 -> LD0
            // Classe 1 -> LD1
            // Classe 2 -> LD2
            show_led_value(1 << (pred & 3), 500000);
        }

        // Separador visual
        show_separator();

        // Mostra quantidade de acertos em binário.
        // Se acertar 8/8, mostra 1000 -> LD3.
        show_led_value(correct, 1200000);

        // Mostra os 4 bits baixos do tempo da última inferência.
        show_led_value(last_cycles & 0xF, 1200000);

        for(volatile uint32_t i = 0; i < 1500000; i++) {
        }
    }

    return 0;
}