`timescale 1ns / 1ps

module uart_watch (
    input clk,
    input rst,
    input hs_mod_sw,
    input watch_mod_sw,
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    output tx,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] mod_indicate_led
);
    wire rx, rx_done;
    wire [7:0] rx_data;
    get_string_UART U_UART (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .rx_data(rx_data)
    );

    top_my_watch U_Watch (
        .clk(clk),
        .reset(rst),
        .hs_mod_sw(hs_mod_sw),
        .watch_mod_sw(watch_mod_sw),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .cmd(rx_data),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .mod_indicate_led(mod_indicate_led)
    );
endmodule
