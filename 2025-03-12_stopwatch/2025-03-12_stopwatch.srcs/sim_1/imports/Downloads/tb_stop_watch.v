`timescale 10ns / 1ns 
//기본클럭 100Mhz -> 10ns 기준으로 단위시간, 정확도는1ns(1ns주기 틱으로 샘플링)

module tb_stopwatch ();
    reg clk;
    reg reset;
    reg sw_mod;
    reg btn_run_stop;
    reg btn_clear;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    Top_Upcounter #(
        .COUNT_100HZ(),
        .MSEC_MAX(100),
        .SEC_MAX(60),
        .MIN_MAX(60),
        .HOUR_MAX(24)
    ) DUC (
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
        btn_run_stop = 1;
        btn_clear = 0;
        sw_mod = 0;
        #10;
        reset = 0;
        wait(DUC.U_DP.min == 1);
        sw_mod = 1;
    end

endmodule
