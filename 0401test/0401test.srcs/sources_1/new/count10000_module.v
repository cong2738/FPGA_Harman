`timescale 1ns / 1ps

module count10000_module #(
    parameter COUNT_MAX = 10000
) (
    input clk,
    input reset,
    input sw,
    output [$clog2(COUNT_MAX)-1:0] count
);
    clk_div #(
        .COUNT_MAX(10_000_000)
    ) CLK_100ms (
        .clk  (clk),
        .reset(reset),
        .tick (clk_100ms)
    );

    two_mode_counter #(
        .COUNT_MAX(COUNT_MAX)
    ) u_counter (
        .clk  (clk_100ms),
        .reset(reset),
        .sw   (sw),
        .count(count)
    );
endmodule

module two_mode_counter #(
    parameter COUNT_MAX = 10000
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
        if (sw) begin
            if (count_curr == 0) begin
                count_next = COUNT_MAX;
            end else count_next = count_next - 1;
        end else begin
            if (count_curr == COUNT_MAX) begin
                count_next = 0;
            end else count_next = count_next + 1;
        end
    end

endmodule
