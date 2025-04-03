`timescale 1ns / 1ps

module uart(
    input clk,
    input reset,
    input tx_trigger,
    input[7:0] tx_data,
    input rx,
    output tx,
    output[7:0] rx_data
    );
endmodule
