`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 10:17:34
// Design Name: 
// Module Name: sensor_cu
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


module top_sensor (
    input  clk,
    input  reset,
    input  start_trigger,
    input  data,
    output start_tick,
        output [7:0] seg_out,
        output [3:0] seg_comm
);
    wire w_tick;
    wire w_start_trigger;
    wire [15:0] w_o_data;
    sensor_cu usensor (
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .start_trigger(w_start_trigger),
        .data(data),
        .start_tick(start_tick),
        .o_data(w_o_data)
    );

    btn_debounce ubtn (
        .i_btn(start_trigger),
        .clk  (clk),
        .reset(reset),
        .o_btn(w_start_trigger)
    );

    tick_1us u1us (
        .clk  (clk),
        .reset(reset),
        .tick (w_tick)
    );
    fnd_controlloer fnd (  //control anod segments
    .clk(clk),
    .reset(reset),
    .count(w_o_data),
    .seg_out(seg_out),
    .seg_comm(seg_comm)
);

ila_0 uila(
.clk(clk),
.probe0(data),
.probe1(start_tick)
);

endmodule

module sensor_cu (
    input  clk,
    input  reset,
    input  tick,
    input  start_trigger,
    input  data,
    output start_tick,
    output [15:0] o_data
);

    parameter IDLE = 4'b0000, START = 4'b0001, WAIT = 4'b0010, DATA = 4'b0011;
    reg [3:0] state, next;
    reg [5:0] tick_count, tick_count_next;
    reg [15:0] data_reg, data_next;
    reg start_tick_reg, start_tick_next;
    assign o_data = data_reg/58;
    assign start_tick = start_tick_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            tick_count <= 0;
            data_reg <= 0;
            start_tick_reg <= 0;
        end else begin
            state <= next;
            tick_count <= tick_count_next;
            data_reg <= data_next;
            start_tick_reg <= start_tick_next;
        end
    end
    always @(*) begin
        next = state;
        data_next = data_reg;
        tick_count_next = tick_count;
        start_tick_next = start_tick_reg;
        case (state)
            IDLE:
            if (start_trigger == 1) begin
                next = START;
            end
            START:
            if (tick == 1) begin
                // data_next = 0;
                start_tick_next = 1;
                tick_count_next = tick_count + 1;
                if (tick_count_next == 10) begin
                    next = WAIT;
                    tick_count_next = 0;
                    start_tick_next = 0;
                end
            end
            WAIT:
            if (data == 1) begin
                next = DATA;
            end else begin
                next = state;
            end

            DATA:
            if (data == 1) begin
                if (tick == 1) begin
                    data_next = data_reg + 1;
                end 
            end
            else if (data == 0) begin
                if (start_trigger == 0)
                next =IDLE;
            end

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
