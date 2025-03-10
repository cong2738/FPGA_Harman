`timescale 1ns / 1ps

module tb_8bit_adder ();
    reg [7:0] A, B;
    wire [7:0] S;
    wire C;

    //dut(disign under test) uut(unit under test)
    bit8adder dut (
        .A(A),
        .B(B),
        .S(S),
        .over(C)
    );

    integer i, j;
    initial begin
        A = 8'h0;
        B = 8'h0;
        #1;
        for (i = 0; i <= 256; i = i + 1) begin
            A = i;
            for (j = 0; j <= 256; j = j + 1) begin
                B = j;
                #1;
            end
        end
    end
endmodule
