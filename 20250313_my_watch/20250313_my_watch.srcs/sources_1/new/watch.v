`timescale 1ns / 1ps

module watch #(
    parameter COUNT_100HZ = 1_000_000,
    parameter MSEC_MAX  = 100,
    parameter SEC_MAX   = 60,
    parameter MIN_MAX   = 60,
    parameter HOUR_MAX  = 24
) (
    input clk,
    input reset,
    output [$clog2(MSEC_MAX)-1:0] msec,
    output [$clog2(SEC_MAX)-1:0] sec,
    output [$clog2(SEC_MAX)-1:0] min,
    output [$clog2(HOUR_MAX)-1:0] hour
);
    stopwatch #(
    .COUNT_100HZ(COUNT_100HZ),
    .MSEC_MAX(MSEC_MAX),
    .SEC_MAX(SEC_MAX),
    .MIN_MAX(MIN_MAX),
    .HOUR_MAX(HOUR_MAX)
) (
    .clk(clk),
    .reset(reset),
    .btn_run_stop(1),
    .btn_clear(0),
    .w_msec(msec),
    .w_sec(sec),
    .w_min(min),
    .w_hour(hour)
);

endmodule
