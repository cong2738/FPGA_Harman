`timescale 1ns / 1ps

module TOP_UART_WATCH (
    input clk,
    input reset,
    input hs_mod_sw,
    input watch_mod_sw,
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    input rx,
    output tx,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] mod_indicate_led
);
    wire [7:0] rx_data;
    wire rx_done;
    top_my_watch U_Watch (
        .clk(clk),
        .reset(reset),
        .hs_mod_sw(hs_mod_sw),
        .watch_mod_sw(watch_mod_sw),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .cmd(rx_data),
        .data_tick(rx_done),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .mod_indicate_led(mod_indicate_led)
    );
    Top_UART_String U_UART (
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .tx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
endmodule
