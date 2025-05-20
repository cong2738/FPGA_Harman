#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"

typedef struct{
    volatile CR;
    volatile SOD;
    volatile SID;
    volatile SR;
} SPI_Typedef;

#define SPI_BASEADDR 0x44a00000U
#define SPI ((SPI_Typedef*) SPI_BASEADDR)

int main()
{
    init_platform();
    SPI->CR = 0b001;
    SPI->SOD = 0b00000001;
    printf("data: %d\n",SPI->SID);
    cleanup_platform();
    return 0;
}
