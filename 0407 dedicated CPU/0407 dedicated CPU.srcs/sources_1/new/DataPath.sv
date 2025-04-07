`timescale 1ns / 1ps

module DataPath (
    input  logic       clk,
    input  logic       reset,
    input  logic       A_0_sel,
    input  logic       sum_0_sel,
    input  logic       A_save_sel,
    input  logic       sum_save_sel,
    input  logic       add_sel,
    input  logic       out_sel,
    output logic       comp_Aand10,
    output logic [7:0] sum_out
);
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
    wire [7:0] A_0_out;
    wire [7:0] A_regout;
    wire [7:0] sum_0_out;
    wire [7:0] sum_regout;
    wire [7:0] adder_o;
    wire [7:0] add_mux_o;
    Mux_2x1 U_A_initial (
        .one    (adder_o),
        .zero   (0),
        .mux_sel(A_0_sel),
        .mux_out(A_0_out)
    );
    Mux_2x1 U_sum_initial (
        .one    (adder_o),
        .zero   (0),
        .mux_sel(sum_0_sel),
        .mux_out(sum_0_out)
    );
    save_ff U_A_Reg (
        .in(A_0_out),
        .clk(clk),
        .reset(reset),
        .save_sel(A_save_sel),
        .out(A_regout)
    );
    save_ff U_Sum_Reg (
        .in      (sum_0_out),
        .clk     (clk),
        .reset   (reset),
        .save_sel(sum_save_sel),
        .out     (sum_regout)
    );
    Mux_2x1 u_adderMux (
        .one    (1),
        .zero   (sum_regout),
        .mux_sel(add_sel),
        .mux_out(add_mux_o)
    );
    adder U_Adder (
        .A  (add_mux_o),
        .B  (A_regout),
        .sum(adder_o)
    );
    out_buffer U_out (
        .A(sum_regout),
        .out_sel(out_sel),
        .out(sum_out)
    );
    comp U_A_UT_Ten (
        .A(A_regout),
        .B(11),
        .comp_out(comp_Aand10)
    );
endmodule

module Mux_2x1 (
    input [7:0] one,
    input [7:0] zero,
    input mux_sel,
    output reg [7:0] mux_out
);
    assign mux_out = mux_sel ? one : zero;
endmodule

module save_ff (
    input [7:0] in,
    input clk,
    input reset,
    input save_sel,
    output reg [7:0] out
);
    always_ff @(posedge clk, posedge reset) begin : A_Reg
        if (reset) begin
            out <= 1'bz;
        end else if (save_sel) begin
            out <= in;
        end
    end
endmodule

module adder (
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] sum
);
    always_comb begin : adder_logic
        sum = A + B;
    end
endmodule

module comp (
    input [7:0] A,
    input [7:0] B,
    output comp_out
);
    assign comp_out = (A == B) ? 1'b1 : 1'b0;
endmodule

module out_buffer (
    input [7:0] A,
    input out_sel,
    output reg [7:0] out
);
    assign out = out_sel ? A : out;
endmodule
