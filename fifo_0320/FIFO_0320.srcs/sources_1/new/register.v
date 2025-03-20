`timescale 1ns / 1ps
/*
    * register.v
    *
    *  Created on: 2021/03/19
*/
module register (
    input clk,
    input [31:0] data,
    output [31:0] q
);

    reg [31:0] q_reg;  // 32bit memory
    assign q = q_reg;

    always @(posedge clk) begin
        q_reg <= data;
    end

endmodule
