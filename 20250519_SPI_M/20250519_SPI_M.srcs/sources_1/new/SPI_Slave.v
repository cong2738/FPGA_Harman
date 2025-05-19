`timescale 1ns / 1ps

module SPI_Slave (
    input  clk,
    input  CS,
    input  MOSI,
    output MISO
);
endmodule

module SlaveInterface (
    input            reset,
    // external signals
    input            SCLK,
    input            SS,
    input            MOSI,
    output           MISO,
    // internal signals
    output reg       done,
    output reg       write,
    output     [1:0] addr,
    output     [7:0] wdata,
    input      [7:0] rdata
);
    localparam SO_IDLE = 0, SO_DATA = 1;

    reg [7:0] temp_tx_data;
    reg [7:0] temp_rx_data;
    reg [2:0] bit_count_Write;
    reg [2:0] bit_count_Read;
    reg write_done;

    assign MISO  = SS ? 1'bz : temp_tx_data[7];
    assign wdata = temp_rx_data;

    // reset sequence
    always @(posedge reset) begin
        if (reset) begin
            temp_tx_data <= 8'dz;
            temp_rx_data <= 0;
            bit_count_Write <= 0;
            bit_count_Read <= 0;
            write_done <= 0;
        end 
    end

    // MOSI sequence
    always @(posedge SCLK) begin
        if(!reset) begin
            write_done <= 0;
            if (!SS) begin
            if (bit_count_Write == 7) begin
                bit_count_Write <= 0;
                write_done <= 1;
            end else begin
                temp_rx_data[bit_count_Write] <= MOSI;
                bit_count_Write <= bit_count_Write + 1;
            end
        end
        end
    end

    // MISO sequence
    always @(posedge SCLK) begin
        if(!reset) begin
            // rdata latch
        if(!SS && write_done) begin
            temp_tx_data <= rdata;
            write <= temp_rx_data[7];
        end
        done = 0;
        if (!SS && !write) begin
            if (bit_count_Read == 7) begin
                done = 1;
                bit_count_Read <= 0;
            end else begin
                temp_tx_data   <= {temp_tx_data[6:0], 1'b0};
                bit_count_Read <= bit_count_Read + 1;
            end
        end
        end
    end

endmodule
