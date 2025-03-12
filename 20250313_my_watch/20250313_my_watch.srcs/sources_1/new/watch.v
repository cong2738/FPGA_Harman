`timescale 1ns / 1ps

module watch #(
    parameter COUNT_100HZ = 1_000_000,
    parameter MSEC_MAX = 100,
    parameter SEC_MAX = 60,
    parameter MIN_MAX = 60,
    parameter HOUR_MAX = 24
) (
    input clk,
    input reset,
    input sec_btn,
    input min_btn,
    input hour_btn,
    output [$clog2(MSEC_MAX)-1:0] w_msec,
    output [$clog2(SEC_MAX)-1:0] w_sec,
    output [$clog2(MIN_MAX)-1:0] w_min,
    output [$clog2(HOUR_MAX)-1:0] w_hour
);
    wire w_run_stop, w_clear;
    wire o_sec_btn, o_min_btn, o_hour_btn;
    btn_debounce U_BTN_Debounce_Sec (
        .clk  (clk),
        .reset(reset),
        .i_btn(sec_btn),   // from btn
        .o_btn(o_sec_btn)  // to control unit
    );
    btn_debounce U_BTN_Debounce_Min (
        .clk  (clk),
        .reset(reset),
        .i_btn(min_btn),   // from btn
        .o_btn(o_min_btn)  // to control unit
    );
    btn_debounce U_BTN_Debounce_Hour (
        .clk  (clk),
        .reset(reset),
        .i_btn(hour_btn),   // from btn
        .o_btn(o_hour_btn)  // to control unit
    );

    watch_control_unit U_Watch_CU (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),  // input 
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    watch_dp #(
        .COUNT_100HZ(COUNT_100HZ),
        .MSEC_MAX(MSEC_MAX),
        .SEC_MAX(SEC_MAX),
        .MIN_MAX(MIN_MAX),
        .HOUR_MAX(HOUR_MAX)
    ) U_DP (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_run_stop),
        .i_clear(w_clear),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );
endmodule

module watch_control_unit (
    input  clk,
    input  reset,
    input  i_sec_add,
    input  i_min_add,
    input  i_hour_add,
    output o_sec_add,
    output o_min_add,
    output o_hour_add
);
    parameter STOP = 3'b000, SEC = 3'b001, MIN = 3'b010, HOUR = 3'b100;
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
    reg [2:0] i_smh;
    always @(*) begin
        next  = state;
        i_smh = {i_sec_add, i_min_add, i_hour_add};
        case (state)
            STOP: begin
                case (i_smh)
                    SEC: next = SEC;
                    MIN: next = MIN;
                    HOUR: next = HOUR;
                    default: next = STOP;
                endcase
            end
            SEC:  next = STOP;
            MIN:  next = STOP;
            HOUR: next = STOP;
            default: begin
                next = STOP;
            end
        endcase
    end

    reg r_sec_add;
    reg r_min_add;
    reg r_hour_add;
    // combinational output logic
    always @(*) begin
        // 초기화 필요.
        r_sec_add  = 0;
        r_min_add  = 0;
        r_hour_add = 0;
        case (state)
            STOP: begin
                r_sec_add  = 0;
                r_min_add  = 0;
                r_hour_add = 0;
            end

            SEC: begin
                r_sec_add  = SEC;
                r_min_add  = SEC;
                r_hour_add = SEC;
            end

            MIN: begin
                r_sec_add  = MIN;
                r_min_add  = MIN;
                r_hour_add = MIN;
            end

            HOUR: begin
                r_sec_add  = HOUR;
                r_min_add  = HOUR;
                r_hour_add = HOUR;
            end

            default: begin
                r_sec_add  = 0;
                r_min_add  = 0;
                r_hour_add = 0;
            end
        endcase
    end

    assign o_sec_add  = r_sec_add;
    assign o_min_add  = r_min_add;
    assign o_hour_add = r_hour_add;

endmodule

