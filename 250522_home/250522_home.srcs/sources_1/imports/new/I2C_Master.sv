`timescale 1ns / 1ps

module I2C_Master (
    input logic clk,
    input logic reset,
    
    input logic [3:0] CMD,
    input logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic ready,
    output logic done,

    inout logic sda,
    output logic scl
);
    typedef enum logic [3:0] {
        IDLE_CMD,
        START_CMD,
        STOP_CMD,
        RESTART_CMD,
        RD_CMD,
        WR_CMD
    } CMD_E;

    typedef enum logic [3:0] {
        IDLE,
        START1,
        START2,
        HOLD,
        STOP1,
        STOP2,
        RESTART,
        DATA1,
        DATA2,
        DATA3,
        DATA4,
        DATA_END1,
        DATA_END2
    } state_enum;

    state_enum state, next;
    logic [$clog2(1000)-1:0] clk_count, clk_count_next;
    logic [7:0] bit_count, bit_count_next;
    logic [7:0] temp_data, temp_data_next;
    logic sda_IO, sda_IO_next;
    logic sda_reg;

    assign sda = sda_IO ? 1'bz : sda_reg;

    always_ff @(posedge clk, posedge reset) begin : state_logic
        if (reset) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_count <= 0;
            temp_data <= 0;
            sda_IO    <= 0;
            scl       <= 1;
        end else begin
            state <= next;
            clk_count <= clk_count_next;
            bit_count <= bit_count_next;
            temp_data <= temp_data_next;
            sda_IO <= sda_IO_next;
        end
    end
    always_comb begin : next_logic
        next = state;
        clk_count_next = clk_count;
        bit_count_next = bit_count;
        temp_data_next = temp_data;
        sda_IO_next = sda_IO;
        done = 0;
        sda_reg = 1;
        ready = 0;
        scl = 1;
        case (state)
            IDLE: begin
                sda_IO_next = 0;
                ready = 1;
                sda_reg = 1;
                scl = 1;
                ready = 1;
                if (CMD == START_CMD) begin
                    next = START1;
                end
            end
            START1: begin
                sda_reg = 0;
                scl = 1;
                if (clk_count == 499) begin
                    clk_count_next = 0;
                    next = START2;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            START2: begin
                sda_reg = 0;
                scl = 0;
                if (clk_count == 499) begin
                    clk_count_next = 0;
                    next = HOLD;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            HOLD: begin
                ready = 1;
                sda_reg = 0;
                scl = 0;
                temp_data_next = tx_data;
                case (CMD)
                    STOP_CMD: begin
                        sda_IO_next = 0;
                        next = STOP1;
                    end
                    RESTART_CMD: begin
                        sda_IO_next = 0;
                        next = START1;
                    end
                    WR_CMD: begin
                        temp_data_next = tx_data;
                        sda_IO_next = 0;
                        next = DATA1;
                    end
                    RD_CMD: begin
                        sda_IO_next = 1;
                        next = DATA1;
                    end
                endcase
            end
            DATA1: begin
                sda_reg = temp_data[7];
                scl = 0;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    next = DATA2;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            DATA2: begin
                sda_reg = temp_data[7];
                scl = 1;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    next = DATA3;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            DATA3: begin
                sda_reg = temp_data[7];
                scl = 1;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    next = DATA4;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            DATA4: begin
                sda_reg = temp_data[7];
                scl = 0;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    temp_data_next = {temp_data[6:0], 1'b0};
                    if (bit_count == 7) begin
                        bit_count_next = 0;
                        sda_IO_next = 1;
                        next = DATA_END1;
                    end else begin
                        bit_count_next = bit_count + 1;
                        next = DATA1;
                    end
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            DATA_END1: begin  // wait slave ACK; 
                sda_reg = 0;
                scl = 0;
                done = 1;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    next = DATA_END2;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            DATA_END2: begin  // compare slave ACK; 
                sda_reg = 0;
                scl = 1;
                if (clk_count == 500) begin
                    sda_IO_next = 0;
                    clk_count_next = 0;
                    if (sda) begin
                        next = STOP1;
                    end else begin
                        next = HOLD;
                    end
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            STOP1: begin
                sda_reg = 0;
                scl = 1;
                if (clk_count == 249) begin
                    clk_count_next = 0;
                    next = STOP2;
                end else begin
                    clk_count_next = clk_count + 1;
                end
            end
            STOP2: begin
                sda_reg = 1;
                scl = 1;
                next = IDLE;
            end
        endcase
    end
endmodule
