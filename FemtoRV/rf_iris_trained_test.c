#include <femtorv32.h>
#include <stdint.h>

typedef struct {
    uint32_t f0;
    uint32_t f1;
    uint32_t f2;
    uint32_t f3;
    uint32_t expected;
} iris_sample_t;

static iris_sample_t samples[] = {
    {57, 25, 50, 20, 2},
    {50, 34, 15, 2, 0},
    {51, 35, 14, 2, 0},
    {48, 34, 16, 2, 0},
    {50, 23, 33, 10, 1},
    {50, 33, 14, 2, 0},
    {57, 28, 41, 13, 1},
    {49, 25, 45, 17, 2},
    {48, 30, 14, 1, 0},
    {61, 30, 46, 14, 1},
    {73, 29, 63, 18, 2},
    {61, 30, 49, 18, 2},
};

#define NUM_SAMPLES 12
#define IO_DBG_ADDR  (1 << (2 + 14))
#define IO_DBG_DATA  (1 << (2 + 15))

#define DBG_REG_SAMPLE   0
#define DBG_REG_EXPECTED 1
#define DBG_REG_PRED     2
#define DBG_REG_CYCLES   3
#define DBG_REG_CORRECT  4

static void dbg_write(uint32_t reg, uint32_t value) {
    IO_OUT(IO_DBG_ADDR, reg);
    IO_OUT(IO_DBG_DATA, value);
}


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


static void rf_load_trained_forest(void) {

    // Tree 0

    rf_load_node(0, 0, 0x60080000);

    rf_load_node(0, 1, 0x00000000);

    rf_load_node(0, 2, 0x60120000);

    rf_load_node(0, 3, 0x00000000);

    rf_load_node(0, 4, 0x00000000);

    rf_load_node(0, 5, 0x00470000);

    rf_load_node(0, 6, 0x00000202);

    rf_load_node(0, 7, 0x00000000);

    rf_load_node(0, 8, 0x00000000);

    rf_load_node(0, 9, 0x00000000);

    rf_load_node(0, 10, 0x00000000);

    rf_load_node(0, 11, 0x00000101);

    rf_load_node(0, 12, 0x00000202);

    rf_load_node(0, 13, 0x00000202);

    rf_load_node(0, 14, 0x00000202);



    // Tree 1

    rf_load_node(1, 0, 0x401B0000);

    rf_load_node(1, 1, 0x00000000);

    rf_load_node(1, 2, 0x60120000);

    rf_load_node(1, 3, 0x00000000);

    rf_load_node(1, 4, 0x00000000);

    rf_load_node(1, 5, 0x40320000);

    rf_load_node(1, 6, 0x40320000);

    rf_load_node(1, 7, 0x00000000);

    rf_load_node(1, 8, 0x00000000);

    rf_load_node(1, 9, 0x00000000);

    rf_load_node(1, 10, 0x00000000);

    rf_load_node(1, 11, 0x00000101);

    rf_load_node(1, 12, 0x00000101);

    rf_load_node(1, 13, 0x00000202);

    rf_load_node(1, 14, 0x00000202);



// Tree 2

    rf_load_node(2, 0, 0x40190000);

    rf_load_node(2, 1, 0x00000000);

    rf_load_node(2, 2, 0x40300000);

    rf_load_node(2, 3, 0x00000000);

    rf_load_node(2, 4, 0x00000000);

    rf_load_node(2, 5, 0x00000101);

    rf_load_node(2, 6, 0x60120000);

    rf_load_node(2, 7, 0x00000000);

    rf_load_node(2, 8, 0x00000000);

    rf_load_node(2, 9, 0x00000000);

    rf_load_node(2, 10, 0x00000000);

    rf_load_node(2, 11, 0x00000101);

    rf_load_node(2, 12, 0x00000101);

    rf_load_node(2, 13, 0x00000101);

    rf_load_node(2, 14, 0x00000202);



    // Tree 3

    rf_load_node(3, 0, 0x60080000);

    rf_load_node(3, 1, 0x00000000);

    rf_load_node(3, 2, 0x40300000);

    rf_load_node(3, 3, 0x00000000);

    rf_load_node(3, 4, 0x00000000);

    rf_load_node(3, 5, 0x00000101);

    rf_load_node(3, 6, 0x40330000);

    rf_load_node(3, 7, 0x00000000);

    rf_load_node(3, 8, 0x00000000);

    rf_load_node(3, 9, 0x00000000);

    rf_load_node(3, 10, 0x00000000);

    rf_load_node(3, 11, 0x00000101);

    rf_load_node(3, 12, 0x00000101);

    rf_load_node(3, 13, 0x00000202);

    rf_load_node(3, 14, 0x00000202);

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
    rf_load_trained_forest();

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
            
            dbg_write(DBG_REG_SAMPLE, i);
            dbg_write(DBG_REG_EXPECTED, samples[i].expected);
            dbg_write(DBG_REG_PRED, pred & 3);
            dbg_write(DBG_REG_CORRECT, correct);
            dbg_write(DBG_REG_CYCLES, last_cycles);

            // Mostra a classe prevista.
            // Classe 0 -> LD0
            // Classe 1 -> LD1
            // Classe 2 -> LD2
            show_led_value(1 << (pred & 3), 500000);
        }

        // Separador visual
        show_separator();

        // Mostra quantidade de acertos em binário.
        // Se acertar 12/12, mostra 1100 -> LD2 + LD3.
        show_led_value(correct, 1200000);

        // Mostra os 4 bits baixos do tempo da última inferência.
        show_led_value(last_cycles & 0xF, 1200000);

        for(volatile uint32_t i = 0; i < 1500000; i++) {
        }
    }

    return 0;
}