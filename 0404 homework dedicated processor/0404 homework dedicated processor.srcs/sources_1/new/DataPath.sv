`timescale 1ns / 1ps

module DataPath (
    input clk,
    input reset,
    input A_0_sel,
    input sum_0_sel,
    input A_save_sel,
    input sum_save_sel,
    input out_sel,
    output comp_Aand10,
    output [7:0] sum_out
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
    wire [7:0] App;
    wire [7:0] sum_0_out;
    wire [7:0] added_sum;
    wire [7:0] sum_regout;
    A_0_Mux U_A_initial (
        .A(App),
        .A_0_sel(A_0_sel),
        .A_0_out(A_0_out)
    );
    A_0_Mux U_sum_initial (
        .A(added_sum),
        .A_0_sel(sum_0_sel),
        .A_0_out(sum_0_out)
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
    adder U_APP (
        .A  (A_regout),
        .B  (1),
        .sum(App)
    );
    adder U_sum (
        .A  (sum_regout),
        .B  (A_regout),
        .sum(added_sum)
    );
    out_buffer U_out (
        .A(sum_regout),
        .out_sel(out_sel),
        .out(sum_out)
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
