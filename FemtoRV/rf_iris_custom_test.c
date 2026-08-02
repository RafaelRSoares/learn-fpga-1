#include <femtorv32.h>
#include <stdint.h>

#define NUM_SAMPLES 5

typedef struct {
    uint32_t f0;
    uint32_t f1;
    uint32_t f2;
    uint32_t f3;
    uint32_t expected;
} iris_sample_t;

static iris_sample_t samples[] = {
    {51, 34, 14,  2, 0},
    {74, 32, 56, 19, 1},
    {67, 33, 57, 25, 2},
    {65, 28, 46, 15, 1},
    {62, 34, 35, 23, 2}
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
    asm volatile(".word 0x0000200b\n");
}

static void rf_custom_feat0(uint32_t v) {
    asm volatile("mv a0, %0\n.word 0x0005300b\n" : : "r"(v) : "a0");
}

static void rf_custom_feat1(uint32_t v) {
    asm volatile("mv a0, %0\n.word 0x0005400b\n" : : "r"(v) : "a0");
}

static void rf_custom_feat2(uint32_t v) {
    asm volatile("mv a0, %0\n.word 0x0005500b\n" : : "r"(v) : "a0");
}

static void rf_custom_feat3(uint32_t v) {
    asm volatile("mv a0, %0\n.word 0x0005600b\n" : : "r"(v) : "a0");
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

static uint32_t pack_node(uint32_t feature, uint32_t threshold, uint32_t left_class, uint32_t right_class) {
    return ((feature & 7) << 29)
         | ((threshold & 0x1FFF) << 16)
         | ((left_class & 0xFF) << 8)
         | (right_class & 0xFF);
}

static void rf_load_node(uint32_t tree, uint32_t node, uint32_t data) {
    rf_custom_tree_write(tree * 15 + node, data);
}

static void rf_load_simple_forest(void) {
    for(uint32_t t = 0; t < 4; t++) {
        rf_load_node(t, 0, pack_node(2, 25, 0, 0));
        rf_load_node(t, 1, pack_node(0, 999, 0, 0));
        rf_load_node(t, 2, pack_node(3, 18, 0, 0));

        rf_load_node(t, 3, pack_node(0, 999, 0, 0));
        rf_load_node(t, 4, pack_node(0, 999, 0, 0));
        rf_load_node(t, 5, pack_node(0, 999, 0, 0));
        rf_load_node(t, 6, pack_node(3, 22, 0, 0));

        rf_load_node(t, 7,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 8,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 9,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 10, pack_node(0, 0, 0, 0));

        rf_load_node(t, 11, pack_node(0, 0, 1, 1));
        rf_load_node(t, 12, pack_node(0, 0, 1, 1));
        rf_load_node(t, 13, pack_node(0, 0, 1, 1));
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

int main() {
    rf_load_simple_forest();

    while(1) {
        uint32_t correct = 0;

        for(uint32_t i = 0; i < NUM_SAMPLES; i++) {
            uint32_t pred = rf_classify(
                samples[i].f0,
                samples[i].f1,
                samples[i].f2,
                samples[i].f3
            );

            if((pred & 3) == samples[i].expected) {
                correct++;
            }

            show_led_value(1 << (pred & 3), 500000);
        }

        for(volatile uint32_t i = 0; i < 1000000; i++) {
        }

        show_led_value(correct, 1000000);

        for(volatile uint32_t i = 0; i < 1500000; i++) {
        }
    }

    return 0;
}