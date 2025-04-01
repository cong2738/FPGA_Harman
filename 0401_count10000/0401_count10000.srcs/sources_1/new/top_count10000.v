`timescale 1ns / 1ps

module top_count10000 #(
    parameter MAX_COUNT = 9999
) (
    input clk,
    input reset,
    input mode_sw,
    output [7:0] seg,
    output [3:0] an
);
    wire [$clog2(MAX_COUNT)-1:0] count;
    counter_10000 u_counter_10000 (
        .clk    (clk),
        .reset  (reset),
        .mode_sw(mode_sw),
        .count  (count)
    );

    fnd_controller u_fnd_controller (
        .clk  (clk),
        .reset(reset),
        .num  (count),
        .seg  (seg),
        .an   (an)
    );

endmodule
