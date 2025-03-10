`timescale 1ns / 1ps

module top_stopwatch (
    input clk,
    input reset,
    input i_btn_run,
    input i_btn_clear,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
);
    wire db_run,db_clear;
    btn_debounce RunDebounce(
        .clk(clk),
        .reset(reset),
        .i_btn(i_btn_run),
        .o_btn(db_run)
    );
    btn_debounce ClearDebounce(
        .clk(clk),
        .reset(reset),
        .i_btn(i_btn_clear),
        .o_btn(db_clear)
    );

    wire w_run, w_clear;
    stopwatch_cu U_Stopwatch_CU (
        .clk(clk),
        .reset(reset),
        .i_btn_run(db_run),
        .i_btn_clear(db_clear),
        .o_run(w_run),
        .o_clear(w_clear)
    );

    wire [6:0] w_msec, w_sec, w_min, w_hour;
    stopwatch_dp DP (
        .clk  (clk),
        .reset(reset),
        .run  (w_run),
        .clear(w_clear),
        .msec (w_msec),
        .sec  (w_sec),
        .min  (w_min),
        .hour (w_hour)
    );

    fnd_controller U_Fnd_Contriller (
        .clk(clk),
        .reset(res),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

endmodule
