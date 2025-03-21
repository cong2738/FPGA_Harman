`timescale 1ns / 1ps

module tb_fifo ();
    reg  clk;
    reg  rst;
    reg  rx;
    wire tx;
    Top_UART_String uut (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx)
    );

    task send_data(input [7:0] data);
        integer i;
        begin
            $display("Sending data %h", data);

            //Start bit(Low)
            rx = 0;
            #(10 * 10417);  //Baud rage에 따른 시간지연 (9600bps기준)

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
