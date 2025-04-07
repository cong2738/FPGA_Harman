`timescale 1ns / 1ps

module top_DedicatedProcessor (
    input clk,
    input reset,
    output [7:0] sum_out
);
    ControlUnit u_ControlUnit (
        .clk         (clk),
        .reset       (reset),
        .comp_Aand10 (comp_Aand10),
        .A_0_sel     (A_0_sel),
        .sum_0_sel   (sum_0_sel),
        .A_save_sel  (A_save_sel),
        .sum_save_sel(sum_save_sel),
        .add_sel     (add_sel),
        .out_sel     (out_sel)
    );

    DataPath u_DataPath (
        .clk         (clk),
        .reset       (reset),
        .A_0_sel     (A_0_sel),
        .sum_0_sel   (sum_0_sel),
        .A_save_sel  (A_save_sel),
        .sum_save_sel(sum_save_sel),
        .add_sel     (add_sel),
        .out_sel     (out_sel),
        .comp_Aand10 (comp_Aand10),
        .sum_out     (sum_out)
    );

endmodule
