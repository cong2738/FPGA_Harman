`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/26 10:49:11
// Design Name: 
// Module Name: test
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
module test (
    input clk,
    input reset,
    input[13:0] data,
    output reg [6:0] seg,
    output wire dot,
    output reg [3:0] cmm
);
    // sellect showData
    reg [3:0] showData;
    always @(*) begin
        case(cmm)
            4'b0001: showData = (data / (10*0)) % 10;
            4'b0010: showData = (data / (10*1)) % 10;
            4'b0100: showData = (data / (10*2)) % 10;
            4'b1000: showData = (data / (10*3)) % 10;
            default: showData = 0;
        endcase
    end
    
    // convert data to segment sig
    assign dot = 0;

    always_comb begin : bcdToSeg
        case (showData)
            0: begin
                seg = 7'b0000001;
            end
            1: begin
                seg = 7'b0000010;
            end
            2: begin
                seg = 7'b0000100;
            end
            3: begin
                seg = 7'b0001000;
            end
            4: begin
                seg = 7'b0010000;
            end
            5: begin
                seg = 7'b0100000;
            end
            6: begin
                seg = 7'b1000000;
            end
            7: begin
                seg = 7'b1000001;
            end
            8: begin
                seg = 7'b1000010;
            end
            9: begin
                seg = 7'b1000100;
            end
            default: begin
                seg = 0;
            end
        endcase
    end

    // cmm controller
    reg [$clog2(10_000)-1:0] clk_cnt;
    always @(posedge clk) begin
        if(reset) begin
            clk_cnt <= 0;
        end else if(clk) begin
            clk_cnt <= clk_cnt + 1;
            if(clk_cnt == 10_000) begin
                clk_cnt <= 0;
                cmm <= cmm + 1;
            end
        end
    end
endmodule