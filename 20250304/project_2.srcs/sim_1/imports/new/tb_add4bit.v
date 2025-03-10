`timescale 1ns / 1ps

module tb_add4bit ();
    reg [3:0] A, B;
    wire [3:0] S;
    wire C;

    //dut(disign under test) uut(unit under test)
    bit4adder dut (
        .A(A),
        .B(B),
        .S(S),
        .over(C)
    );

    integer i, j;
    initial begin
        A = 3'h0;
        B = 3'h0;
        #1;
        for (i = 0; i <= 16; i = i + 1) begin
            A = i;
            for (j = 0; j <= 16; j = j + 1) begin
                B = j;
                #1;
            end
        end
    end
endmodule
