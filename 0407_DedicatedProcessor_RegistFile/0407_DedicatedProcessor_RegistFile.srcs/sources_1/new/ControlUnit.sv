`timescale 1ns / 1ps

module ControlUnit (
    input  logic       clk,
    input  logic       reset,
    input  logic       comp_10,
    output logic       initial_sig,
    output logic       wen,
    output logic [2:0] wptr,
    output logic [2:0] rptr1,
    output logic [2:0] rptr2,
    output logic       out_sel
);
    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7
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
        initial_sig = 0;
        wen = 0;
        wptr = 0;
        rptr1 = 0;
        rptr2 = 0;
        out_sel = 0;

        case (state)
            S0: begin  //  initial_one
                initial_sig = 1;
                wen         = 1;
                wptr        = 1;
                rptr1       = 0;
                rptr2       = 0;
                out_sel     = 0;
                next        = S1;
            end
            S1: begin  //  initial_a
                initial_sig = 0;
                wen         = 1;
                wptr        = 2'b0;
                rptr1       = 0;
                rptr2       = 0;
                out_sel     = 0;
                next        = S2;
            end
            S2: begin  //  initial_sum
                initial_sig = 0;
                wen         = 1;
                wptr        = 3;
                rptr1       = 0;
                rptr2       = 0;
                out_sel     = 0;
                next        = S3;
            end
            S3: begin  // while (a < 10)
                rptr1 = 2;  // a
                if (comp_10) begin
                    next = S4;
                end else begin
                    next = S7;
                end
            end
            S4: begin  // sum = sum + a
                wen     = 1;
                wptr    = 3;  // sum
                rptr1   = 3;  // sum
                rptr2   = 2;  // a
                out_sel = 0;
                next    = S5;
            end
            S5: begin  // a = a + 1
                wen     = 1;
                wptr    = 2;  //a
                rptr1   = 1;  // 1
                rptr2   = 2;  // a
                out_sel = 0;
                next    = S6;
            end
            S6: begin  // out = sum
                rptr1   = 3;  // 1
                out_sel = 1;
                next    = S3;
            end
            S7: begin  // halt
                next = S7;
            end

        endcase

    end
endmodule
