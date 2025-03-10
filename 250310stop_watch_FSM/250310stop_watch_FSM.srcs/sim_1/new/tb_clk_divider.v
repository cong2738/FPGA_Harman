`timescale 1ns / 1ps

module tb_clk_divider ();
    reg clk, reset, run, clear;
    wire[6:0] msec,sec,min,hour;

    stopwatch_dp#(10_000) dut(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        run   = 1;
        clear = 0;

        #10 reset = 0;
        wait(sec == 2);

        #10; run = 0;
        

    end

endmodule
