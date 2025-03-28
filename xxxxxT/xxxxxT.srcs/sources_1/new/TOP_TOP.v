`timescale 1ns / 1ps
`include "..\imports\temp_sensor.srcs\sources_1\new\top_sensor.v"

module TOP_TOP (
    input clk,
    input reset,
    inout data,
    input start_trigger,
    output [4:0] led,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    wire tx;
    top_DH11_module U_RHT_SENSOR (
        .clk(clk),
        .reset(reset),
        .data(data),
        .start_trigger(start_trigger),
        .led(led),
        .seg_out(seg_out),
        .seg_comm(seg_comm)
    );
    uart_clock uuart_clock (
        .reset(reset),
        .clk(clk),
        .finish_tick(w_finish_tick),
        .start_trigger(w_start_trigger | w_tick10sec),
        .tx(tx),
        .sensor_data(w_o_data2)
    );
endmodule
