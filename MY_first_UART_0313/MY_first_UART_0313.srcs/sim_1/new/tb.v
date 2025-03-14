`timescale 1ns / 1ps

module tb ();
    reg clk;
    reg rst;
    reg btn;
    wire tx;

    uart #(100)DUT (
        .clk(clk),
        .rst(rst),
        .btn_start(btn),
        .tx(tx)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;    
        rst = 1;
        wait(DUT.tx == 0);
        rst = 0;
        #10;
        btn = 1;
        wait(DUT.tx == 1);
        btn = 0;
    end
endmodule
