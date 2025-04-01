`timescale 1ns / 1ps

module top #(
    parameter COUNT_MAX = 9999
) (
    input clk,
    input reset,
    input sw,
    output [7:0] seg,
    output [3:0] an
);
    wire [$clog2(9999)-1:0] count;
    count10000_module #(
        .COUNT_MAX(10000)
    ) u_count10000_module (
        .clk  (clk),
        .reset(reset),
        .sw   (sw),
        .count(count)
    );

    fnd_ctrl u_fnd_ctrl (
        .clk  (clk),
        .reset(reset),
        .bcd  (count),
        .seg  (seg),
        .an   (an)
    );

endmodule
