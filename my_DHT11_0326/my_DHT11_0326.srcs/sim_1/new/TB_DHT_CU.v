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


// module TB_DHT_CU ();
//     reg clk;
//     reg rst;
//     reg btn_start;
//     wire sensor_LED;
//     wire data;
//     wire dht_IO;
//     TOP_DHT11 uut (
//         .clk(clk),
//         .rst(rst),
//         .btn_start(btn_start),
//         .sensor_LED(sensor_LED),
//         .dht_IO(dht_IO)
//     );

//     always #5 clk = ~clk;

//     initial begin
//         clk = 0;
//         rst = 1;
//         btn_start = 0;
//         #100 rst = 0;
//         btn_start = 1;
//     end
// endmodule

module tb_dht11();

    reg clk;
    reg reset;
    reg btn_start;

    reg dht_sensor_data;
    reg io_oe;

    wire [3:0] led;
    wire dht_io;

    // tb io mode 변환
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    TOP_DHT11 dut (
        .clk(clk),
        .rst(reset),
        .btn_start(btn_start),
        .sensor_LED(led),
        .dht_IO(dht_io) // inout port
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        io_oe = 0;
        btn_start = 0;

        #100;
        reset = 0;
        #100;
        btn_start = 1;
        #100;
        btn_start = 0;
        #10000;
        // 18msec 대기
        wait(dht_io);
        #30000;
        // 입력 모드로 변환
        io_oe = 1;
        dht_sensor_data = 1'b0;
        #80000;
        dht_sensor_data = 1'b1;
        #80000;
        #50000;
        $stop;  
    end

endmodule
