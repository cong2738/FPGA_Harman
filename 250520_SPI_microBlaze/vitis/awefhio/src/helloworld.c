#include <sleep.h>
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#define SPI_BASEADDR 0x44a00000U
typedef struct {
	volatile uint32_t CD;
	volatile uint32_t SOD;
	volatile uint32_t SID;
	volatile uint32_t SR;
}SPI_typedef;

#define GPSPI ((SPI_typedef*) SPI_BASEADDR)

int main()
{
	uint32_t data = 0;
	while(data < 10) {
		GPSPI->SOD = data;
		GPSPI->CD = 0b001;
		GPSPI->CD = 0b000;
		while(!(GPSPI->SR && (1<<1)));
		xil_printf("SID: %d\n", GPSPI->SID);
		data++;
	}

    return 0;
}
