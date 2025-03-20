`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 16:38:18
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo ();
    reg clk;
    reg rst;
    reg wr;
    reg rd;
    reg [7:0] wdata;
    wire full;
    wire empty;
    wire [7:0] rdata;
    fifo uut (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .full(full),
        .empty(empty),
        .wdata(wdata),
        .rdata(rdata)
    );

    reg rand_rd;
    reg rand_wr;
    reg [7:0] compare_data[2**4-1:0];
    integer write_count;
    integer read_count;
    always #5 clk = ~clk;
    integer i;
    initial begin
        clk = 0;
        rst = 1;
        wdata = 8'b00;
        wr = 0;
        rd = 0;
        #10;
        rst = 0;
        #10;
        wr = 1;
        for (i = 0; i < 16; i = i + 1) begin
            wdata = $urandom_range(0, 255);
            #10;
        end
        wr = 0;
        rd = 1;

        for (i = 0; i < 16; i = i + 1) begin
            #10;
        end
        wr = 0;
        rd = 0;
        #10 wr = 1;
        rd = 0;
        for (i = 0; i < 16; i = i + 1) begin
            wdata = $urandom_range(0, 255);
            #10;
        end
        wr = 0;
        rd = 0;
        #10 wr = 1;
        rd = 1;
        for (i = 0; i < 16; i = i + 1) begin
            wdata = $urandom_range(0, 255);
            #10;
        end
        wr = 0;
        rd = 0;
        #10 wr = 0;
        rd = 1;
        for (i = 0; i < 17; i = i + 1) begin
            #10;
        end
        wr = 0;
        #10
        rd = 0;
        #20;

        write_count = 0;
        read_count  = 0;
        for (i = 0; i < 50; i = i + 1) begin
            @(negedge clk);
            rand_wr = $random % 2;
            if (!full & rand_wr) begin  // rite test
                wr = 1;
                wdata = $random % 256;
                compare_data[write_count%16] = wdata; // read data와 비교하기 위함.
                write_count = write_count + 1;
            end else begin
                wr = 0;
            end

            rand_rd = $random % 2;
            if (!empty & rand_rd) begin  // read test
                rd = 1;
                #2;
                if (rdata === compare_data[read_count%16]) begin
                    $display("Pass");
                end else begin
                    $display("Fail: rdata = %h, compare_data = %h", rdata,
                             compare_data[read_count]);
                end
                read_count = read_count + 1;
            end else begin
                rd = 0;
            end
        end
    end
endmodule
