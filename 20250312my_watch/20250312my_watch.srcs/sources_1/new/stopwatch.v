`timescale 1ns / 1ps

module stopwatch #(
    parameter COUNT_100HZ = 1_000_000,
    parameter MSEC_MAX = 100,
    parameter SEC_MAX = 60,
    parameter MIN_MAX = 60,
    parameter HOUR_MAX = 24
) (
    input clk,
    input reset,
    input btn_run_stop,
    input btn_clear,
    output [$clog2(MSEC_MAX)-1:0] o_msec,
    output [$clog2(SEC_MAX)-1:0] o_sec,
    output [$clog2(MIN_MAX)-1:0] o_min,
    output [$clog2(HOUR_MAX)-1:0] o_hour
);
    wire w_btn_run_stop, w_btn_clear;
    btn_debounce U_BTN_Debounce_RUN_STOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_stop),   // from btn
        .o_btn(w_btn_run_stop)  // to control unit
    );
    btn_debounce U_BTN_Debounce_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear),   // from btn
        .o_btn(w_btn_clear)  // to control unit
    );

    Sropwatch_control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_btn_run_stop),  // input 
        .i_clear(w_btn_clear),
        .o_run_stop(o_run_stop),
        .o_clear(o_clear)
    );

    wire [$clog2(MSEC_MAX)-1:0] w_msec;
    wire [ $clog2(SEC_MAX)-1:0] w_sec;
    wire [ $clog2(MIN_MAX)-1:0] w_min;
    wire [$clog2(HOUR_MAX)-1:0] w_hour;
    stopwatch_dp #(
        .COUNT_100HZ(COUNT_100HZ),
        .MSEC_MAX(MSEC_MAX),
        .SEC_MAX(SEC_MAX),
        .MIN_MAX(MIN_MAX),
        .HOUR_MAX(HOUR_MAX)
    ) U_DP (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_run_stop),
        .i_clear(o_clear),
        .msec(o_msec),
        .sec(o_sec),
        .min(o_min),
        .hour(o_hour)
    );

endmodule

module Sropwatch_control_unit (
    input clk,
    input reset,
    input i_run_stop,  // input 
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;
    // state 관리
    reg [2:0] state, next;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    // next combinational logic
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else begin
                    next = state;
                end
            end
            RUN: begin
                if (i_run_stop == 1'b1) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end
            CLEAR: begin
                if (i_clear == 1'b0) begin
                    next = STOP;
                end
            end
            default: begin
                next = state;
            end
        endcase
    end

    // combinational output logic
    always @(*) begin
        // 초기화 필요.
        o_run_stop = 1'b0;
        o_clear = 1'b0;
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
