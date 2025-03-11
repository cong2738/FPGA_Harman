`timescale 1ns / 1ps


module tb_stopwatch ();

    reg clk, reset, run, clear;
    wire [6:0] msec, sec, min, hour;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;


    top_stopwatch uclk (
        .clk(clk),
        .reset(reset),
        .btn_run_stop(run),
        .btn_clear(clear),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );
    stopwatch_dp udp (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .msec (msec),
        .sec  (sec),
        .min  (min),
        .hour (hour)
    );


    always #0.05 clk = ~clk;
    initial begin
        clk   = 0;
        reset = 1;
        run   = 0;
        clear = 0;
        #10;
        reset = 0;
        run   = 1;
        #10;
        wait (min == 1);
        #1000000;
        run   = 0;
        clear = 1;


        #100000;
        #10;



    end

endmodule
