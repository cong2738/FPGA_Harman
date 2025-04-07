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
    logic [7:0] A_0_out;
    logic [7:0] A_regout;
    logic [7:0] sum_0_out;
    logic [7:0] sum_regout;
    logic [7:0] adder_o;
    logic [7:0] add_mux_o;
    Mux_2x1 U_A_initial (
        .mux_sel(A_0_sel),
        .one    (adder_o),
        .zero   (0),
        .mux_out(A_0_out)
    );
    Mux_2x1 U_sum_initial (
        .mux_sel(sum_0_sel),
        .one    (adder_o),
        .zero   (0),
        .mux_out(sum_0_out)
    );
    save_ff U_A_Reg (
        .clk     (clk),
        .reset   (reset),
        .save_sel(A_save_sel),
        .in      (A_0_out),
        .out     (A_regout)
    );
    save_ff U_Sum_Reg (
        .clk     (clk),
        .reset   (reset),
        .save_sel(sum_save_sel),
        .in      (sum_0_out),
        .out     (sum_regout)
    );
    Mux_2x1 u_adderMux (
        .mux_sel(add_sel),
        .one    (1),
        .zero   (sum_regout),
        .mux_out(add_mux_o)
    );
    adder U_Adder (
        .A  (add_mux_o),
        .B  (A_regout),
        .sum(adder_o)
    );
    save_ff u_save_ff(
        .clk      (clk      ),
        .reset    (reset    ),
        .save_sel (out_sel ),
        .in       (sum_regout       ),
        .out      (sum_out      )
    );
    
    comp U_A_UT_Ten (
        .A       (A_regout),
        .B       (10),
        .comp_out(comp_Aand10)
    );
endmodule

module Mux_2x1 (
    input  logic       mux_sel,
    input  logic [7:0] one,
    input  logic [7:0] zero,
    output logic [7:0] mux_out
);
    always_comb begin : Mux_2x1
        mux_out = 0;
        case (mux_sel)
            0: mux_out = zero;
            1: mux_out = one;
        endcase
    end
endmodule

module save_ff (
    input  logic       clk,
    input  logic       reset,
    input  logic       save_sel,
    input  logic [7:0] in,
    output logic [7:0] out
);
    always_ff @(posedge clk, posedge reset) begin : A_Reg
        if (reset) begin
            out <= 0;
        end else if (save_sel) begin
            out <= in;
        end
    end
endmodule

module adder (
    input  logic [7:0] A,
    input  logic [7:0] B,
    output logic [7:0] sum
);
    always_comb begin : adder_logic
        sum = A + B;
    end
endmodule

module comp (
    input  logic [7:0] A,
    input  logic [7:0] B,
    output logic       comp_out
);
    assign comp_out = (A <= B) ? 1'b1 : 1'b0;
endmodule

module out_buffer (
    input  logic       out_sel,
    input  logic [7:0] A,
    output logic [7:0] out
);
    assign out = out_sel ? A : out;
endmodule
