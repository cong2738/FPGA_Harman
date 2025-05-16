`timescale 1ns / 1ps

module SPI_FND (
    input  wire       sys_clk,
    input  wire       SCLK,
    input  wire       reset,
    input  wire       CS,
    input  wire       MOSI,
    output wire       MISO,
    output wire [3:0] comm,
    output wire [7:0] font
);
    wire [7:0] spi_data;
    wire done;
    wire [13:0] bcd;

    SPI_Slave u_SPI_Slave (
        .SCLK (SCLK),
        .reset   (reset),
        .CS      (CS),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .data_reg(spi_data),
        .done    (done)
    );

    IP_CU u_IP_CU (
        .sys_clk(sys_clk),
        .SCLK (SCLK),
        .reset  (reset),
        .CS     (CS),
        .i_data (spi_data),
        .done   (done),
        .bcd    (bcd)
    );

    fndController u_fndController (
        .clk    (sys_clk),
        .reset  (reset),
        .fndData(bcd),
        .fndDot (4'b1111),
        .fndCom (comm),
        .fndFont(font)
    );

endmodule
