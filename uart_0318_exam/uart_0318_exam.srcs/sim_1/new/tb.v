`timescale 1ns / 1ps

module tb_rx ();
    reg  clk;
    reg  rst;
    // reg btn;
    // wire tx;

    reg  rx;
    wire tx;
    wire [7:0] fnd_font;
    wire [3:0] fnd_comm;

    TOP_UART DUT (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    always #5 clk = ~clk;

    integer i;
    reg[7:0] rx_data;
    initial begin
        rx_data = 8'h88;
        clk = 0;
        rst = 1;
        rx  = 1;
        #100 rst = 0;
        rx = 1;
        #100;
        rx = 0;
        #104160;

        for (i = 0; i < 8; i = i + 1) begin
            rx = rx_data[i];
        #104160;
        end
        rx = 1;
        #104160;

    end
endmodule

