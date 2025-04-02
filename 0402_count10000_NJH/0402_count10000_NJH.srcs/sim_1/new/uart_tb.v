`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 15:36:28
// Design Name: 
// Module Name: uart_tb
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


module uart_tb ();
    localparam IDLE = 0, WAIT = 1, DATA = 2, STOP = 3;
    reg    clk;
    reg    reset;
    reg    rx;
    wire   tx;
    wire[7:0] rx_data;
    top_counter_up_down utt (
        .clk    (clk),
        .reset  (reset),
        .rx     (rx),
        .tx     (tx),
        .rx_data(rx_data)
    );


    task send_data(input [7:0] data);
        integer i;
        begin
            $display("sending data: %h", data);

            rx = 0;
            #104170;

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #104170;
            end
            rx = 1;
            #104170;

            $display("Data sent:%h", data);

        end
    endtask

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        clk   = 0;
        #100;
        reset = 0;
        #100;
        rx = 0;
        wait (utt.u_UART.u_rx.state == WAIT);
        rx = 1;
        wait (utt.u_UART.u_rx.state == DATA);
        send_data("r");
        wait (utt.u_UART.u_rx.state == STOP);
        rx = 1;
        wait (utt.u_UART.u_rx.state == IDLE);
        rx = 1;
        #10000;
        $stop;
    end

endmodule
