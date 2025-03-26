`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 11:42:41
// Design Name: 
// Module Name: TOP_DHT11
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


module TOP_DHT11 (
    input clk,
    input rst,
    input btn_start,
    output sensor_LED,
    output [3:0] current_state,
    output data,
    inout dht_IO
);
    tick_1us U_1us (
        .clk  (clk),
        .reset(reset),
        .tick (tick_1us)
    );
    DHT_CU U_DHT(
    .clk(clk),
    .rst(rst),
    .tick_1us(tick_1us),
    .btn_start(btn_start),
    .sensor_LED(sensor_LED),
    .current_state(current_state),
    .data(data),
    .dht_IO(dht_IO)
);
endmodule

module DHT_CU (
    input clk,
    input rst,
    input tick_1us,
    input btn_start,
    output sensor_LED,
    output [3:0] current_state,
    output data,
    inout dht_IO
);
    parameter IDLE = 3'b000, START = 3'b001, WAIT = 3'b010, READ = 3'b100;

    reg [1:0] state, next;
    reg [$clog2(30)-1:0] us_count_reg, us_count_next;
    reg dht_IO_reg, dht_IO_next;
    reg LED_reg, LED_next;

    assign dht_IO = dht_IO_reg;
    assign current_state = state;
    assign sensor_LED = LED_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            us_count_reg <= 0;
            dht_IO_reg <= 1;
            LED_reg <= 0;
        end else begin
            state <= next;
            us_count_reg <= us_count_next;
            dht_IO_reg <= dht_IO_next;
            LED_reg <= LED_next;
        end
    end

    always @(*) begin
        next <= state;
        us_count_next <= us_count_reg;
        dht_IO_next <= dht_IO_reg;
        LED_next <= LED_reg;
        case (state)
            IDLE: begin
                LED_next = 0;
                dht_IO_next = 1;
                if (btn_start) begin
                    us_count_next = 0;
                    next = START;
                end
            end
            START: begin
                dht_IO_next = 0;
                if (tick_1us) begin
                    if (us_count_reg == 18) begin
                        us_count_next = 0;
                        next = WAIT;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            WAIT: begin
                dht_IO_next = 1;
                if (tick_1us) begin
                    if (us_count_reg == 30) begin
                        us_count_next = 0;
                        next = READ;
                        LED_reg = 1;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            READ: begin
                LED_next = 1;
                dht_IO_next = dht_IO;
                if (dht_IO == 0) begin
                    next = IDLE;
                end
            end

            default: next = IDLE;
        endcase
    end
endmodule

module tick_1us (
    input  clk,
    input  reset,
    output tick
);

    parameter BAUD_RATE = 9600;
    localparam BAUD_COUNT = 100;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;

    reg tick_reg, tick_next;
    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset == 1) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end


    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next  = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 1'b0;
        end
    end

endmodule
