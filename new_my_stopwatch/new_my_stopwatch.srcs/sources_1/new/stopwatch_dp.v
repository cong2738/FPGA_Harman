`timescale 1ns / 1ps

module stopwatch_dp (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output [6:0] msec,
    sec,
    min,
    hour
);
    wire w_tick_100hz;
    // 100Hz tick generator
    tick_100hz U_Tick_100hz (
        .clk(clk),  // 100Mhz
        .reset(reset),
        .run_stop(i_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );

    localparam TENMSEC_MAX = 100;
    wire [$clog2(TENMSEC_MAX):0] w_msec;
    wire w_msec_clk;
    counter_tick #(
        .TICK_COUNT(TENMSEC_MAX)
    ) U_Count_Msec (  // msec
        .clk(clk),
        .reset(reset),
        .clear(i_clear),
        .tick(w_tick_100hz),  //100hz => 0.01sec
        .counter(w_msec),
        .o_tick(w_msec_clk)  // 100hz/100 = 1hz => 1sec
    );

    localparam SEC_MAX = 60;
    wire [$clog2(SEC_MAX):0] w_sec;
    wire w_sec_clk;
    counter_tick #(
        .TICK_COUNT(SEC_MAX)
    ) U_Count_sec (  // sec
        .clk(clk),
        .reset(reset),
        .clear(i_clear),
        .tick(w_msec_clk),  //1hz
        .counter(w_sec),
        .o_tick(w_sec_clk)  // 1/60hz => 60sec
    );

    localparam MIN_MAX = 60;
    wire [$clog2(MIN_MAX):0] w_min;
    wire w_min_clk;
    counter_tick #(
        .TICK_COUNT(MIN_MAX)
    ) U_Count_Min (
        .clk(clk),
        .reset(reset),
        .clear(i_clear),
        .tick(w_sec_clk),
        .counter(w_min),
        .o_tick(w_min_clk)  //60min
    );

    localparam HOUR_MAX = 60;
    wire [$clog2(MIN_MAX):0] w_hour;
    wire w_hour_clk;
    counter_tick #(
        .TICK_COUNT(MIN_MAX)
    ) U_Count_Hour (
        .clk(clk),
        .reset(reset),
        .clear(i_clear),
        .tick(w_min_clk),
        .counter(w_hour),
        .o_tick(w_hour_clk)  //60min
    );
    assign msec = w_msec;
    assign sec  = w_sec;
    assign min  = w_min;
    assign hour = w_hour;
endmodule

// 100Hz tick generator
module tick_100hz (
    input clk,  // 100Mhz
    input reset,
    input run_stop,
    output o_tick_100hz
);

    reg [$clog2(1_000_000)-1:0] r_counter;
    reg r_tick_100hz;

    assign o_tick_100hz = r_tick_100hz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_tick_100hz <= 0;
        end else begin
            if (run_stop == 1'b1) begin
                if (r_counter == (1_000_000 - 1)) begin // 100_000_000 / 1_000_000 = 100hz
                    r_counter <= 0;
                    r_tick_100hz <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick_100hz <= 1'b0;
                end
            end
        end
    end

endmodule

module counter_tick #(
    parameter TICK_COUNT = 10_000
) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1 : 0] counter,
    output o_tick
);

    //                           state         next
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;
    assign counter = counter_reg;
    assign o_tick  = r_tick;

    // state
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    // next
    always @(*) begin
        counter_next = counter_reg;
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 0;
        end else if (tick == 1'b1) begin  // tick count
            if (counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                r_tick = 1'b0;
            end
        end
    end

endmodule
