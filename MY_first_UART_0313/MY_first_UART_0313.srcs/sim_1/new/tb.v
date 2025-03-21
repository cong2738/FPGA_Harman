`timescale 10ns / 1ns

module tb ();
    reg clk;
    reg rst;
    reg btn;
    wire tx;

    uart #(100)DUT (
        .clk(clk),
        .rst(rst),
        .btn_start(btn),
        .uart_data(8'h30),
        .tx(tx),
        .tx_busy()
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;    
        rst = 1;
        wait(DUT.tx == 1);
        rst = 0;
        #10;
        btn = 1;
        wait(DUT.tx == 0);
        btn = 0;
    end
endmodule


