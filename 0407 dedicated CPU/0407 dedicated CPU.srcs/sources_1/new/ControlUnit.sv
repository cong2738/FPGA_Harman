`timescale 1ns / 1ps

module ControlUnit (
    input  logic clk,
    input  logic reset,
    input  logic comp_Aand10,
    output logic A_0_sel,
    output logic sum_0_sel,
    output logic A_save_sel,
    output logic sum_save_sel,
    output logic add_sel,
    output logic out_sel
);
    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5
    } state_e;

    state_e state, next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= S0;
        end else begin
            state <= next;
        end
    end
    /* 
    a = 0;
    sum = 0;
    while (a < 10) {   
        sum = sum + a;
        output = sum;
        a = a + 1;
    }
    halt;
    */
    always_comb begin : next_state_logic
        next = state;
        A_0_sel = 0;
        sum_0_sel = 0;
        A_save_sel = 0;
        sum_save_sel = 0;
        add_sel = 0;
        out_sel = 0;

        case (state)
            S0: begin  // a = 0, sum = 0
                A_save_sel = 1;
                sum_save_sel = 1;
                next = S1;
            end
            S1: begin  // while (a < 10)
                if (comp_Aand10) begin
                    next = S2;
                end else next = S5;
            end
            S2: begin  // sum = sum + a
                add_sel = 0;
                sum_0_sel = 1;
                sum_save_sel = 1;
                next = S3;
            end
            S3: begin  // a = a + 1
                add_sel = 1;
                A_0_sel = 1;
                A_save_sel = 1;
                next = S4;
            end
            S4: begin  // out = sum
                out_sel = 1;
                next = S1;
            end
            S5: begin  // halt
                next = S5;
            end

        endcase

    end
endmodule
