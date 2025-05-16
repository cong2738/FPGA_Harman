`timescale 1ns / 1ps

module SPI_Master (
    input wire sys_clk,
    input wire reset,
    input wire MISO,
    input wire start,
    input wire [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire MOSI,
    output reg done,
    output reg ready,
    output reg SCLK,
    output reg CS
);

    localparam IDLE = 0, CP0 = 1, CP1 = 2;

    reg [1:0] state, next;
    reg [$clog2(8)-1:0] bit_count, bit_count_next;
    reg [$clog2(50)-1:0] tx_count, tx_count_next;
    reg [7:0] temp_rxData, temp_rxData_next;
    reg [7:0] temp_txData, temp_txData_next;

    assign MOSI = temp_txData[7];
    assign rx_data = temp_rxData;

    // state logic
    always @(posedge sys_clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            tx_count <= 0;
            temp_rxData <= 0;
            temp_txData <= 0;
        end else begin
            state <= next;
            bit_count <= bit_count_next;
            tx_count <= tx_count_next;
            temp_rxData <= temp_rxData_next;
            temp_txData <= temp_txData_next;
        end
    end

    // next logic
    always @(*) begin
        next             = state;
        bit_count_next   = bit_count;
        tx_count_next    = tx_count;
        temp_rxData_next = temp_rxData;
        temp_txData_next = temp_txData;
        done             = 0;
        ready            = 0;
        SCLK             = 0;
        CS               = 1;
        case (state)
            IDLE: begin
                CS = 1;
                temp_txData_next = 8'dz;
                done = 0;
                ready = 1;
                if (start) begin
                    tx_count_next    = 0;
                    bit_count_next   = 0;
                    temp_txData_next = tx_data;
                    next             = CP0;
                end
            end
            CP0: begin
                CS = 0;
                if (tx_count == 49) begin
                    temp_rxData_next = {temp_rxData[6:0], MISO};
                    tx_count_next    = 0;
                    next             = CP1;
                end else tx_count_next = tx_count + 1;
            end
            CP1: begin
                CS = 0;
                SCLK = 1;
                if (tx_count == 49) begin
                    tx_count_next = 0;
                    if (bit_count == 7) begin
                        bit_count_next = 0;
                        done = 1;
                        next = IDLE;
                    end else begin
                        bit_count_next   = bit_count + 1;
                        temp_txData_next = {temp_txData[6:0], 1'b0};
                        next = CP0;
                    end
                end else tx_count_next = tx_count + 1;
            end
        endcase
    end
endmodule
