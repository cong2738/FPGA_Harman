`timescale 1ns / 1ps

module top_stopwatch (
    input        clk,
    input        reset,
    input        btn_run_hour,
    input        btn_clear_start,
    input        btn_sec,
    input        btn_min,
    input        com_run,
    input        com_clear,
    input        com_sec,
    input        com_min,
    input        com_hour,
    input        com_start,
    input  [1:0] mode_sel,
    output [6:0] w_stop_msec,
    output [6:0] w_stop_sec,
    output [6:0] w_stop_min,
    output [6:0] w_stop_hour,
    output [6:0] w_watch_msec,
    output [6:0] w_watch_sec,
    output [6:0] w_watch_min,
    output [6:0] w_watch_hour
);
    wire w_run, w_clear, w_hour, w_min, w_sec, w_start, run, clear;

    // 1bit wire는 선언안해도 자동 1bit 로 연결됨

    btn_debounce U_Btn_Run_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_hour & mode_sel == 0),
        .o_btn(w_run)
    );
    btn_debounce U_Btn_Clear_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear_start & mode_sel == 0),
        .o_btn(w_clear)
    );
    
    btn_debounce U_Btn_Start_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear_start & mode_sel == 1),
        .o_btn(w_start)
    );
    btn_debounce U_Btn_Hour_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_hour & mode_sel == 1),
        .o_btn(w_hour)
    );
    btn_debounce U_Btn_Min_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_min & mode_sel == 1),
        .o_btn(w_min)
    );
    btn_debounce U_Btn_Sec_DB (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_sec & mode_sel == 1),
        .o_btn(w_sec)
    );

    stopwatch_cu U_Stopwatch (
        .clk(clk),
        .reset(reset),
        .i_btn_run(w_run | com_run),
        .i_btn_clear(w_clear | com_clear),
        .o_run(run),
        .o_clear(clear)
    );
    stopwatch_dp U_StopWatch_dp (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .msec (w_stop_msec),
        .sec  (w_stop_sec),
        .min  (w_stop_min),
        .hour (w_stop_hour)
    );
    clock_dp U_clock_dp (
        .clk(clk),
        .reset(reset),
        .i_btn_sec(w_sec | com_sec),
        .i_btn_min(w_min | com_min),
        .i_btn_hour(w_hour | com_hour),
        .i_start(w_start),
        .msec(w_watch_msec),
        .sec(w_watch_sec),
        .min(w_watch_min),
        .hour(w_watch_hour)
    );

endmodule




