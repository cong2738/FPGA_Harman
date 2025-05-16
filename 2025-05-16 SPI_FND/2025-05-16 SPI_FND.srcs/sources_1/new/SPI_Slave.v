`timescale 1ns / 1ps

module SPI_Slave (
    input wire SCLK,
    input wire reset,
    input wire CS,
    input wire MOSI,
    output wire MISO,
    output reg [7:0] data_reg,
    output reg done,
    output reg busy
);
    reg [$clog2(8)-1:0] bit_count;

    assign MISO = CS ? 8'dz : MOSI;

    always @(posedge SCLK, posedge reset) begin
        if (reset) begin
            data_reg <= 0;
            done <= 0;
            bit_count <= 0;
        end else begin
            done <= 0;
            if (!CS) begin
                data_reg <= {data_reg[6:0], MOSI};
                if (bit_count == 7) begin
                    done <= 1;
                    bit_count <= 0;
                end else bit_count <= bit_count + 1;
            end
        end
    end
endmodule
