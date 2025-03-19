`timescale 1ns / 1ps

module fifo (
    input clk,
    input rst,
    input [7:0] w_data,
    input wr,
    output full,
    input rd,
    output [7:0] r_data,
    output empty
);
    wire w_empty, w_full;
    wire [3:0] w_waddr, w_raddr;
    assign empty = w_empty;
    assign full  = w_full;
    memory_controller U_CU (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .waddr(w_waddr),
        .full(w_full),
        .rd(rd),
        .raddr(w_raddr),
        .empty(w_empty)
    );

    register_file #(
        .ADDR_WIDTH(4),  // 주소 폭 (4비트 -> 16개의 주소)
        .DATA_WIDTH(8)   // 데이터 폭 (8비트)
    ) U_reg1 (
        .clk(clk),
        .wr(),
        .rd(),
        .waddr(w_waddr),
        .wdata(),
        .raddr(w_r_addr),
        .rdata()
    );


endmodule

module register_file #(
    parameter ADDR_WIDTH = 4,  // 주소 폭 (4비트 -> 16개의 주소)
    parameter DATA_WIDTH = 8   // 데이터 폭 (8비트)
) (
    input clk,
    input wr,
    input rd,
    input [3:0] waddr,
    input [7:0] wdata,
    input [3:0] raddr,
    output [7:0] rdata
);
    reg [7:9] mem[0:2**4-1];

    //write
    always @(posedge clk) begin
        if (wr) begin
            mem[waddr] <= wdata;
        end
    end

    //read
    assign rdata = mem[raddr];

endmodule

module fifo_control_unit #(
    parameter ADDR_WIDTH = 4,  // 주소 폭 (4비트 -> 16개의 주소)
    parameter DATA_WIDTH = 8   // 데이터 폭 (8비트)
)(
    input clk,
    input rst,
    input wr,
    output [3:0] waddr,
    output full,
    input rd,
    output [3:0] raddr,
    output empty
);
    reg full_reg, full_next;
    reg empty_reg, empty_next;
    reg [3:0] waddr_reg, waddr_next;
    reg [3:0] raddr_reg, raddr_next;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 최초상태 빈상태
            full_reg  <= 0;
            empty_reg <= 1;
            waddr_reg <= 0;
            raddr_reg <= 0;
        end else begin
            full_reg  <= full_next;
            empty_reg <= empty_next;
            waddr_reg <= waddr_next;
            raddr_reg <= raddr_next;
        end
    end

    always @(*) begin
        full_next  = full_reg;
        empty_next = empty_reg;
        waddr_next = waddr_reg;
        raddr_next = raddr_reg;
        case({wr,rd})
            2'b01: begin // pop
                if(!empty_reg) begin
                     raddr_next = raddr_reg + 1;
                     full_next = 0;
                     // 다음의 "끝"(pop)주소 상태가 지금의 "처음"(push)주소와 동일시 빈판정
                     if(raddr_next == waddr_reg) begin 
                        empty_next  = 1;
                     end
                end
            end
            2'b10: begin // push
                if(!full_reg) begin
                    waddr_next = waddr_reg + 1;
                    empty_next = 0;
                    // 다음의 "처음"(push)주소 상태가 지금의 "끝"(pop) 주소와 동일시 꽉판정
                    if(waddr_next == ADDR_WIDTH) begin 
                        full_next = 1;
                    end
                end
            end

        endcase
    end

endmodule
