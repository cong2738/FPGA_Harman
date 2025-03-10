`timescale 1ns / 1ps

module bit4adder (
    input [3:0] A,
    input [3:0] B,
    // input c_in,
    output [3:0] S,
    output over
);
    // wire[4:0] c;
    // full_adder U0 (
    //     .A(A[0]),
    //     .B(B[0]),
    //     .C_in(0),
    //     .S(S[0]),
    //     .C(c[1])
    // );
    // for (genvar i = 1; i < 3; i = i + 1) begin
    //     full_adder U1 (
    //     .A(A[i]),
    //     .B(B[i]),
    //     .C_in(c[i]),
    //     .S(S[i]),
    //     .C(c[i+1])
    // );
    // end
    // over = c[4];
    
    wire c_0, c_1, c_2;
    full_adder r0 (
        .A(A[0]),
        .B(B[0]),
        .C_in(1'b0),
        .S(S[0]),
        .C(c_0)
    );
    full_adder r1 (
        .A(A[1]),
        .B(B[1]),
        .C_in(c_0),
        .S(S[1]),
        .C(c_1)
    );
    full_adder r2 (
        .A(A[2]),
        .B(B[2]),
        .C_in(c_1),
        .S(S[2]),
        .C(c_2)
    );
    full_adder r3 (
        .A(A[3]),
        .B(B[3]),
        .C_in(c_2),
        .S(S[3]),
        .C(over)
    );
endmodule

