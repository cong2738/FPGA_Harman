`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/01 11:48:29
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb ();
    reg clk;
    reg reset;
    reg sw;
    wire [7:0] seg;
    wire [3:0] an;
    top u_top (
        .clk  (clk),
        .reset(reset),
        .sw   (sw),
        .seg  (seg),
        .an   (an)
    );
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        sw = 0;
        reset =1;
        #10;
        reset = 0;
        
    end

endmodule
