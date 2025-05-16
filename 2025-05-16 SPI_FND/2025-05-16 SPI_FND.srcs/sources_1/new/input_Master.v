`timescale 1ns / 1ps

module input_Master #(parameter MAX_COUNT = 100_000) (
    input wire clk,
    input wire reset,
    input wire btn,
    input wire [15:0] sw,
    input wire done,
    input wire ready,
    output wire [7:0] data,
    output reg start
);

    localparam STOP = 0, LOW = 1, HIGH = 2;
    reg [1:0] state, next;
    reg start_next;
    reg [7:0] data_reg, data_next;

    assign data = data_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
            start <= 0;
            data_reg <= 0;
        end else begin
            state <= next;
            start <= start_next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        next = state;
        data_next = data_reg;
        start_next = 0;
        case (state)
            STOP: begin
                if(btn) begin
                    next = LOW;
                    
                end
            end
            LOW: begin
                start_next = ready;
                data_next = sw[7:0];
                if(done) begin
                    next = HIGH;
                end
            end
            HIGH: begin
                start_next = ready;
                data_next = sw[15:8];
                if(ready) next = STOP;
            end
        endcase
    end
endmodule
