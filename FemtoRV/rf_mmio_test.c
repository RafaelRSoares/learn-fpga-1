#include <femtorv32.h>
#include <stdint.h>

#define IO_RF_ADDR  (1 << (2 + 12))
#define IO_RF_DATA  (1 << (2 + 13))

#define RF_REG_STATUS 0
#define RF_REG_RESULT 1
#define RF_REG_FEAT0  2
#define RF_REG_FEAT1  3
#define RF_REG_FEAT2  4
#define RF_REG_FEAT3  5
#define RF_REG_TADDR  6
#define RF_REG_TMEM   7
#define RF_REG_START  8

static void rf_select(uint32_t reg) {
    IO_OUT(IO_RF_ADDR, reg);
}

static void rf_write(uint32_t reg, uint32_t value) {
    rf_select(reg);
    IO_OUT(IO_RF_DATA, value);
}

static uint32_t rf_read(uint32_t reg) {
    rf_select(reg);
    return IO_IN(IO_RF_DATA);
}

static uint32_t pack_node(uint32_t feature, uint32_t threshold, uint32_t left_class, uint32_t right_class) {
    return ((feature & 7) << 29)
         | ((threshold & 0x1FFF) << 16)
         | ((left_class & 0xFF) << 8)
         | (right_class & 0xFF);
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

static void rf_load_node(uint32_t tree, uint32_t node, uint32_t data) {
    rf_custom_tree_write(tree * 15 + node, data);
}

static void rf_load_simple_forest(void) {
    for(uint32_t t = 0; t < 4; t++) {
        // Nó 0: separa < 50 e >= 50
        rf_load_node(t, 0, pack_node(0, 50, 0, 0));

        // Nó 1: lado esquerdo, separa < 25 e >= 25
        rf_load_node(t, 1, pack_node(0, 25, 0, 0));

        // Nó 2: lado direito, separa < 75 e >= 75
        rf_load_node(t, 2, pack_node(0, 75, 0, 0));

        // Nós 3, 4, 5, 6: forçam ir para a esquerda
        rf_load_node(t, 3, pack_node(0, 999, 0, 0));
        rf_load_node(t, 4, pack_node(0, 999, 0, 0));
        rf_load_node(t, 5, pack_node(0, 999, 0, 0));
        rf_load_node(t, 6, pack_node(0, 999, 0, 0));

        // Folhas usadas
        rf_load_node(t, 7,  pack_node(0, 0, 0, 0)); // classe 0
        rf_load_node(t, 9,  pack_node(0, 0, 1, 1)); // classe 1
        rf_load_node(t, 11, pack_node(0, 0, 2, 2)); // classe 2
        rf_load_node(t, 13, pack_node(0, 0, 3, 3)); // classe 3

        // Folhas não usadas nesse teste
        rf_load_node(t, 8,  pack_node(0, 0, 0, 0));
        rf_load_node(t, 10, pack_node(0, 0, 1, 1));
        rf_load_node(t, 12, pack_node(0, 0, 2, 2));
        rf_load_node(t, 14, pack_node(0, 0, 3, 3));
    }
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


int main() {
    rf_load_simple_forest();

    while(1) {
        uint32_t r0 = rf_classify(10, 0, 0, 0);
        LEDS(1 << r0);

        for(volatile int i = 0; i < 300000; i++) {
        }

        uint32_t r1 = rf_classify(30, 0, 0, 0);
        LEDS(1 << r1);

        for(volatile int i = 0; i < 300000; i++) {
        }

        uint32_t r2 = rf_classify(60, 0, 0, 0);
        LEDS(1 << r2);

        for(volatile int i = 0; i < 300000; i++) {
        }

        uint32_t r3 = rf_classify(90, 0, 0, 0);
        LEDS(1 << r3);

        for(volatile int i = 0; i < 300000; i++) {
        }
    }

    return 0;
}