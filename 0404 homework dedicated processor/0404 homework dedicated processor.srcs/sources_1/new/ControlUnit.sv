`timescale 1ns / 1ps

module ControlUnit (
    input clk,
    input reset,
    input comp_Aand10,
    output reg A_0_sel,
    output reg sum_0_sel,
    output reg A_save_sel,
    output reg sum_save_sel,
    output reg out_sel
);
    reg [7:0] state, next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end
    /* 
    a = 0;
    sum = 0;
    while (a < 10) {   
        output = a;
        a = a + 1;
        sum = sum + a;
    }
    halt;
    */
    always_comb begin : next_state_logic
        A_0_sel = 0;
        sum_0_sel = 0;
        A_save_sel = 0;
        sum_save_sel = 0;
        out_sel = 0;

        case (state)
            0: begin
                A_save_sel = 1;
                sum_save_sel = 1;
                next = 1;
            end
            1: begin
                if (comp_Aand10) begin
                    next = 5;
                end else next = 2;
            end
            2: begin
                sum_0_sel = 1;
                sum_save_sel = 1;
                next = 3;
            end
            3: begin
                out_sel = 1;
                next = 4;
            end
            4: begin
                A_0_sel   = 1;
                A_save_sel = 1;
                next = 1;
            end
            5: begin
                next = 5;
            end

        endcase

    end
endmodule
