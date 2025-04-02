`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input        mode,
    input        run,
    input        clear,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] fndData;
    wire [ 3:0] dot_data;

    counter_up_down u_counter_up_down (
        .clk     (clk),
        .reset   (reset),
        .mode    (mode),
        .run     (run),
        .clear   (clear),
        .count   (fndData),
        .dot_data(dot_data)
    );

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .dot_data(dot_data),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );
endmodule

module counter_up_down (
    input         clk,
    input         reset,
    input         mode,
    input         run,
    input         clear,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;
    wire [$clog2(3)-1:0] count_state;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter_CU u_counter_CU (
        .clk        (clk),
        .reset      (reset),
        .mode       (mode),
        .run        (run),
        .clear      (clear),
        .count_state(count_state)
    );

    counter U_Counter_Up_Down (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .count_state(count_state),
        .count(count)
    );

    dot_data_ctrl u_dot_data_ctrl (
        .bcd     (count),
        .dot_data(dot_data)
    );

endmodule


module counter (
    input                  clk,
    input                  reset,
    input                  tick,
    input  [$clog2(3)-1:0] count_state,
    output [         13:0] count
);
    localparam STOP = 0, DOWN = 1, UP = 2, CLEAR = 3;
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (count_state != STOP) begin
            if (count_state == CLEAR) counter <= 0;
            else if (count_state == UP) begin
                if (tick) begin
                    if (counter == 9999) begin
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            end else if (count_state == DOWN) begin
                if (tick) begin
                    if (counter == 0) begin
                        counter <= 9999;
                    end else begin
                        counter <= counter - 1;
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    output reg  tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

module dot_data_ctrl (
    input [$clog2(9999)-1:0] bcd,
    output [3:0] dot_data
);
    assign dot_data = (bcd % 10 < 5) ? 4'b1101 : 4'b1111;

endmodule

module counter_CU (
    input clk,
    input reset,
    input mode,
    input run,
    input clear,
    output [$clog2(3)-1:0] count_state
);
    localparam STOP = 0, DOWN = 1, UP = 2, CLEAR = 3;

    reg [$clog2(3)-1:0] state, next;

    assign count_state = state;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (clear) next = CLEAR;
                else if (run) begin
                    if (mode) next = DOWN;
                    else next = UP;
                end
            end

            UP: begin
                if (!run) next = STOP;
                else if (clear) next = CLEAR;
                else if (mode) next = DOWN;
            end

            DOWN: begin
                if (!run) next = STOP;
                else if (clear) next = CLEAR;
                else if (!mode) next = UP;
            end

            CLEAR: begin
                if (!clear) begin
                    if (!run) next = STOP;
                    else begin
                        if (mode) next = DOWN;
                        else next = UP;
                    end
                end
            end
        endcase
    end
endmodule
