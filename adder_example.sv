`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/24
// Design Name: Adder Example
// Module Name: adder_example
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module demonstrates an adder using both combinational and
//              sequential logic.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module adder_example #(
    parameter WIDTH = 8
) (
    input                       clk,
    input                       reset,
    input      [WIDTH-1:0]      a,
    input      [WIDTH-1:0]      b,
    output logic [WIDTH:0]      sum_comb, // Combinational output (WIDTH+1 for carry)
    output logic [WIDTH:0]      sum_seq   // Sequential output (WIDTH+1 for carry)
);

    // Combinational Adder Block
    // The output 'sum_comb' is updated immediately whenever inputs 'a' or 'b' change.
    always_comb begin
        sum_comb = a + b;
    end

    // Sequential Adder Block
    // The result of 'a + b' is registered into 'sum_seq' on the rising edge of the clock.
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_seq <= '0; // Reset the sequential sum to 0
        end else begin
            sum_seq <= a + b; // On clock edge, calculate and store the sum
        end
    end

endmodule

