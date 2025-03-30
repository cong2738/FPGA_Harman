`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 13:24:16
// Design Name: 
// Module Name: mux_3mode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module univ_cu (
    input clk,
    input reset,
    input [7:0] cmd,
    output [2:0] mode_sel,
    output run_stop,
    output clear,
    output hour_add,
    output min_add,
    output sec_add
);
    cmd_mode_sel_mux u_cmd_mode_sel_mux (
        .cmd     (cmd),
        .mode_sel(mode_sel)
    );
    cmd_sig_box u_cmd_sig_box (
        .clk     (clk),
        .rst     (rst),
        .cmd     (cmd),
        .cmd_tick(cmd_tick),
        .run_stop(run_stop),
        .clear   (clear),
        .sec_add (sec_add),
        .min_add (min_add),
        .hour_add(hour_add)
    );
endmodule

module cmd_mode_sel_mux (
    input  [7:0] cmd,
    output [2:0] mode_sel
);
    reg [2:0] r_mode_sel;
    assign mode_sel = r_mode_sel;
    always @(*) begin
        case (cmd)
            "0": begin
                r_mode_sel = 0;
            end
            "1": begin
                r_mode_sel = 1;
            end
            "2": begin
                r_mode_sel = 2;
            end
            default: r_mode_sel = 0;
        endcase
    end
endmodule

module cmd_sig_box (
    input        clk,
    input        rst,
    input  [7:0] cmd,
    input        cmd_tick,
    output       run_stop,
    output       clear,
    output       sec_add,
    output       min_add,
    output       hour_add
);
    reg r_run_stop;
    reg r_clear;
    reg r_hour_add;
    reg r_min_add;
    reg r_sec_add;

    always @(*) begin
        r_run_stop = 0;
        r_clear = 0;
        r_hour_add = 0;
        r_min_add = 0;
        r_sec_add = 0;
        case (cmd)
            "R": begin
                r_run_stop = 1;
            end
            "r": begin
                r_run_stop = 1;
            end
            "C": begin
                r_clear = 1;
            end
            "c": begin
                r_clear = 1;
            end
            "H": begin
                r_hour_add = 1;
            end
            "h": begin
                r_hour_add = 1;
            end
            "M": begin
                r_min_add = 1;
            end
            "m": begin
                r_min_add = 1;
            end
            "S": begin
                r_sec_add = 1;
            end
            "s": begin
                r_sec_add = 1;
            end
            default: begin
                r_run_stop = 0;
                r_clear = 0;
                r_hour_add = 0;
                r_min_add = 0;
                r_sec_add = 0;
            end
        endcase
    end

    assign run_stop = r_run_stop & cmd_tick;
    assign clear    = r_clear & cmd_tick;
    assign sec_add  = r_hour_add & cmd_tick;
    assign min_add  = r_min_add & cmd_tick;
    assign hour_add = r_sec_add & cmd_tick;

endmodule

module mux_3mode (
    input [$clog2(3)-1:0] mode,
    input a1,
    input a2,
    input a3,
    input a4,
    input b1,
    input b2,
    input b3,
    input b4,
    input c1,
    input c2,
    input c3,
    input c4,
    output reg o1,
    output reg o2,
    output reg o3,
    output reg o4
);

    always @(*) begin
        case (mode)
            0: begin
                o1 = a1;
                o2 = a2;
                o3 = a3;
                o4 = a4;
            end
            1: begin
                o1 = b1;
                o2 = b2;
                o3 = b3;
                o4 = b4;
            end
            2: begin
                o1 = c1;
                o2 = c2;
                o3 = c3;
                o4 = c4;
            end
        endcase
    end
endmodule
