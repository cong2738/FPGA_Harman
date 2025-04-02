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

    blink_dot u_blink_dot (
        .bcd    (count),
        .dot_off(dot_off)
    );

    fnd_controller u_fnd_controller (
        .clk  (clk),
        .reset(reset),
        .num  (count),
        .dot_off(dot_off),
        .seg  (seg),
        .an   (an)
    );

endmodule

module blink_dot (
    input [$clog2(9999)-1:0] bcd,
    output reg dot_off
);
    always @(*) begin
        dot_off = 1;
        if (bcd % 10 < 5) begin
            dot_off = 0;
        end
    end
endmodule
