`timescale 1ns / 1ps

module tb_memory ();
    localparam ADDR_WIDTH = 4;
    localparam DATA_WIDTH = 8;

    reg clk;
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] wdata;
    reg wr;
    wire [DATA_WIDTH-1:0] rdata;

    ram_comb #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(8)
    ) uut (
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    reg [DATA_WIDTH-1:0] rand_data;
    reg [ADDR_WIDTH-1:0] rand_addr;

    integer i;
    initial begin
        clk = 0;
        addr = 0;
        wdata = 0;
        wr = 0;
        #10;
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            rand_addr = $random % 16;
            rand_data = $random % 256;

            wr = 1;  // write

            addr = rand_addr;
            wdata = rand_data;

            @(posedge clk);
            wr = 0;  // read
            #1;
            addr = rand_addr;

            // == 값 비교, === case 비교 0 1 x z까지 다 비교
            if (rdata === wdata) begin
                $display("Test passed");
            end else begin
                $display("Test failed addr: %d, rdata: %d", addr, rdata);
            end
        end
        #10;
        $finish;
    end
endmodule
