`timescale 1ns / 1ps

module top_DedicatedProcessor (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] sum_out
);
    logic comp_Aand10;
    logic A_0_sel;
    logic sum_0_sel;
    logic A_save_sel;
    logic sum_save_sel;
    logic add_sel;
    logic out_sel;

    //닷스타: 이름같은건 자동연결(시스템베릴로그기능)
    ControlUnit u_ControlUnit (.*);
    DataPath u_DataPath (.*);
    
endmodule
