`timescale 1ns / 1ps

module send_tx_btn (
    input  clk,
    input  rst,
    input  btn_start,
    output tx
);
    uart #(
        .BAUD_RATE(9600)
    ) U_Uart (
        .clk(),
        .rst(),
        .btn_start(),
        .tx(),
        .tx_busy()
    );

    btn_debounce U_btn_Debounce (
        .clk  (),
        .reset(),
        .i_btn(),
        .o_btn()
    );
endmodule
