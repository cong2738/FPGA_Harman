`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input        rx,
    output       tx,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] fndData;
    wire [ 3:0] dot_data;
    wire [ 7:0] rx_data;

    UART u_UART (
        .clk    (clk),
        .reset  (reset),
        .tx_data(rx_data),
        .trigger(rx_done),
        .rx     (rx),
        .tx     (tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    counter_up_down u_counter_up_down (
        .clk     (clk),
        .reset   (reset),
        .cmd     (rx_data),
        .cmdtick (rx_done),
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
    input  [ 7:0] cmd,
    input         cmdtick,
    output [13:0] count,
    output [ 3:0] dot_data
);
    wire tick;
    wire [2:0] count_state;

    cmd_box u_cmd_box (
        .cmd    (cmd),
        .cmdtick(cmdtick),
        .run    (run),
        .stop   (stop),
        .clear  (clear),
        .mode   (mode)
    );

    counter_CU u_counter_CU (
        .clk        (clk),
        .reset      (reset),
        .run        (run),
        .stop       (stop),
        .clear      (clear),
        .mode       (mode),
        .count_state(count_state)
    );

    clk_div_10hz U_Clk_Div_10Hz (
        .clk(clk),
        .reset(reset),
        .count_state(count_state),
        .tick(tick)
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
    input         clk,
    input         reset,
    input         tick,
    input  [ 2:0] count_state,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (count_state[2]) begin
            counter <= 0;
        end else if (count_state[1]) begin
            if (tick) begin
                if (counter == 9999) begin
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end
        end else if (count_state[0]) begin
            if (tick) begin
                if (counter == 0) begin
                    counter <= 9999;
                end else begin
                    counter <= counter - 1;
                end
            end
        end

    end
endmodule

module clk_div_10hz (
    input wire clk,
    input wire reset,
    input [2:0] count_state,
    output reg tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else if (count_state[2]) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else if (count_state) begin
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
    input run,
    input stop,
    input clear,
    input mode,
    output [2:0] count_state
);
    localparam STOP = 3'b000, DOWN = 3'b001, UP = 3'b010, CLEAR = 3'b100;

    reg [2:0] state, next;
    reg mode_curr, next_mode;

    assign count_state = state;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            mode_curr <= 0;
        end else begin
            state <= next;
            mode_curr <= next_mode;
        end
    end


    always @(*) begin
        next = state;
        next_mode = mode_curr;
        case (state)
            STOP: begin
                if (clear) next = CLEAR;
                else if(mode) begin
                    if (mode_curr) next_mode = 0;
                    else if (!mode_curr) next_mode = 1;
                end
                else if (run) begin
                    if (mode_curr) next = DOWN;
                    else if (!mode_curr) next = UP;
                end
            end

            UP: begin
                next_mode = 0;
                if (stop) next = STOP;
                else if (clear) next = CLEAR;
                else if (mode) next = DOWN;
            end

            DOWN: begin
                next_mode = 1;
                if (stop) next = STOP;
                else if (clear) next = CLEAR;
                else if (mode) next = UP;
            end

            CLEAR: begin
                next = STOP;
            end
        endcase
    end
endmodule

module cmd_box (
    input [7:0] cmd,
    input cmdtick,
    output reg run,
    output reg stop,
    output reg clear,
    output reg mode
);
    always @(*) begin
        run   = 0;
        stop  = 0;
        clear = 0;
        mode  = 0;
        case (cmd)
            "r": run = cmdtick;
            "s": stop = cmdtick;
            "c": clear = cmdtick;
            "m": mode = cmdtick;
        endcase
    end
endmodule
