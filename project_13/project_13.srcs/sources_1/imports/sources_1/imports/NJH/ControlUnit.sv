`timescale 1ns / 1ps

module ControlUnit (
    input  logic       clk,
    input  logic       reset,
    output logic       RFSrcMuxSel,
    output logic [2:0] readAddr1,
    output logic [2:0] readAddr2,
    output logic [2:0] writeAddr,
    output logic       writeEn,
    output logic       outBuf,
    output logic [2:0] aluOP,
    input  logic       comp
);
    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        S8,
        S9,
        S10,
        O0,
        O1,
        O2,
        O3,
        O4,
        O5,
        O6,
        O7,
        O8,
        O9,
        O10
    } state_e;

    state_e state, state_next;
    logic [14:0] out_signals;

    assign {RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf,aluOP} = out_signals;

    always_ff @(posedge clk, posedge reset) begin : state_reg
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin : state_next_machine
        state_next  = state;
        out_signals = 0;
        case (state)
            //{RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf, aluOP} = out_signals;
            S0: begin  // R1 = 1
                out_signals = 15'b1_000_000_001_1_0_000;
                state_next  = O0;
            end
            S1: begin  // R2 = 0
                out_signals = 15'b0_000_000_010_1_0_000;
                state_next  = O1;
            end
            S2: begin  // R3 = 0;
                out_signals = 15'b0_000_000_011_1_0_000;
                state_next  = O2;
            end
            S3: begin  // R4 = R1 + R1
                out_signals = 15'b0_001_001_100_1_0_000;
                state_next  = O3;
            end
            S4: begin  // R5 = R4 + R4
                out_signals = 15'b0_100_100_101_1_0_000;
                state_next  = O4;
            end
            S5: begin  // R6 = R5 - R1
                out_signals = 15'b0_101_001_110_1_0_001;
                state_next  = O5;
            end
            S6: begin  // R2 = R6 & R4
                out_signals = 15'b0_110_100_010_1_0_010;
                state_next  = O6;
            end
            S7: begin  //R3 = R2 or R5
                out_signals = 15'b0_010_101_011_1_0_011;
                state_next  = O7;
            end
            S8: begin  //R7 = R3 xor R2
                out_signals = 15'b0_011_010_111_1_0_100;
                state_next  = O8;
            end
            S9: begin  //R4 = not R7
                out_signals = 15'b0_111_000_100_1_0_101;
                state_next  = O9;
            end
            S10: begin  //if(R7 > R4)
                out_signals = 15'b0_111_100_000_0_0_110;
                if (comp) state_next = S4;
                else begin
                    state_next = S10;
                end
            end

            O0: begin  // out = R1
                out_signals = 15'b1_001_xxx_xxx_0_1_xxx;
                state_next  = S1;
            end
            O1: begin  // out = R2
                out_signals = 15'b1_010_xxx_xxx_0_1_xxx;
                state_next  = S2;
            end
            O2: begin  // out = R3 
                out_signals = 15'b1_011_xxx_xxx_0_1_xxx;
                state_next  = S3;
            end
            O3: begin  // out = R4 
                out_signals = 15'b1_100_xxx_xxx_0_1_xxx;
                state_next  = S4;
            end
            O4: begin  // out = R5 
                out_signals = 15'b1_101_xxx_xxx_0_1_xxx;
                state_next  = S5;
            end
            O5: begin  // out = R6 
                out_signals = 15'b1_110_xxx_xxx_0_1_xxx;
                state_next  = S6;
            end
            O6: begin  // out = R2 
                out_signals = 15'b1_010_xxx_xxx_0_1_xxx;
                state_next  = S7;
            end
            O7: begin  // out = R3 
                out_signals = 15'b1_011_xxx_xxx_0_1_xxx;
                state_next  = S8;
            end
            O8: begin  // out = R7
                out_signals = 15'b1_111_xxx_xxx_0_1_xxx;
                state_next  = S9;
            end
            O9: begin  // out = R4
                out_signals = 15'b1_100_xxx_xxx_0_1_xxx;
                state_next  = S10;
            end
            O10: begin  //if(R7 > R4)
                state_next = S10;
            end
        endcase
    end
endmodule
