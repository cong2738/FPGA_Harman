`timescale 1ns / 1ps


module add_4bit(
        input A,
        input B,
        input C,
        input D
    );
    full_adder U1(
        .A(B),
        .B(B),
        .C(),
    );
    full_adder U1();
    full_adder U1();
    full_adder U1();
endmodule
