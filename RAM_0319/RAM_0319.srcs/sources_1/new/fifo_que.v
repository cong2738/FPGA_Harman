`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 14:31:45
// Design Name: 
// Module Name: fifo_que
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

`include "ram_ip.v"
module fifo_que (
    input clk,
    input rst,
    input [31:0] data_in,
    input wr,
    input rd,
    output [31:0] data_out,
    output empty,
    output full
);
    wire w_empty,w_full;
    assign empty = w_empty;
    assign full = w_full;
    memory_controller U_CU (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .rptr(),
        .wptr(),
        .empty(w_empty),
        .full(w_full)
    );

    ram_ip_seq #(
        .ADDR_WIDTH(4),  // 주소 폭 (4비트 -> 16개의 주소)
        .DATA_WIDTH(8)   // 데이터 폭 (8비트)
    ) U_reg1 (
        .clk  (clk),  // 클럭 신호
        .addr (),  // 주소 입력
        .wdata(),  // 쓰기 데이터 입력
        .wr   (!w_full & wr & w_empty),  // 쓰기 활성화 신호 (1이면 쓰기)
        .rdata()   // 읽기 데이터 출력
    );


endmodule

module memory_controller (
    input  clk,
    input  rst,
    input  wr,
    input  rd,
    input  rptr,
    input  wptr,
    output empty,
    output full
);

endmodule
