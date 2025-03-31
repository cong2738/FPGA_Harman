`timescale 1ns / 1ps


module univ_cu (
    input clk,
    input reset,
    input [7:0] command,
    input data,
    output [1:0] mode_sel,
    output com_run,
    output com_clear,
    output com_sec,
    output com_min,
    output com_hour,
    output com_start
);

    uart_cu u_uart_cu (
        .clk      (clk),
        .reset    (reset),
        .data     (data),
        .command  (command),
        .com_run  (com_run),
        .com_clear(com_clear),
        .com_sec  (com_sec),
        .com_min  (com_min),
        .com_hour (com_hour),
        .com_start(com_start),
        .mode_sel (mode_sel)
    );

endmodule


module uart_cu (
    input clk,
    input reset,
    input data,
    input [7:0] command,
    output reg com_run,
    output reg com_clear,
    output reg com_sec,
    output reg com_min,
    output reg com_hour,
    output reg com_start,
    output reg [1:0] mode_sel
);

    reg  data_prev;
    wire data_1clk;

    assign data_1clk = data & ~data_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            com_run   <= 0;
            com_clear <= 0;
            com_sec   <= 0;
            com_min   <= 0;
            com_hour  <= 0;
            com_start <= 0;
        end else begin
            data_prev <= data;
            if (data_1clk) begin
                com_run   <= 0;
                com_clear <= 0;
                com_sec   <= 0;
                com_min   <= 0;
                com_hour  <= 0;
                com_start <= 0;
                case (command)
                    "R": com_run <= 1;
                    "C": com_clear <= 1;
                    "M": com_min <= 1;
                    "S": com_sec <= 1;
                    "H": com_hour <= 1;
                    "B": com_start <= 1;
                endcase

                case (command)
                    "0": begin
                        mode_sel = 0;
                    end
                    "1": begin
                        mode_sel = 1;
                    end
                    "2": begin
                        mode_sel = 2;
                    end
                endcase

            end else begin
                com_run   <= 0;
                com_clear <= 0;
                com_sec   <= 0;
                com_min   <= 0;
                com_hour  <= 0;
                com_start <= 0;
            end
        end
    end
endmodule
