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

endmodule

module tx (
    input clk,
    input reset,
    input tx_trigger,
    input [7:0] tx_data,
    output tx_done,
    output tx_busy,
    output tx
);

endmodule


module rx (
    input clk,
    input reset,
    input rx,
    output [7:0] rx_data,
    output rx_done,
    output rx_busy
);

endmodule
