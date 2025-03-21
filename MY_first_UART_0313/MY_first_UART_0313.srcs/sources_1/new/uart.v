`timescale 1ns / 1ps

module uart #(
    BAUD_RATE = 9600
) (
    input  clk,
    input  rst,
    input  btn_start,
    input [7:0]uart_data,
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
    //fs,
    parameter   IDLE = 4'h0, START = 4'h1, 
                D0 = 4'h2, D1 = 4'h3, 
                D2 = 4'h4, D3 = 4'h5,
                D4 = 5'h6, D5 = 4'h7, 
                D6 = 4'h8, D7 = 4'h9,
                STOP = 4'ha;

    reg [3:0] state, next;
    reg tx_reg, tx_next;
    reg busy_reg, busy_next;

    assign o_tx = tx_reg;
    assign tx_busy = busy_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tx_reg   <= 1;
            busy_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            busy_reg <= busy_next;
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        busy_next = busy_reg;
        case (state)
            IDLE: begin
                busy_next = 0;
                tx_next   = 1;
                if (start_triger) begin
                    busy_next = 1;
                    next = START;
                end
            end
            START: begin
                if (tick == 1) begin
                    tx_next = 0;
                    next = D0;
                end
            end
            D0: begin
                if (tick) begin
                    tx_next = i_data[0];
                    next = D1;
                end
            end
            D1: begin
                if (tick) begin
                    tx_next = i_data[1];
                    next = D2;
                end
            end
            D2: begin
                if (tick) begin
                    tx_next = i_data[2];
                    next = D3;
                end
            end
            D3: begin
                if (tick) begin
                    tx_next = i_data[3];
                    next = D4;
                end
            end
            D4: begin
                if (tick) begin
                    tx_next = i_data[4];
                    next = D5;
                end
            end
            D5: begin
                if (tick) begin
                    tx_next = i_data[5];
                    next = D6;
                end
            end
            D6: begin
                if (tick) begin
                    tx_next = i_data[6];
                    next = D7;
                end
            end
            D7: begin
                if (tick) begin
                    tx_next = i_data[7];
                    next = STOP;
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
