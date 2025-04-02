`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 11:22:02
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
    reg        clk;
    reg        reset;
    reg        mode;
    reg        run;
    reg        clear;
    wire [3:0] fndCom;
    wire [7:0] fndFont; 
    top_counter_up_down u_top_counter_up_down (
        .clk        (clk),
        .reset      (reset),
        .mode       (mode),
        .run        (run),
        .clear      (clear),
        .fndCom     (fndCom),
        .fndFont    (fndFont)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        mode  = 0;
        run   = 1;
        clear = 0;
        #100;
        reset = 0;
    end

endmodule
