`timescale 1ns / 1ps

module UART (
    input clk,
    input reset,
    input [7:0] tx_data,
    input trigger,
    input rx,
    output tx,
    output [7:0] rx_data,
    output rx_done
);
    buadrate_gen u_buadrate_gen (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    tx u_tx (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick),
        .trigger(trigger),
        .tx_data(tx_data),
        .tx     (tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    rx u_rx (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick),
        .rx     (rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule

module tx (
    input clk,
    input reset,
    input tick,
    input trigger,
    input [7:0] tx_data,
    output tx,
    output tx_busy,
    output tx_done
);
    localparam IDLE = 0, WAIT = 1, DATA = 2, STOP = 3;

    reg tx_reg, tx_next;
    reg busy, busy_next;
    reg done, done_next;
    reg [$clog2(3)-1:0] state, next;
    reg [$clog2(16)-1:0] tCount, tCount_next;
    reg [$clog2(7)-1:0] dtCount, dtCount_next;

    assign tx = tx_reg;
    assign tc_busy = busy;
    assign tx_done = done;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            tCount <= 0;
            dtCount <= 0;
            tx_reg <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            state <= next;
            tCount <= tCount_next;
            dtCount <= dtCount_next;
            tx_reg <= tx_next;
            busy <= busy_next;
            done <= done_next;
        end
    end

    always @(*) begin
        next = state;
        tCount_next = tCount;
        dtCount_next = dtCount;
        tx_next = 1;
        busy_next = 1;
        done_next = 0;
        case (state)
            IDLE: begin
                tx_next   = 1;
                busy_next = 0;
                if (trigger) begin
                    tCount_next = 0;
                    next = WAIT;
                end
            end
            WAIT: begin
                tx_next = 0;
                if (tick) begin
                    if (tCount == 15) begin
                        tCount_next = 0;
                        dtCount_next = 0;
                        next = DATA;
                    end else begin
                        tCount_next = tCount + 1;
                    end
                end
            end
            DATA: begin
                tx_next = tx_data[dtCount];
                if (tick) begin
                    if (tCount == 15) begin
                        tCount_next = 0;
                        if (dtCount == 7) begin
                            dtCount_next = 0;
                            next = STOP;
                        end else dtCount_next = dtCount + 1;
                    end else begin
                        tCount_next = tCount + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1;
                if (tick) begin
                    if (tCount == 15) begin
                        tCount_next = 0;
                        next = IDLE;
                        done_next = 1;
                    end else begin
                        tCount_next = tCount + 1;
                    end
                end
            end
        endcase
    end
endmodule

module rx (
    input clk,
    input reset,
    input tick,
    input rx,
    output [7:0] rx_data,
    output rx_done
);
    localparam IDLE = 0, WAIT = 1, DATA = 2, STOP = 3;

    reg [$clog2(3)-1:0] state, next;
    reg [$clog2(24)-1:0] tc, tc_next;
    reg [$clog2(8)-1:0] dc, dc_next;
    reg [7:0] data, data_next;
    reg done, done_next;

    assign rx_data = data;
    assign rx_done = done;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            tc <= 0;
            dc <= 0;
            data <= 0;
            done <= 0;
        end else begin
            state <= next;
            tc <= tc_next;
            dc <= dc_next;
            data <= data_next;
            done <= done_next;
        end
    end

    always @(*) begin
        next = state;
        tc_next = tc;
        dc_next = dc;
        data_next = data;
        done_next = 0;
        case (state)
            IDLE: begin
                if (!rx) begin
                    tc_next = 0;
                    next = WAIT;
                end
            end
            WAIT: begin
                if (tick) begin
                    if (tc == 7) begin
                        next = DATA;
                        tc_next = 0;
                        dc_next = 0;
                    end else tc_next = tc + 1;
                end
            end
            DATA: begin
                data_next[dc] = rx;
                if (tick) begin
                    if (tc == 15) begin
                        tc_next = 0;
                        if (dc == 7) begin
                            dc_next = 0;
                            next = STOP;
                        end else dc_next = dc + 1;
                    end else tc_next = tc + 1;
                end
            end
            STOP: begin
                if (tick) begin
                    if (tc == 23) begin
                        tc_next = 0;
                        done_next = 1;
                        next = IDLE;
                    end else tc_next = tc + 1;
                end
            end
        endcase
    end
endmodule

module buadrate_gen #(
    parameter BUADRATE = 9600
) (
    input wire clk,
    input wire reset,
    input [2:0] count_state,
    output reg tick
);
    localparam COUNTMAX = 100_000_000 / BUADRATE / 16;
    reg [$clog2(COUNTMAX)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == COUNTMAX - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
