`timescale 1ns / 1ps

module top_sensor (
    input clk,
    input reset,
    input start_trigger,
    input data,
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

    wire tx;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    uart #(
        .BAUD_RATE(9600)
    ) U_UART (
        .clk(clk),
        .rst(rst),
        .tx_start_triger(tx_start_triger),
        .tx_data(tx_data),
        .rx(rx),
        .tx(tx),
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule

module dc_divider #(
    MAX_BCD = 100
) (
    input clk,
    input reset,
    input wr,
    input rd,
    input [$clog2(MAX_BCD)-1:0] bcd,
    input [1:0] idx,
    output read_done,
    output [7:0] o_char
);
    localparam IDLE = 0, WRITE = 0, READ = 0;
    reg data_on;
    reg [7:0] mem[0:3];
    reg [1:0] state, next;
    reg [7:0] bcd_reg, bcd_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state   <= 0;
            bcd_reg <= 0;
        end else begin
            state   <= next;
            bcd_reg <= bcd_next;
        end
    end

    always @(*) begin
        next <= state;
        bcd_next <= bcd_reg;
        case (state)
            IDLE: begin
                if (wr) begin
                    next = WRITE;
                end else if (rd) begin
                    next = READ;
                end else next = IDLE;
            end
            WRITE: begin
                mem[0] = bcd % 10 + "0";
                mem[1] = bcd / 10 % 10 + "0";
                mem[2] = bcd / 100 % 10 + "0";
                mem[3] = bcd / 1000 % 10 + "0";
                data_on = 1;
                next = 0;
            end
            READ: begin
                data_on  = 0;
                bcd_next = mem[idx];
            end
        endcase
    end

    assign o_char = bcd_reg;
endmodule

module sensor_cu #(
    parameter MAX_DISTANCE = 100
) (
    input clk,
    input reset,
    input tick,
    input start_trigger,
    input data,
    output start_tick,
    output [$clog2(MAX_DISTANCE):0] o_data
);

    parameter IDLE = 4'b0000, START = 4'b0001, WAIT = 4'b0010, DATA = 4'b0011;
    reg [3:0] state, next;
    reg [5:0] tick_count, tick_count_next;
    reg [$clog2(MAX_DISTANCE*58):0] data_reg, data_next;
    reg start_tick_reg, start_tick_next;
    assign o_data = data_reg / 58;
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
                data_next = 0;
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
                    if (data_next == MAX_DISTANCE*58) begin
                        data_next = 0;
                        next = IDLE;
                    end
                end

            end else if (data == 0) begin
                tick_count_next = 0;
                next = IDLE;
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
