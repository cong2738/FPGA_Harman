`timescale 1ns / 1ps

module DataPatch (
    input logic clk,
    input logic reset,
    input logic ASrcMuxSel,
    input logic AEn,
    output logic ALt10,
    input logic OutBuf,
    output logic [7:0] outPort
);

    mux_0_data u_mux_0_data (
        .d  (sum),
        .sel(ASrcMuxSel),
        .d_o(mux_0_data_o)
    );

    register u_register (
        .clk  (clk),
        .reset(reset),
        .en   (AEn),
        .d    (mux_0_data_o),
        .q    (register_o)
    );

    adder u_adder (
        .a  (register_o),
        .b  (1),
        .sum(sum)
    );

    comparator u_while_comparator (
        .a (register_o),
        .b (10),
        .lt(ALt10)
    );
    buffer u_buffer (
        .d_i(register_o),
        .en (OutBuf),
        .d_o(buffer_o)
    );

endmodule

module mux_0_data (
    input  d,
    input  sel,
    output d_o
);
    assign d_o = sel ? d : 0;
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
    end
endmodule

module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic lt
);
    assign lt = a < b;
endmodule

module buffer (
    input logic [7:0] d_i,
    input logic en,
    output logic [7:0] d_o
);
    assign d_o = en ? d_i : 8'bz;
endmodule

/*
a = 0;
sum = 0;
while(a < 10) {
    sum = sum + a;
    a = a + 1;
}
halt;
*/
