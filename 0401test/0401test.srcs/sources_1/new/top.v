`timescale 1ns / 1ps

module top #(
    parameter COUNT_MAX = 9999
) (
    input clk,
    input reset,
    input sw,
    output [6:0] fnd,
    output dot,
    output [3:0] cmm
);
    clk_div CLK_100ms (
        .clk  (clk),
        .reset(reset),
        .tick (clk_100ms)
    );

    wire [$clog2(COUNT_MAX)-1:0] count;
    counter #(
        .COUNT_MAX(9999)
    ) u_counter (
        .clk  (tick),
        .reset(reset),
        .sw   (sw),
        .count(clk_100ms)
    );

endmodule

module counter #(
    parameter COUNT_MAX = 9999
) (
    input clk,
    input reset,
    input sw,
    output [$clog2(COUNT_MAX)-1:0] count
);
    reg [$clog2(COUNT_MAX)-1:0] count_curr, count_next;

    assign count = count_curr;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_curr <= 0;
        end else begin
            count_curr <= count_next;
        end
    end

    always @(*) begin
        count_next = count_curr;
        if (count_curr == COUNT_MAX - 1) begin
            count_next = 0;
        end else if (count_curr == 0) begin
            count_next = 9999;
        end else if (sw) begin
            count_next = count_next - 1;
        end else begin
            count_next = count_next + 1;
        end
    end

endmodule
