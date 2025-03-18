`timescale 1ns / 1ps

module send_tx_btn #(
    parameter BAUD_RATE = 9600
) (
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
    wire uart_start;
    shot_15tic U_Shot (
        .start_shot(d_start),
        .tx_busy(w_tx_busy),
        .clk(clk),
        .rst(rst),
        .tx_tirgger(uart_start)
    );

    wire [7:0] i_uart_data;
    uart #(
        .BAUD_RATE(BAUD_RATE)
    ) U_Uart (
        .clk(clk),
        .rst(rst),
        .btn_start(uart_start),
        .uart_data(i_uart_data),
        .tx(tx),
        .tx_busy(w_tx_busy)
    );

    //send tx ascii to PC
    reg [7:0] data_curr, data_next;

    assign i_uart_data = data_curr;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data_curr <= "0" - 1;
        end else begin
            data_curr <= data_next;
        end
    end

    always @(*) begin
        data_next = data_curr;
        if (uart_start) begin  // debounsed start triger
            if (data_next == "z") begin
                data_next = "0";
            end else data_next = data_curr + 1;  // increase 1 for ASCII
        end else begin
            data_next = data_curr;
        end
    end

endmodule

module shot_15tic (
    input  start_shot,
    input  tx_busy,
    input  clk,
    input  rst,
    output tx_tirgger
);
    localparam STOP = 0, RUN = 1;

    reg state, next;
    reg cur_trigger, next_trigger;
    reg [3:0] count_reg, count_next;

    assign tx_tirgger = cur_trigger;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            cur_trigger <= 0;
            count_reg <= 0;
        end else begin
            state = next;
            cur_trigger = next_trigger;
            count_reg = count_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        next = state;
        next_trigger = 0;
        case (state)
            STOP: begin
                if (start_shot) begin
                    next = RUN;
                end
            end
            RUN: begin
                if (!tx_busy) begin
                    next_trigger = 1;
                    if (count_reg == 15) begin
                        count_next = 0;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end else if (count_reg == 15) begin
                    next = STOP;
                    count_next = 0;
                end else begin
                    next_trigger = 0;
                    count_next = count_reg;
                end
            end
            default: ;
        endcase
    end
endmodule
