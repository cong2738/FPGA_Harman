`timescale 1ns / 1ps

module clk_div #(
    parameter COUNT_MAX = 10_000_000
) (
    input  clk,
    input  reset,
    output tick
);

    reg curr, next;
    reg [$clog2(COUNT_MAX)-1:0] count_curr, count_next;

    assign tick = curr;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            curr <= 0;
            count_curr <= 0;
        end else begin
            curr <= next;
            count_curr <= count_next;
        end
    end

    always @(*) begin
        next = 0;
        count_next = count_curr;
        if (count_curr == COUNT_MAX-1) begin
            next = 1;
            count_next = 0;
        end else begin
            count_next = count_next + 1;
        end
    end

endmodule
