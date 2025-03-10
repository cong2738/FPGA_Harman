`timescale 1ns / 1ps

module bit4adder (
    input [3:0] A,
    input [3:0] B,
    output [3:0] S,
    output over
);
    wire [4:0] c;
    assign c[0] = 0;  // 초기 캐리 입력을 0으로 설정

    for (genvar i = 0; i < 4; i = i + 1) begin
        full_adder U (
            .A(A[i]),
            .B(B[i]),
            .C_in(c[i]),
            .S(S[i]),
            .C(c[i+1])
        );
    end

    assign over = c[4];  // 최종 캐리 출력을 over에 할당
endmodule

module bit8adder (
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output over
);
    wire [8:0] c;
    assign c[0] = 0;  // 초기 캐리 입력을 0으로 설정

    for (genvar i = 0; i < 8; i = i + 1) begin
        full_adder U (
            .A(A[i]),
            .B(B[i]),
            .C_in(c[i]),
            .S(S[i]),
            .C(c[i+1])
        );
    end

    assign over = c[8];  // 최종 캐리 출력을 over에 할당
endmodule
