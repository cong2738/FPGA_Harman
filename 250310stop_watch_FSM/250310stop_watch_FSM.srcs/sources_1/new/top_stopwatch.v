`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input i_btn_run,
    input i_btn_clear,
    output[3:0] fnd_comm,
    output[7:0] fnd_font
);

    wire w_run, w_clear;
    stopwatch_cu U_Stopwatch_CU(
        .clk(clk),
        .reset(reset),
        .i_btn_run(i_btn_run),
        .i_btn_clear(i_clear),
        .o_run(w_run),
        .o_clear(w_clear)
    );

    fnd_controller #(
        .LOW_MAX(100), 
        .HIGH_MAX(60)
    ) U(
        .clk(clk),
        .reset(res),
        .msec(),
        .sec(),
        .min(),
        .hour(),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    btn_debounce (
        .clk(clk),
        .reset(reset),
        .i_btn(),
        .o_btn()
    );
endmodule
