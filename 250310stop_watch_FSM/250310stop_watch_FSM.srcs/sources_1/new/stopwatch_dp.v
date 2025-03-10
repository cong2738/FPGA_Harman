`timescale 1ns / 1ps

module stopwatch_dp#(parameter FCOUNT = 1_000_000) (
    input clk,
    input reset,
    input run,
    input clear,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [6:0] hour
);

    wire w_100hz;
    tick_generator100hz #(
        .FCOUNT(FCOUNT)
    ) Tick_Generator100hz (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .o_clk(w_100hz)  // period:0.01sec = 10msec
    );

    wire [6:0] w_msec;
    wire w_1hz;
    time_counter #(
        .TICK_COUNT(100)
    ) Msec_Counter (
        .clk(clk),
        .reset(reset),
        .tick(w_100hz),
        .count(w_msec),
        .o_tick(w_1hz)  // period:1sec
    );

    wire [6:0] w_sec;
    wire w_secCounter_tick;
    time_counter #(
        .TICK_COUNT(60)
    ) Sec_Counter (
        .clk(clk),
        .reset(reset),
        .tick(w_1hz),
        .count(w_sec),
        .o_tick(w_secCounter_tick)  // period:1min
    );

    wire [6:0] w_min;
    wire w_minCounter_tick;
    time_counter #(
        .TICK_COUNT(60)
    ) Min_Counter (
        .clk(clk),
        .reset(reset),
        .tick(w_secCounter_tick),
        .count(w_min),
        .o_tick(w_minCounter_tick)  // period:1hour
    );

    wire [6:0] w_hour;
    wire w_hourCounter_tick;
    time_counter #(
        .TICK_COUNT(24)
    ) Hour_Counter (
        .clk(clk),
        .reset(reset),
        .tick(w_minCounter_tick),
        .count(w_hour),
        .o_tick(w_hourCounter_tick)  // period:1day
    );

    assign msec = w_msec;
    assign sec  = w_sec;
    assign min  = w_min;
    assign hour = w_hour;

endmodule


module time_counter #(
    parameter TICK_COUNT = 100
) (
    input clk,
    input reset,
    input tick,
    input [$clog2(TICK_COUNT)-1:0] count,
    input o_tick
);
    reg [$clog2(TICK_COUNT) - 1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg = count_next;
            tick_reg  = tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;
        if (tick) begin
            if (count_next == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1;
            end else begin
                count_next = count_next + 1;
                tick_next  = 0;
            end
        end
    end

    assign count  = count_reg;
    assign o_tick = tick_reg;
endmodule

module tick_generator100hz #(
    parameter FCOUNT = 1_000_000
) (
    input  clk,
    input  reset,
    input  run,
    input  clear,
    output o_clk
);
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  //출력을 f/f으로 내보내기 위해 사용

    always @(posedge clk, posedge reset) begin
        if (clear) begin
            count_next <= 0;
            clk_next   <= 0;
        end else if (run) begin
            if (reset) begin
                count_reg <= 0;
                clk_reg   <= 0;
            end else begin
                count_reg <= count_next;
                clk_reg   <= clk_next;
            end
        end
    end

    always @(*) begin
        count_next = count_reg;
        clk_next   = 0;
        if(run) begin
            if (count_next == FCOUNT - 1) begin
                count_next = 0;
                clk_next   = 1'b1;
            end else begin
                count_next = count_reg + 1;
                clk_next   = 1'b0;
            end
        end
    end

    assign o_clk = clk_reg;

endmodule
