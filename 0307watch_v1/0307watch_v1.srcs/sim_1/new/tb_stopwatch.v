`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/07 16:06:39
// Design Name: 
// Module Name: tb_stopwatch
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


module tb_stopwatch(

    );

    reg clk,reset,w_clear,w_tick_100hz;
    wire [16:0]w_count;
    wire w_tick_msec;
    
    count_tick #(
        .COUNT(10_000)
    ) dut (
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_point_sec),
        .o_tick(w_tick_100)
    );

    integer i;
    always #5 clk = ~clk;
    initial begin
        clk = 0; reset = 1; w_clear = 0; w_tick_100hz = 0;
        #10 reset = 0;
        for (i = 0;  i < 110; i= i+1) begin
            #10 w_tick_100hz = 1;
            #10 w_tick_100hz = 0;
        end
        #10;
        $STOP;
    end
endmodule
