`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 16:38:18
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo ();
    reg clk;
    reg rst;
    reg wr;
    reg rd;
    reg [7:0] w_data;
    wire full;
    wire empty;
    wire [7:0] r_data;
    fifo uut (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .full(full),
        .empty(empty),
        .w_data(w_data),
        .r_data(r_data)
    );

    always #5 clk = ~clk;
    integer i;
    initial begin
        clk = 0;
        rst = 1;
        w_data = 8'b00;
        wr = 0;
        rd = 0;
        #10;
        rst = 0;
        #10;
        wr = 1;
        for (i = 0; i < 15; i = i + 1) begin
            #10;
            w_data = $random%256;
        end
        #10;
        wr = 0;
        rd = 1;
        for (i = 0; i < 15; i = i + 1) begin
            #10;
        end
        $finish;
    end
endmodule
