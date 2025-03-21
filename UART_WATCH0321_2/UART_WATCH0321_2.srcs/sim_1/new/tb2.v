`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 16:04:05
// Design Name: 
// Module Name: tb2
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


module tb2 ();
    reg  clk;
    reg  rst;
    reg hs_mod_sw = 0;
    reg watch_mod_sw = 0;
    reg btnU = 0;
    reg btnL = 0;
    reg btnR = 0;
    reg btnD = 0;
    reg  rx;
    wire tx;
    top_my_watch uut (
        .clk(clk),
        .reset(rst),
        .hs_mod_sw(hs_mod_sw),
        .watch_mod_sw(watch_mod_sw),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .rx(rx),
        .tx(tx),
        .fnd_comm(),
        .fnd_font(),
        .mod_indicate_led()
    );
    
    task send_data(input [7:0] data);
        integer i;
        begin
            $display("Sending data %h", data);

            //Start bit(Low)
            rx = 0;
            #(10 * 10417);  //Baud rage�뿉 �뵲瑜� �떆媛꾩��뿰 (9600bps湲곗�)

            //Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(10 * 10417);
            end

            //Stop bit(High)
            rx = 1;
            #(10 * 10417);

            $display("Data sent: %h", data);
        end
    endtask

    always #5 clk = ~clk;

    integer i;
    reg [7:0] rx_data;
    initial begin
        rx_data = "0";
        clk = 0;
        rst = 1;
        rx = 1;
        #50 rst = 0;
        #10000;

        for (i = 0; i < 16; i = i + 1) begin
            send_data(rx_data);
            wait (uut.U_UART.rx_done);
            rx_data = rx_data + 1;
        end

        #10000;

        wait (uut.U_UART.tx_busy);
        wait (!uut.U_UART.tx_busy);
        $stop;


    end

endmodule

