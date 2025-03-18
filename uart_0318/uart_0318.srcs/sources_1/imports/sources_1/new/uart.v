`timescale 1ns / 1ps
/*
    2025.03.17
*/
module uart #(
    BAUD_RATE = 9600
) (
    input clk,
    input rst,
    input btn_start,
    input [7:0] uart_data,
    output tx,
    output tx_busy
);

    wire tick;
    // rx에쓰려고 16배속 했지만 클럭 동기화 이슈때문에 TX에도 같은곳의 클럭을 써야한다.
    boud_tick_gen #(
        .BAUD_RATE(BAUD_RATE)
    ) U_btn_Debounce (
        .clk(clk),
        .rst(rst),
        .baud_tick(tick)
    );

    // uart_rx U_Rx (
    //     .clk(clk),
    //     .rst(rst),
    //     .tick(tick),
    //     .start_triger(btn_start),
    //     .i_data(uart_data),
    //     .o_rx(rx),
    //     .rx_busy(tx_busy)
    // );

    uart_tx U_Tx (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .start_triger(btn_start),
        .i_data(uart_data),
        .o_tx(tx),
        .tx_busy(tx_busy)
    );


endmodule
module moduleName (
    input  clk,
    input  rst,
    input  tick,
    input  rx,
    output rx_data,
    output rx_busy
);
    localparam IDLE = 0, SEND = 1, START = 2, DATA = 3, STOP = 4;
    reg [1:0] state, next;
    reg [7:9] data_reg, data_next;
    reg busy_reg, busy_next;
    reg [7:0] bit_count_reg, bit_count_next;
    reg [3:0] tick_count_reg, tick_count_next;

    // output
    assign rx_busy = busy_reg;
    assign rx_data = data_reg;

    // state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state          <= 0;
            busy_reg       <= 0;
            bit_count_reg  <= 0;
            tick_count_reg <= 0;
        end else begin
            state          <= next;
            busy_reg       <= busy_next;
            bit_count_reg  <= bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    // next
    always @(*) begin
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        case (state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next  = 0;
                if (rx == 0) begin
                    tick_count_next = 0;
                    next = START;
                end
            end
            START: begin
                if (tick_count_reg == 7) begin
                    tick_count_next = 0;
                    next = DATA;
                end else begin
                    tick_count_next = tick_count_reg + 1;
                end
            end
            DATA: begin
                if (tick_count_reg == 15) begin
                    if (bit_count_reg == 7) begin
                        tick_count_next = 0;
                        next = STOP;
                    end else begin
                        bit_count_next = bit_count_reg + 1;
                        tick_count_next = 0;
                        next = DATA;
                    end
                end else begin
                    tick_count_next = tick_count_reg + 1;
                end
            end
            STOP: begin
                if (tick_count_reg == 7) begin
                    tick_count_next = 0;
                    next = IDLE;
                end else begin
                    tick_count_next = tick_count_reg + 1;
                end
            end
            default: next = IDLE;
        endcase
    end
endmodule

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_triger,
    input [7:0] i_data,
    output o_tx,
    output tx_busy
);
    parameter IDLE = 0, SEND = 1, START = 2, DATA = 3, STOP = 4;

    reg [3:0] state, next;
    reg tx_reg, tx_next;
    reg busy_reg, busy_next;
    reg [3:0] bit_count_reg, bit_count_next;
    reg [3:0] tick_count_reg, tick_count_next;

    assign o_tx = tx_reg;
    assign tx_busy = busy_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 1;
            busy_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            busy_reg <= busy_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        busy_next = busy_reg;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        case (state)
            IDLE: begin
                tick_count_next = 0;
                busy_next = 0;
                tx_next = 1;
                if (start_triger) begin
                    next = SEND;
                end
            end
            SEND: begin
                if (tick) begin
                    next = START;
                end
            end
            START: begin
                tx_next   = 0;
                busy_next = 1;
                if (tick) begin
                    if (tick_count_next == 15) begin
                        tick_count_next = 0;
                        bit_count_next = 0;
                        next = DATA;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        next = START;
                    end
                end
            end
            DATA: begin
                tx_next = i_data[bit_count_next];
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        if (bit_count_reg == 7) begin
                            bit_count_next = 0;
                            tx_next = 1;
                            next = STOP;
                        end else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        next = DATA;
                    end
                end
            end
            STOP: begin
                tx_next = 1;
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            default: next = state;
        endcase
    end

endmodule

module boud_tick_gen #(
    parameter BAUD_RATE = 9600
) (
    input  clk,
    input  rst,
    output baud_tick
);
    localparam BUAD_COUNT = (100_000_000 / BAUD_RATE) / 16;
    reg [$clog2(BUAD_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    //next
    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;
        if (count_reg == BUAD_COUNT - 1) begin
            count_next = 0;
            tick_next  = 1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 0;
        end
    end

    //output
    assign baud_tick = tick_reg;

endmodule


