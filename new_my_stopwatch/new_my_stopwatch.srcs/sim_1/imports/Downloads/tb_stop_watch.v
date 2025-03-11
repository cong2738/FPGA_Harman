`timescale 1ns / 1ps


module tb_stopwatch ();

    reg clk, reset, run, clear, sw_mod;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;


    Top_Upcounter DUT_Top (
        .clk(clk),
        .reset(reset),
        .sw_mod(sw_mod),
        .btn_run_stop(run),
        .btn_clear(clear),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );

    wire w_msec,w_sec,w_min,w_hour;
    fnd_controller #(.BCD_MAX(100)) DUT_Fnd_Controller (
        .clk(clk),
        .reset(reset),
        .sw_mod(sw_mod),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );
    integer i;
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        run = 0;
        clear = 0;
        sw_mod = 0;
        run = 1;
        #10;
        reset = 0;
        #10;
        wait(w_min ==1);

        run   = 0;
        clear = 1;
    end

endmodule
