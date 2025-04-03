`timescale 1ns / 1ps
module tb_stopwatch ();
    reg clk;
    reg reset;
    reg en;
    reg clear;
    wire [13:0] t;
    wire [3:0] dot_data;
    my_stopWatch #(100) u_my_stopWatch (
        .clk     (clk),
        .reset   (reset),
        .en      (en),
        .clear   (clear),
        .t       (t),
        .dot_data(dot_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        en = 1;
        clear = 0;
        #100;
        reset = 0;
        wait(t == 9999);
    end

endmodule
