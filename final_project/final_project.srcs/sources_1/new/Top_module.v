`timescale 1ns / 1ps

module Top_module(
    input clk,
    input reset,
    input rx,
    output tx,
    output [7:0] command,
    output data
);
    wire [7:0] w_tx_rdata, w_rx_wdata, w_fifo_rx_tx_data;
    wire w_tx_start, w_tx_done, w_rx_done;
    wire w_full_rd, w_empty_wr;
    wire [7:0] w_tx_rx_dataout;

    assign command = w_rx_wdata;
    assign data = w_rx_done;

    fifo_tx U_FIFO_TX (
        .clk(clk),
        .reset(reset),
    // write
        .wdata(w_fifo_rx_tx_data),
        .wr(~w_empty_wr),
        .full(w_full_rd),
    // read
        .rd(~w_tx_done & ~w_tx_start),
        .rdata(w_tx_rdata),
        .empty(w_tx_start)
    );
    
    fifo_rx U_FIFO_RX (
        .clk(clk),
        .reset(reset),
    // write
        .wdata(w_rx_wdata),
        .wr(w_rx_done),
        .full(),
    // read
        .rd(~w_full_rd),
        .rdata(w_fifo_rx_tx_data),
        .empty(w_empty_wr)
    );
    uart_fsm U_Uart_FSM (
        .clk(clk),         // 시스템 클럭 입력
        .rst(reset),         // 비동기 리셋 신호
        // tx
        .btn_start(~w_tx_start),   // 데이터 전송 시작 트리거
        .tx_data_in(w_tx_rx_dataout),
        .tx_done(w_tx_done),
        .tx(tx),  // pc로 감
        //rx
        .rx(rx),  // pc로 감
        .rx_done(w_rx_done),     // UART 송신 신호 (시리얼 출력) 
        .rx_data(w_rx_wdata)
    );

    data_save U_Data_Save(
        .clk(clk),
        .reset(reset),
        .rd(~w_empty_wr),
        .data_in(w_fifo_rx_tx_data),
        .data_out(w_tx_rx_dataout)
    );

endmodule

module data_save(
    input clk,
    input reset,
    input rd,
    input [7:0] data_in,
    output [7:0] data_out
    );
    reg [7:0] data_reg,data_next;
    assign data_out = data_reg;
    always @(posedge clk) begin
        if (reset) begin
            data_reg <=0;
        end
        else begin
            data_reg <= data_next;
        end
    end
    always@(*) begin
        data_next = data_reg;
        if(rd) begin
            data_next = data_in;
        end
    end
endmodule

