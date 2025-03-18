`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/18 17:36:21
// Design Name: 
// Module Name: tb_fnd_controller
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


module tb_fnd_controller ();
    reg clk;
    reg reset;
    reg hs_mod_sw;
    reg [3:0] msec;
    reg [3:0] sec;
    reg [3:0] min;
    reg [3:0] hour;
    wire [7:0] fnd_font;
    wire [3:0] fnd_comm;

    hnd_controller UUT (
        .clk(clk),
        .reset(reset),
        .hs_mod_sw(hs_mod_sw),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        msec  = 0;
        sec   = 0;
        min   = 0;
        hour  = 0;
        #10 reset = 0;
    end

endmodule
