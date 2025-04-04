`timescale 1ns / 1ps

module top (
    input        clk,
    input        reset,
    input        btnU,
    input        btnL,
    input        btnR,
    input        btnD,
    input        rx,
    output       tx,
    output [3:0] fndCom,
    output [7:0] fndFont,
    output       led
);
    wire [13:0] fndData;
    wire [3:0] fndDot;
    wire [13:0] count;
    wire [3:0] c_dot_data;
    wire [13:0] s_t;
    wire [3:0] s_dot_data;

    wire tx_trigger;
    wire [7:0] tx_data;
    wire tx_done;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    wire rx_busy;

    uart u_uart (
        .clk       (clk),
        .reset     (reset),
        .tx_trigger(tx_trigger),
        .tx_data   (tx_data),
        .rx        (rx),
        .tx        (tx),
        .tx_done   (tx_done),
        .tx_busy   (tx_busy),
        .rx_data   (rx_data),
        .rx_done   (rx_done),
        .rx_busy   (rx_busy)
    );

    btn_CU u_btn_CU (
        .clk   (clk),
        .reset (reset),
        .btnU  (btnU),
        .btnL  (btnL),
        .btnR  (btnR),
        .btnD  (btnD),
        .d_btnU(d_btnU),
        .d_btnL(d_btnL),
        .d_btnR(d_btnR),
        .d_btnD(d_btnD)
    );

    control_unit u_control_unit (
        .clk            (clk),
        .reset          (reset),
        .d_btnU         (d_btnU),
        .d_btnL         (d_btnL),
        .d_btnR         (d_btnR),
        .d_btnD         (d_btnD),
        .rx_data        (rx_data),
        .rx_done        (rx_done),
        .tx_done        (tx_done),
        .tx_busy        (tx_busy),
        .tx_data        (tx_data),
        .tx_trigger     (tx_trigger),
        .counter_en     (counter_en),
        .counter_clear  (counter_clear),
        .counter_mode   (counter_mode),
        .stopwatch_en   (stopwatch_en),
        .stopwatch_clear(stopwatch_clear),
        .sel            (sel)
    );

    counter_up_down U_Counter (
        .clk     (clk),
        .reset   (reset),
        .en      (counter_en),
        .clear   (counter_clear),
        .mode    (counter_mode),
        .count   (count),
        .dot_data(c_dot_data)
    );

    my_stopWatch u_my_stopWatch (
        .clk     (clk),
        .reset   (reset),
        .en      (stopwatch_en),
        .clear   (stopwatch_clear),
        .t       (s_t),
        .dot_data(s_dot_data)
    );

    mode_4x2_mux u_mode_4x2_mux (
        .sel       (sel),
        .count     (count),
        .c_dot_data(c_dot_data),
        .t         (s_t),
        .s_dot_data(s_dot_data),
        .fndData   (fndData),
        .fndDot    (fndDot)
    );

    fndController U_FndController (
        .clk    (clk),
        .reset  (reset),
        .fndData(fndData),
        .fndDot (fndDot),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );
    assign led = sel;
endmodule

module btn_CU (
    input  clk,
    input  reset,
    input  btnU,
    input  btnL,
    input  btnR,
    input  btnD,
    output d_btnU,
    output d_btnL,
    output d_btnR,
    output d_btnD

);
    btn_debounce u_btnU_debounce (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnU),
        .o_btn(d_btnU)
    );

    btn_debounce u_btnL_debounce (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnL),
        .o_btn(d_btnL)
    );

    btn_debounce u_btnR_debounce (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnR),
        .o_btn(d_btnR)
    );

    btn_debounce u_btnD_debounce (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnD),
        .o_btn(d_btnD)
    );
endmodule

module control_unit (
    input            clk,
    input            reset,
    input            d_btnU,
    input            d_btnL,
    input            d_btnR,
    input            d_btnD,
    input      [7:0] rx_data,
    input            rx_done,
    input            tx_done,
    input            tx_busy,
    output reg [7:0] tx_data,
    output reg       tx_trigger,
    output reg       counter_en,
    output reg       counter_clear,
    output reg       counter_mode,
    output reg       stopwatch_en,
    output reg       stopwatch_clear,
    output reg       sel
);
    localparam STOP = 0, RUN = 1, CLEAR = 2;
    localparam UP = 0, DOWN = 1;
    localparam IDLE = 0, ECHO = 1;
    localparam COUNTER = 0, STOPWATCH = 1;

    reg [1:0] counter_state, counter_state_next;
    reg [1:0] stopwatch_state, stopwatch_state_next;
    reg mode_state, mode_next;
    reg echo_state, echo_next;
    reg watch_state, watch_next;

    cmd_box u_cmd_box (
        .rx_data   (rx_data),
        .rx_done   (rx_done),
        .cmd_tick_Q(cmd_tick_Q),
        .cmd_tick_R(cmd_tick_R),
        .cmd_tick_S(cmd_tick_S),
        .cmd_tick_C(cmd_tick_C),
        .cmd_tick_M(cmd_tick_M)
    );

    // state_management
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_state <= STOP;
            stopwatch_state <= STOP;
            mode_state <= UP;
            echo_state <= IDLE;
            watch_state <= COUNTER;
        end else begin
            counter_state <= counter_state_next;
            stopwatch_state <= stopwatch_state_next;
            mode_state <= mode_next;
            echo_state <= echo_next;
            watch_state <= watch_next;
        end
    end

    // echo_next logic
    always @(*) begin
        tx_data = 0;
        tx_trigger = 1'b0;
        echo_next = echo_state;
        case (echo_state)
            IDLE: begin
                tx_data = 7'b0;
                tx_trigger = 1'b0;
                if (rx_done) begin
                    echo_next = ECHO;
                end
            end
            ECHO: begin
                if (tx_done) begin
                    echo_next = IDLE;
                end else begin
                    tx_data = rx_data;
                    tx_trigger = 1'b1;
                end
            end
        endcase
    end

    // watch_mode_next_logic
    always @(*) begin
        sel = 0;
        watch_next = watch_state;
        case (watch_state)
            COUNTER: begin
                sel = 0;
                if (cmd_tick_Q || d_btnR) begin
                    watch_next = STOPWATCH;
                end
            end
            STOPWATCH: begin
                sel = 1;
                if (cmd_tick_Q || d_btnR) begin
                    watch_next = COUNTER;
                end
            end
        endcase
    end

    // counter_next logic
    always @(*) begin
        counter_state_next    = counter_state;
        counter_en    = 1'b0;
        counter_clear = 1'b0;
        counter_mode = 1'b0;
        mode_next = mode_state;
        if (sel == COUNTER) begin
            case (counter_state)
                STOP: begin
                    counter_en = 1'b0;
                    counter_clear = 1'b0;
                    if (cmd_tick_R || d_btnL) counter_state_next = RUN;
                    else if (cmd_tick_C || d_btnU) counter_state_next = CLEAR;
                end
                RUN: begin
                    counter_en = 1'b1;
                    counter_clear = 1'b0;
                    if (cmd_tick_S || d_btnL) counter_state_next = STOP;
                end
                CLEAR: begin
                    counter_en = 1'b0;
                    counter_clear = 1'b1;
                    counter_state_next = STOP;
                end
            endcase

            case (mode_state)
                UP: begin
                    counter_mode = 0;
                    if (cmd_tick_M || d_btnD) mode_next = DOWN;
                end
                DOWN: begin
                    counter_mode = 1;
                    if (cmd_tick_M || d_btnD) mode_next = UP;
                end
            endcase
        end
    end

    // stopwatch_next logic
    always @(*) begin
        stopwatch_state_next    = stopwatch_state;
        stopwatch_en    = 1'b0;
        stopwatch_clear = 1'b0;
        if (sel == STOPWATCH) begin
            case (stopwatch_state)
                STOP: begin
                    stopwatch_en = 1'b0;
                    stopwatch_clear = 1'b0;
                    if (cmd_tick_R || d_btnL) stopwatch_state_next = RUN;
                    else if (cmd_tick_C || d_btnU) stopwatch_state_next = CLEAR;
                end
                RUN: begin
                    stopwatch_en = 1'b1;
                    stopwatch_clear = 1'b0;
                    if (cmd_tick_S || d_btnL) stopwatch_state_next = STOP;
                end
                CLEAR: begin
                    stopwatch_en = 1'b0;
                    stopwatch_clear = 1'b1;
                    stopwatch_state_next = STOP;
                end
            endcase
        end
    end
endmodule

module cmd_box (
    input [7:0] rx_data,
    input rx_done,
    output reg cmd_tick_Q,
    output reg cmd_tick_R,
    output reg cmd_tick_S,
    output reg cmd_tick_C,
    output reg cmd_tick_M
);
    always @(*) begin
        cmd_tick_Q = 0;
        cmd_tick_R = 0;
        cmd_tick_S = 0;
        cmd_tick_C = 0;
        cmd_tick_M = 0;
        case (rx_data)
            "q": cmd_tick_Q = rx_done;
            "Q": cmd_tick_Q = rx_done;
            "R": cmd_tick_R = rx_done;
            "r": cmd_tick_R = rx_done;
            "S": cmd_tick_S = rx_done;
            "s": cmd_tick_S = rx_done;
            "C": cmd_tick_C = rx_done;
            "c": cmd_tick_C = rx_done;
            "M": cmd_tick_M = rx_done;
            "m": cmd_tick_M = rx_done;
        endcase
    end
endmodule

module mode_4x2_mux (
    input             sel,
    input      [13:0] count,
    input      [ 3:0] c_dot_data,
    input      [13:0] t,
    input      [ 3:0] s_dot_data,
    output reg [13:0] fndData,
    output reg [ 3:0] fndDot
);

    always @(*) begin
        if (!sel) begin
            fndData = count;
            fndDot  = c_dot_data;
        end else begin
            fndData = t;
            fndDot  = s_dot_data;
        end
    end
endmodule
