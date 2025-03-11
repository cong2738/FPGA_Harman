`timescale 10ns / 10ns


module tb_stopwatch ();

    reg clk;
    reg reset;
    reg sw_mod;
    reg btn_run_stop;
    reg btn_clear;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    Top_Upcounter DUC (
    .clk(clk),
    .reset(reset),
    .sw_mod(sw_mod),
    .btn_run_stop(btn_run_stop),
    .btn_clear(btn_clear),
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font)
);

    always #1 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        btn_run_stop = 0;
        btn_clear = 0;
        sw_mod = 0;
        btn_run_stop = 1;
        #10;
        reset = 0;
    end

endmodule
