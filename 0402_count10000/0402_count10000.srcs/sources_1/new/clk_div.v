`timescale 1ns / 1ps
module clk_div #(
    parameter MAX_COUNT = 100_000_000
) (
    input clk,
    input reset,
    output reg tick
);
    reg [$clog2(MAX_COUNT)-1:0] div_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 0;
        end else begin
            if (div_counter == MAX_COUNT - 1) begin
                div_counter <= 0;
                tick <= 1;
            end else begin
                tick <= 0;
                div_counter <= div_counter + 1;
            end
        end
    end

endmodule
