`timescale 1ns / 1ps

module send_tx_btn1 (
    input  clk,
    input  rst,
    input  btn_start,
    output tx
);
    wire d_start;
    btn_debounce U_btn_Debounce (
        .clk  (clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(d_start)
    );

    wire w_tx_busy;
    wire [7:0] i_uart_data;
    uart #(
        .BAUD_RATE(9600)
    ) U_Uart (
        .clk(clk),
        .rst(rst),
        .btn_start(d_start),
        .uart_data(i_uart_data),
        .tx(tx),
        .tx_busy(w_tx_busy)
    );

    //send tx ascii to PC
    reg[7:0] data_curr, data_next;

    assign i_uart_data = data_curr;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data_curr <= "0"-1;
        end else begin
            data_curr <= data_next;
        end
    end

    always @(*) begin
        data_next = data_curr;
        if (d_start) begin  // debounsed start triger
            if (data_next == "z") begin
                data_next = "0";
            end else data_next = data_curr + 1;  // increase 1 for ASCII
        end
    end

endmodule