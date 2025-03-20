`timescale 1ns / 1ps
/*0319버전에서 레지스터에 RD신호를 추가*/
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
    wire [3:0] w_wptr, w_rptr;
    assign full  = w_full;
    assign empty = w_empty;
    fifo_control_unit #(
        .ADDR_WIDTH(4),  // 주소 폭 (4비트 -> 16개의 주소)
        .DATA_WIDTH(8)   // 데이터 폭 (8비트)
    ) U_CU (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .wptr(w_wptr),
        .full(w_full),
        .rd(rd),
        .rptr(w_rptr),
        .empty(w_empty)
    );

    ram #(
        .ADDR_WIDTH(4),  // 주소 폭 (4비트 -> 16개의 주소)
        .DATA_WIDTH(8)   // 데이터 폭 (8비트)
    ) U_reg1 (
        .clk(clk),
        .wr(wr & ~w_full),
        .rd(rd & ~w_empty),
        .wptr(w_wptr),
        .wdata(w_data),
        .rptr(w_rptr),
        .rdata(r_data)
    );


endmodule

module ram #(
    parameter ADDR_WIDTH = 4,  // 주소 폭 (4비트 -> 16개의 주소)
    parameter DATA_WIDTH = 8   // 데이터 폭 (8비트)
) (
    input                   clk,    // 클럭 신호
    input                   wr,
    input                   rd,     // 쓰기 활성화 신호 (1이면 쓰기)
    input  [ADDR_WIDTH-1:0] wptr,   // 쓰기주소
    input  [DATA_WIDTH-1:0] wdata,  // 쓰기 데이터 입력
    input  [ADDR_WIDTH-1:0] rptr,   // 읽기주소
    output [DATA_WIDTH-1:0] rdata   // 읽기 데이터 출력
);

    // RAM 메모리 선언 (2^ADDR_WIDTH 크기)
    reg [DATA_WIDTH-1:0] ram[0:(1<<ADDR_WIDTH)-1];

    reg [DATA_WIDTH-1:0] w_rdata;
    assign rdata = w_rdata;
    always @(posedge clk) begin
        if (wr) ram[wptr] <= wdata;  // 쓰기 동작
        
        if (rd) begin
            w_rdata = ram[rptr];  // 주소에 해당하는 데이터 출력
        end

    end

endmodule

module fifo_control_unit #(
    parameter ADDR_WIDTH = 4,  // 주소 폭 (4비트 -> 16개의 주소)
    parameter DATA_WIDTH = 8   // 데이터 폭 (8비트)
) (
    input clk,
    input rst,
    input wr,
    output [3:0] wptr,
    output full,
    input rd,
    output [3:0] rptr,
    output empty
);
    reg full_reg, full_next;
    reg empty_reg, empty_next;
    reg [3:0] wptr_reg, wptr_next;
    reg [3:0] rptr_reg, rptr_next;

    //output
    assign wptr  = wptr_reg;
    assign rptr  = rptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 최초상태 빈상태
            full_reg  <= 0;
            empty_reg <= 1;
            wptr_reg  <= 0;
            rptr_reg  <= 0;
        end else begin
            full_reg  <= full_next;
            empty_reg <= empty_next;
            wptr_reg  <= wptr_next;
            rptr_reg  <= rptr_next;
        end
    end

    reg [1:0] wr_rd;
    always @(*) begin
        wr_rd = {wr, rd};
        full_next = full_reg;
        empty_next = empty_reg;
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;

        case (wr_rd)
            2'b01: begin  // pop
                if (!empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 0;
                    // 다음의 "끝"(pop)주소 상태가 지금의 "처음"(push)주소와 동일시 빈판정
                    if (rptr_next == wptr_reg) begin
                        empty_next = 1;
                    end
                end
            end
            2'b10: begin  // push
                if (!full_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 0;
                    // 다음의 "처음"(push)주소 상태가 지금의 "끝"(pop) 주소와 동일시 꽉판정
                    if (wptr_next == rptr_reg) begin
                        full_next = 1;
                    end
                end
            end
            2'b11: begin  //pop & push
                if (empty_reg) begin  // 빈상태
                    //pop은 비엇으니 생략
                    wptr_next  = wptr_reg + 1;  //push만 할겨
                    empty_next = 0;
                    if (wptr_next == rptr_reg) begin
                        full_next = 1;
                    end
                end else if (full_reg) begin  // 꽉상태
                    rptr_next = rptr_reg + 1;
                    //push는 꽉찼으니 생략
                    full_next = 0;
                    if (rptr_next == wptr_reg) begin
                        empty_next = 1;
                    end
                end else begin  //둘 다 가능한 상태
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
            end

        endcase
    end

endmodule
