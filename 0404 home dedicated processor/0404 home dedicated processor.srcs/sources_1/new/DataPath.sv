`timescale 1ns / 1ps

module DataPath (
    input clk,
    input reset,
    input A_0_sel,
    input A_save_sel,
    input out_sel,
    output comp_Aand10,
    output [7:0] A_out
);
    wire [7:0] A_0_out;
    wire [7:0] A_regout;
    wire [7:0] App;
    A_0_Mux U_A_initial (
        .A(App),
        .A_0_sel(A_0_sel),
        .A_0_out(A_0_out)
    );
    A_save_ff U_A_Reg_Save (
        .A_in(A_0_out),
        .clk(clk),
        .reset(reset),
        .A_save_sel(A_save_sel),
        .A_out(A_regout)
    );
    adder U_APP (
        .A  (A_regout),
        .B  (1),
        .sum(App)
    );
    out_buffer U_A_out (
        .A(A_regout),
        .out_sel(out_sel),
        .out(A_out)
    );
    comp U_A_UT_Ten (
        .A(A_regout),
        .B(10),
        .comp_out(comp_Aand10)
    );
endmodule

module A_0_Mux (
    input [7:0] A,
    input A_0_sel,
    output reg [7:0] A_0_out
);
    assign A_0_out = A_0_sel ? A : 8'b0;
endmodule

module A_save_ff (
    input [7:0] A_in,
    input clk,
    input reset,
    input A_save_sel,
    output reg [7:0] A_out
);
    always_ff @(posedge clk, posedge reset) begin : A_Reg
        if (reset) begin
            A_out <= 1'bz;
        end else if (A_save_sel) begin
            A_out <= A_in;
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
