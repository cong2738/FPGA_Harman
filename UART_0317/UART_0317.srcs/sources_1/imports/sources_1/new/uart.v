`timescale 1ns / 1ps
/*
    2025.03.17
    - UART TX module
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
    boud_tick_gen U_BTG (
        .clk(clk),
        .rst(rst),
        .baud_tick(tick)
    );

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

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_triger,
    input [7:0] i_data,
    output o_tx,
    output tx_busy
);
    parameter IDLE = 0, SEND = 1, START = 2, RUN = 3, STOP = 4;

    reg [3:0] state, next;
    reg tx_reg, tx_next;
    reg busy_reg, busy_next;
    reg [3:0] count_reg, count_next;

    assign o_tx = tx_reg;
    assign tx_busy = busy_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg <= 1;
            busy_reg <= 0;
            count_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            busy_reg <= busy_next;
            count_reg <= count_next;
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        busy_next = busy_reg;
        count_next = count_reg;
        case (state)
            IDLE: begin
                busy_next = 0;
                tx_next   = 1;
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
                tx_next = 0;
                busy_next = 1;
                if (tick) begin
                    count_next = 0;
                    next = RUN;
                end
            end
            RUN: begin
                tx_next = i_data[count_next];
                if (tick) begin
                    count_next = count_reg + 1;
                    if (count_reg == 7) begin
                        count_next = 0;
                        tx_next = 1;
                        next = STOP;
                    end else begin
                        next = RUN;
                    end
                end
            end

            STOP: begin
                if (tick) begin
                    tx_next = 1;
                    busy_next = 0;
                    next = IDLE;
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
    localparam BUAD_COUNT = 100_000_000 / BAUD_RATE;
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
