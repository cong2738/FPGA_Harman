`timescale 1ns / 1ps

module ALU (
    input  logic [2:0] aluOP,
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] res
);
    typedef enum int {
        ADD = 3'b000,
        SUB = 3'b001,
        AND = 3'b010,
        OR  = 3'b011,
        XOR = 3'b100,
        NOT = 3'b101,
        LT = 3'b110,
        EQ = 3'b111
    } opperation;

    always_comb begin : ALU
        case (aluOP)
            ADD: res = a + b;
            SUB: res = a - b;
            OR: res =  a | b;
            AND: res = a & b;
            XOR: res = a ^ b;
            NOT: res = ~a;
            NOT: res = a < b;
            NOT: res = a == b;
            default: res = 8'bz;
        endcase
    end
endmodule


