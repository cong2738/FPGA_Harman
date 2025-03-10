`timescale 1ns / 1ps

module tb_full_adder();
    reg A, B, C_in;
    wire S, C;

    full_adder U_adder( 
        .A(A),
        .B(B),
        .C_in(C_in),
        .S(S),
        .C(C)
    );

    initial begin
        #10;    A=0; B=0; C_in=0;
        #10;    A=1; B=0; C_in=0;
        #10;    A=0; B=1; C_in=0;
        #10;    A=1; B=1; C_in=0;
        #10;    A=0; B=0; C_in=1;
        #10;    A=1; B=0; C_in=1;
    end
endmodule
