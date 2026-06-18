#include <femtorv32.h>

#define IO_BASE  0x00400000
#define LEDS     (*(volatile int*)(IO_BASE + 0))

int main() {
    int x = 0;

    while(1) {
        LEDS = x;

        for(volatile int i = 0; i < 100000; i++) {
        }

        x++;
    }

    return 0;
}