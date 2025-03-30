`timescale 1ns / 1ps

module TOP_DHT11 (
    input        clk,
    input        rst,
    input        btn_start,
    // output       data,
    output [3:0] sensor_LED,
    inout        dht_IO
);
    wire tick_1us;
    tick_1us U_1us (
        .clk  (clk),
        .reset(rst),
        .tick (tick_1us)
    );
    DHT_CU U_DHT_CU (
        .clk(clk),
        .rst(rst),
        .tick_1us(tick_1us),
        .btn_start(btn_start),
        .sensor_LED(sensor_LED),
        .data(data),
        .dht_IO(dht_IO)
    );
endmodule

module DHT_CU (
    input        clk,
    input        rst,
    input        tick_1us,
    input        btn_start,
    output [3:0] sensor_LED,
    output       data,
    inout        dht_IO
);
    localparam IDLE = 3'b000, START = 3'b001, WAIT = 3'b010, READ = 3'b100;
    localparam START_TIME = 18, WAIT_TIME = 30;
    reg [2:0] state, next;
    reg [$clog2(30)-1:0] us_count_reg, us_count_next;
    reg LED_reg, LED_next;
    reg io_oe_reg, io_oe_next;
    reg io_out_reg, io_out_next;

    // out 3state on/off
    assign dht_IO = (io_oe_reg) ? io_out_reg : 1'bz;

    assign sensor_LED = {LED_reg, state};

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            us_count_reg <= 0;
            io_out_reg <= 1;
            LED_reg <= 0;
            io_oe_reg <= 0;
        end else begin
            state <= next;
            us_count_reg <= us_count_next;
            LED_reg <= LED_next;
            io_oe_reg <= io_oe_next;
            io_out_reg <= io_out_next;
        end
    end

    always @(*) begin
        next = state;
        us_count_next = us_count_reg;
        LED_next = LED_reg;
        io_oe_next = io_oe_reg;
        io_out_next = io_out_reg;
        case (state)
            IDLE: begin
                LED_next = 0;
                io_out_next = 1;
                io_oe_next = 1;
                if (btn_start) begin
                    us_count_next = 0;
                    next = START;
                end
            end
            START: begin
                io_out_next = 0;
                if (tick_1us) begin
                    if (us_count_reg == START_TIME - 1) begin
                        us_count_next = 0;
                        next = WAIT;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            WAIT: begin
                io_out_next = 1;
                if (tick_1us) begin
                    if (us_count_reg == WAIT_TIME - 1) begin
                        us_count_next = 0;
                        next = READ;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            READ: begin
                // io oe change
                io_oe_next  = 0;
                // output open, High_z
                io_out_next = 1'bz;

                if (dht_IO) LED_next = 1;
                else LED_next = 0;

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
