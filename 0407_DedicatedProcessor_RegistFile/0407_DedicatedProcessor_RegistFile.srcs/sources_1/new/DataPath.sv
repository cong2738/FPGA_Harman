`timescale 1ns / 1ps

module DataPath (
    input  logic       clk,
    input  logic       reset,
    input  logic       mux_sel01,
    input  logic       initial_sig,
    input  logic       wen,
    input  logic [2:0] wptr,
    input  logic [2:0] rptr1,
    input  logic [2:0] rptr2,
    input  logic       out_sel,
    output logic       comp_10,
    output logic [7:0] out_data
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

    logic [7:0] mux_out;
    logic [7:0] rdata1;
    logic [7:0] rdata2;
    logic [7:0] sum;

    Mux_2x1 initial_1_to_file (
        .mux_sel(initial_sig),
        .one    (1),
        .zero   (sum),
        .mux_out(mux_out)
    );

    RegFile u_RegFile (
        .clk   (clk),
        .wen   (wen),
        .wdata (mux_out),
        .wptr  (wptr),
        .rptr1 (rptr1),
        .rptr2 (rptr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    adder u_adder (
        .A  (rdata1),
        .B  (rdata2),
        .sum(sum)
    );

    comp u_comp (
        .A       (rdata1),
        .B       (10),
        .comp_out(comp_10)
    );

    save_ff u_out_buffer (
        .clk     (clk),
        .reset   (reset),
        .save_sel(out_sel),
        .in      (rdata1),
        .out     (out_data)
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

module RegFile (
    input  logic       clk,
    input  logic       wen,
    input  logic [7:0] wdata,
    input  logic [2:0] wptr,
    input  logic [2:0] rptr1,
    input  logic [2:0] rptr2,
    output logic [7:0] rdata1,
    output logic [7:0] rdata2
);
    logic [7:0] mem[0:7];

    assign mem[0] = 0;

    always_ff @(posedge clk) begin : WRITE
        if (wen) mem[wptr] <= wdata;
    end

    always_comb begin : READ
        rdata1 = mem[rptr1];
        rdata2 = mem[rptr2];
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
