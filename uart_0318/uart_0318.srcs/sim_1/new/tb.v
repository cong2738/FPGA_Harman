`timescale 1ns / 1ps

module tb_rx ();
    reg clk;
    reg rst;
    // reg btn;
    // wire tx;

    reg rx;
    wire tx;

    TOP_UART DUT (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;
        #100 rst = 0;
        rx = 1;
        #100;
        rx = 0;
        #104160;
        rx = 1;
        #104160;
        rx = 0;
        #104160;
        rx = 1;
        #104160;
        rx = 0;
        #104160;
        rx = 1;
        #104160;
        rx = 1;
        #104160;
        rx = 0;
        #104160;
        rx = 0;
        #104160;
        rx = 1;
        #104160;


    end
endmodule

