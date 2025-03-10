`timescale 1ns / 1ps

module tb_clk_divider ();
    reg clk, reset, run, clear;
    wire o_clk;

    clk_divider #(
        .FCOUNT(1_000_000)
    ) DUT (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .o_clk(o_clk)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        run   = 1;
        clear = 0;
        #10 reset = 0;
        #100; run = 0;
        

    end

endmodule
