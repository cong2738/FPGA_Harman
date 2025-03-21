`timescale 1ns / 1ps

module Top_UART_String (
    input  clk,
    input  rst,
    input  rx,
    output tx
);
    wire [7:0] w_rx_data;
    wire [7:0] w_rxmem_data;
    wire [7:0] w_txmem_data;
    wire w_rx_done;
    wire w_rxmem_empty;
    wire w_txmem_full;
    wire w_txmem_empty;
    wire w_tx_busy;

    // uart #(
    //     .BAUD_RATE(9600)
    // ) U_UART (
    //     .clk(clk),
    //     .rst(rst),
    //     .tx_start_triger(~w_txmem_empty),
    //     .tx_data(w_txmem_data),
    //     .rx(rx),
    //     .tx(tx),
    //     .tx_busy(w_tx_busy),
    //     .rx_data(w_rx_data),
    //     .rx_done(w_rx_done)
    // );
    Uart8 #(
        .CLOCK_RATE(100_000_000),  // board internal clock
        .BAUD_RATE (9_600)
    ) U_UART (  
        .clk (clk),
        // rx interface
        .rx(rx),
        .rxEn(rst),
        .out(w_rx_data),
        .rxDone(w_rx_done),
        .rxBusy(),
        .rxErr(),

        // tx interface
        .tx(tx),
        .txEn(rst),
        .txStart(~w_txmem_empty),
        .in(w_txmem_data),
        .txDone(),
        .txBusy(w_tx_busy)
    );

    fifo #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(8)
    ) U_Rx_Mem (
        .clk(clk),
        .rst(rst),
        .wdata(w_rx_data),
        .wr(w_rx_done),
        .full(),
        .rd(~w_txmem_full),
        .rdata(w_rxmem_data),
        .empty(w_rxmem_empty)
    );

    fifo #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(8)
    ) U_Tx_Mem (
        .clk(clk),
        .rst(rst),
        .wdata(w_rxmem_data),
        .wr(~w_rxmem_empty),
        .full(w_txmem_full),
        .rd(~w_tx_busy),
        .rdata(w_txmem_data),
        .empty(w_txmem_empty)
    );


endmodule
