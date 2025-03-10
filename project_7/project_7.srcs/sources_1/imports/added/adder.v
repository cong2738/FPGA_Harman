`timescale 1ns / 1ps

module half_adder (
    input  A,
    input  B,
    output S,
    output C
);
    // assign S = A ^ B;
    // assign C = A & B;
    
    // 게이트 프리미티브 (출력,입력1,입력2,...)
    xor (S, A, B);
    and (C, A, B);

endmodule