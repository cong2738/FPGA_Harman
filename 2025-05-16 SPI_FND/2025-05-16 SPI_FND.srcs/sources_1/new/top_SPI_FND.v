`timescale 1ns / 1ps

module top_SPI_FND #(
    parameter MAX_COUNT = 100_000
) (
    input wire sys_clk,
    input wire reset,
    input wire btn,
    input wire [15:0] sw,
    output wire [15:0] led,
    output wire [3:0] comm,
    output wire [7:0] font
);
    assign led = sw;

    wire [7:0] tx_data;

    btn_debounce #(MAX_COUNT) u_btn_debounce (
        .clk  (sys_clk),
        .reset(reset),
        .i_btn(btn),
        .o_btn(o_btn)
    );

    input_Master u_input_Master (
        .clk  (sys_clk),
        .reset(reset),
        .btn  (o_btn),
        .sw   (sw),
        .done (done),
        .ready (ready),
        .data (tx_data),
        .start(start)
    );

    SPI_Master u_SPI_Master (
        .sys_clk(sys_clk),
        .reset  (reset),
        .start  (start),
        .MISO   (MISO),
        .tx_data(tx_data),
        .rx_data(),
        .MOSI   (MOSI),
        .done   (done),
        .ready  (ready),
        .SCLK   (SCLK),
        .CS     (CS)
    );

    SPI_FND u_SPI_FND (
        .sys_clk(sys_clk),
        .SCLK   (SCLK),
        .reset  (reset),
        .CS     (CS),
        .MOSI   (MOSI),
        .MISO   (MISO),
        .comm   (comm),
        .font   (font)
    );

endmodule
