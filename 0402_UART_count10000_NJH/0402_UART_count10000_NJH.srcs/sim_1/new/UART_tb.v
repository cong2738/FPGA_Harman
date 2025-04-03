`timescale 1ns / 1ps

module UART_tb ();
    reg clk;
    reg reset;
    reg tx_trigger;
    reg [7:0] tx_data;
    reg rx; 
    wire tx;
    wire tx_done;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    wire rx_busy;

    uart u_uart (
        .clk       (clk),
        .reset     (reset),
        .tx_trigger(tx_trigger),
        .tx_data   (tx_data),
        .rx        (tx),

        .tx     (tx),
        .tx_done(tx_done),
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        tx_trigger = 0;
        tx_data = 0;
        rx = 0;
        #10 reset = 0;
        @(posedge clk);
        #1;
        tx_data = 8'b11001010;
        tx_trigger = 1;

        @(posedge clk);
        #1;
        tx_trigger = 0;

        @(posedge tx_done);
        #20;
        $finish;
    end

endmodule
