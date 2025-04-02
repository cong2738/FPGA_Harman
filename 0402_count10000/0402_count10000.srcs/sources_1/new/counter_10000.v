module counter_10000 #(
    parameter MAX_COUNT = 9999
) (
    input clk,
    input reset,
    input mode_sw,
    output [$clog2(MAX_COUNT)-1:0] count
);
    clk_div #(
        .MAX_COUNT(10_000_000)
    ) u_clk_div (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    up_down_counter u_counter (
        .clk    (clk),
        .tick   (tick),
        .reset  (reset),
        .mode_sw(mode_sw),
        .count  (count)
    );

endmodule

module up_down_counter #(
    parameter MAX_COUNT = 9999
) (
    input clk,
    input tick,
    input reset,
    input mode_sw,
    output [$clog2(MAX_COUNT)-1:0] count
);
    reg [$clog2(MAX_COUNT)-1:0] r_count;

    assign count = r_count;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end else begin
            if (tick) begin
                if (mode_sw) begin
                    if (count == 0) begin
                        r_count <= MAX_COUNT;
                    end else r_count <= r_count - 1;
                end else begin
                    if (count == MAX_COUNT) begin
                        r_count <= 0;
                    end else r_count <= r_count + 1;
                end
            end
        end
    end
endmodule
