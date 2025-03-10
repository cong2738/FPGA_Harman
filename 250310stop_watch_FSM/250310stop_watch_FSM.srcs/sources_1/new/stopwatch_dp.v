`timescale 1ns / 1ps

module stopwatch_dp (
    input clk,
    input reset,
    input run,
    input clear,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [6:0] hour
);

clk_divider #(
    .FCOUNT(1_000_000)
) (
    .clk(),
    .reset(),
    .o_clk()
);

endmodule

module clk_divider #(
    parameter FCOUNT = 1_000_000
) (
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  //출력을 f/f으로 내보내기 위해 사용

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_next <= 0;
            clk_reg <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg   <= clk_next;
        end
    end

    always @(*) begin
        if (count_next == FCOUNT - 1) begin
            count_next = 0;
            clk_next   = 1'b1;
        end else begin
            count_next = count_next + 1;
            clk_next = 1'b0;
        end
    end

    assign o_clk = clk_reg;

endmodule
