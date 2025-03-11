`timescale 10ns / 10ns


module tb_stopwatch ();

    reg clk;
    reg reset;
    reg sw_mod;
    reg btn_run_stop;
    reg btn_clear;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    wire w_run_stop, w_clear;
    wire o_btn_run_stop, o_btn_clear;
    btn_debounce U_BTN_Debounce_RUN_STOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_stop),   // from btn
        .o_btn(o_btn_run_stop)  // to control unit
    );
    btn_debounce U_BTN_Debounce_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear),   // from btn
        .o_btn(o_btn_clear)  // to control unit
    );

    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),  // input 
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    wire [$clog2(100)-1:0] w_msec;
    wire [$clog2(60)-1:0] w_sec, w_min;
    wire [$clog2(24)-1:0] w_hour;
    stopwatch_dp U_DP (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_run_stop),
        .i_clear(w_clear),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    fnd_controller #(
        .MSEC_MAX(100),
        .SEC_MAX (60),
        .MIN_MAX (60),
        .HOUR_MAX(24)
    ) U_fnd_cntl (
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
        #10;
        btn_run_stop = 0;
        btn_clear = 1;
    end

endmodule
