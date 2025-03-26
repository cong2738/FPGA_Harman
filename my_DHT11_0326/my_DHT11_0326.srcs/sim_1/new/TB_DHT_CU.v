`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 12:13:23
// Design Name: 
// Module Name: TB_DHT_CU
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


module TB_DHT_CU ();
    reg clk;
    reg rst;
    reg btn_start;
    wire sensor_LED;
    wire [3:0] current_state;
    wire data;
    wire dht_IO;
    TOP_DHT11 uut (
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start),
        .sensor_LED(sensor_LED),
        .current_state(current_state),
        .data(data),
        .dht_IO(dht_IO)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #100 rst = 0;
        btn_start = 1;
    end
endmodule
