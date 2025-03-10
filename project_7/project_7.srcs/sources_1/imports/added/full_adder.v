`timescale 1ns / 1ps

module full_adder (
    input  A, B,
    input  C_in,
    output S,C
);

    wire w_S1, w_C1, w_S2, w_C2;

    half_adder U_half_adder1 (
        .A(A),
        .B(B),
        .S(w_S1),
        .C(w_C1)
    );

    half_adder U_half_adder2 (
        .A(w_S1),
        .B(C_in),
        .S(w_S2),
        .C(w_C2)
    );

    assign S = w_S2;

    assign C = w_C1 | w_C2;

endmodule
