`timescale 1ns / 1ps

module uart (
    input clk,
    input reset,
    input tx_trigger,
    input [7:0] tx_data,
    input rx,
    output tx,
    output tx_done,
    output tx_busy,
    output [7:0] rx_data,
    output rx_done,
    output rx_busy
);
    wire tick;

    baudrate_gen U_Baudrate_Gen (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    tx U_Transmitter (
        .clk       (clk),
        .reset     (reset),
        .tick      (tick),
        .tx_trigger(tx_trigger),
        .tx_data   (tx_data),
        .tx_done   (tx_done),
        .tx_busy   (tx_busy),
        .tx        (tx)
    );

    rx U_Receiver (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick),
        .rx     (rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy)
    );


endmodule

module tx (
    input clk,
    input reset,
    input tick,
    input tx_trigger,
    input [7:0] tx_data,
    output tx_done,
    output tx_busy,
    output reg tx
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, next;
    reg [7:0] temp_data, temp_data_next;
    reg [2:0] bit_count, bit_count_next;
    reg [3:0] tick_count, tick_count_next;
    reg done, done_next;
    reg busy, busy_next;

    assign tx_busy = busy, tx_done = done;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state      <= IDLE;
            temp_data  <= 0;
            tick_count <= 0;
            bit_count  <= 0;
            done       <= 0;
            busy       <= 0;
        end else begin
            state      <= next;
            temp_data  <= temp_data_next;
            tick_count <= tick_count_next;
            bit_count  <= bit_count_next;
            done       <= done_next;
            busy       <= busy_next;
        end
    end

    always @(*) begin
        next = state;
        temp_data_next = temp_data;
        tick_count_next = tick_count;
        bit_count_next = bit_count;
        done_next = 0;
        busy_next = busy;

        case (state)
            IDLE: begin
                tx = 1;
                busy_next = 0;
                if (tx_trigger) begin
                    temp_data_next = tx_data; // ** 데이터를 버퍼에 넣어서 "유지" 시킨다.
                    busy_next = 1;
                    next = START;
                end
            end
            START: begin
                tx = 0;
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        bit_count_next  = 0;
                        next            = DATA;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            DATA: begin
                tx = temp_data[0];
                busy_next = 1;
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        if (bit_count == 7) begin
                            next = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;
                            temp_data_next = {1'b0, temp_data[7:1]};
                        end
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            STOP: begin
                tx = 1;
                busy_next = 1;
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        done_next       = 1;  // 한틱만
                        next            = IDLE;
                    end else begin
                        tick_count_next = tick_count + 1;
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
    output rx_done,
    output rx_busy
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, next;
    reg [2:0] bit_count, bit_count_next;
    reg [3:0] tick_count, tick_count_next;
    reg [7:0] data, data_next;
    reg busy, busy_next;
    reg done, done_next;

    assign rx_data = data, rx_done = done, rx_busy = busy;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            tick_count <= 0;
            data <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            state <= next;
            bit_count <= bit_count_next;
            tick_count <= tick_count_next;
            data <= data_next;
            busy <= busy_next;
            done <= done_next;
        end
    end

    always @(*) begin
        next = state;
        bit_count_next = bit_count;
        tick_count_next = tick_count;
        data_next = data;
        busy_next = 0;
        done_next = 0;
        case (state)
            IDLE: begin
                if (!rx) begin
                    next = START;
                    bit_count_next = 0;
                    tick_count_next = 0;
                    data_next = 0;
                end
            end
            START: begin
                busy_next = 1;
                if (tick) begin
                    if (tick_count == 7) begin
                        tick_count_next = 0;
                        next = DATA;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            DATA: begin
                busy_next = 1;
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        data_next = {rx, data[7:1]};
                        if (bit_count == 7) begin
                            bit_count_next = 0;
                            next = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;
                        end
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            STOP: begin
                busy_next = 1;
                if (tick) begin
                    if (tick_count == 15) begin
                        tick_count_next = 0;
                        done_next = 1;
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
        endcase
    end

endmodule

module baudrate_gen #(
    parameter BAUDRATE = 9600
) (
    input  clk,
    input  reset,
    output tick
);
    localparam COUNT_MAX = 100_000_000 / (BAUDRATE * 16);
    reg r_tick;
    reg [$clog2(COUNT_MAX)-1:0] count;

    assign tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count  <= 0;
            r_tick <= 0;
        end else begin
            if (count == COUNT_MAX - 1) begin
                count  <= 0;
                r_tick <= 1;
            end else begin
                count = count + 1;
                r_tick <= 0;
            end
        end
    end

endmodule
