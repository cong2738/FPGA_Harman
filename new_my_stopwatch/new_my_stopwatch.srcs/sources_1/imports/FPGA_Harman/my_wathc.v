`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    //    input [2:0] sw,
    input btn_run_stop,
    input btn_clear,
    output [3:0] seg_comm,
    output [7:0] seg
);
    wire w_clk_10, w_run_stop, w_clear;
    wire o_btn_run_stop, o_btn_clear;

    btn_debounce U_BTN_Debounce_RUN_STOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_stop),   // from btn
        .o_btn(o_btn_run_stop)  // to control unit
    );
    btn_debounce U_BTN_Debounce_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear),   // from btn
        .o_btn(o_btn_clear)  // to control unit
    );

    stopwatch_cu U_CU (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),  // input 
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    wire w_msec,w_sec,w_min,w_hour;
    stopwatch_dp U_DP(
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_run_stop),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    fnd_controller #(
        .LOW_MAX(100),
        .HIGH_MAX(100)
    ) U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .bcd_low(w_msec),  
        .bcd_high(w_sec),  
        .seg(seg),
        .seg_comm(seg_comm)
    );

endmodule

