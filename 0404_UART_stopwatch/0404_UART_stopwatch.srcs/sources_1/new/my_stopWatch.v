`timescale 1ns / 1ps

module my_stopWatch #(
    parameter COUNT_MAX = 10_000_000
) (
    input         clk,
    input         reset,
    input         en,
    input         clear,
    output [13:0] t,
    output [ 3:0] dot_data
);

    wire [13:0] msec;
    wire [13:0] sec;
    wire [13:0] min;

    clk_divider #(COUNT_MAX) u_clk_divider (
        .clk  (clk),
        .reset(reset),
        .en   (en),
        .clear(clear),
        .tick (tick)
    );

    clock_counter #(10) u_msec (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick),
        .en     (en),
        .clear  (clear),
        .count  (msec),
        .gen_clk(msec_clk)
    );

    clock_counter #(60) u_sec (
        .clk    (clk),
        .reset  (reset),
        .tick   (msec_clk),
        .en     (en),
        .clear  (clear),
        .count  (sec),
        .gen_clk(sec_clk)
    );

    clock_counter #(10) u_min (
        .clk    (clk),
        .reset  (reset),
        .tick   (sec_clk),
        .en     (en),
        .clear  (clear),
        .count  (min),
        .gen_clk()
    );

    merge_time u_merge_time (
        .clk (clk),
        .msec(msec),
        .sec (sec),
        .min (min),
        .t   (t)
    );

    stopWatch_comp_dot u_comp_dot (
        .msec    (msec),
        .dot_data(dot_data)
    );

endmodule

module clock_counter #(
    parameter COUNT_TIME = 10
) (
    input clk,
    input reset,
    input tick,
    input en,
    input clear,
    output [13:0] count,
    output reg gen_clk
);
    reg [13:0] div_counter;

    assign count = div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            gen_clk <= 1'b0;
        end else begin
            gen_clk <= 1'b0;
            if (en) begin
                if (tick) begin
                    if (div_counter == COUNT_TIME - 1) begin
                        div_counter <= 0;
                        gen_clk <= 1'b1;
                    end else begin
                        div_counter <= div_counter + 1;
                        gen_clk <= 1'b0;
                    end
                end
            end
            if (clear) begin
                div_counter <= 0;
                gen_clk <= 1'b0;
            end
        end
    end
endmodule

module merge_time (
    input clk,
    input [13:0] msec,
    input [13:0] sec,
    input [13:0] min,
    output [13:0] t
);
    // reg [13:0] r_t;
    // assign t = r_t;
    // always @(posedge clk) begin
    //     r_t = min * 1000 + sec * 10 + msec;
    // end
    assign t = min * 1000 + sec * 10 + msec;
endmodule

module stopWatch_comp_dot (
    input  [13:0] msec,
    output [ 3:0] dot_data
);
    assign dot_data = ((msec) < 5) ? 4'b0101 : 4'b1111;
endmodule
