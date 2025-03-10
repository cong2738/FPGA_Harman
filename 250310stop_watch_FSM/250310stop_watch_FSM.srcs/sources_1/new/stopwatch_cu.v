`timescale 1ns / 1ps

module stopwatch_cu (
    input  clk,
    input  reset,
    input  i_btn_run,
    input  i_btn_clear,
    output reg o_run,
    output reg o_clear
);

    //fsm 구조로 CU설계
    localparam STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] state, next;

    // state register
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            state <= STOP;
        end else begin
            state = next;
        end
    end

    // next logic
    always @(*) begin
        next = state;
        case (state)
            STOP:
            if (i_btn_run) begin
                next = RUN;
            end else if (i_btn_clear) begin
                next = CLEAR;
            end else next = state;

            RUN:
            if (i_btn_run) begin
                next = STOP;
            end else next = state;

            CLEAR:
            if (i_btn_clear == 0) begin
                next = STOP;
            end else next = STOP;

            default: next = state;
        endcase
    end

    // output logic
    always @(*) begin
        o_run = 0;
        o_clear = 0;
        case (state)
            STOP: begin 
                o_run = 0;
                o_clear = 0;
            end 

            RUN: begin 
                o_run = 1;
                o_clear = 0;
            end 
            
            CLEAR: begin 
                o_run = 0;
                o_clear = 1;
            end 
        endcase
    end

endmodule
