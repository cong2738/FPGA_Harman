`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    //    input [2:0] sw,
    input btn_run_stop,
    input btn_clear,
    output [3:0] seg_comm,
    output [7:0] seg
);
    wire w_clk_10, w_run_stop, w_clear;
    wire o_btn_run_stop, o_btn_clear;
    wire w_tick_100hz;

    // 100Hz tick generator
    tick_100hz U_Tick_100hz (
        .clk(clk),  // 100Mhz
        .reset(reset),
        .run_stop(w_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );
    
    wire [13:0] w_msec;
    couter_tick U_Count_Msec (  // msec
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_msec),
        .o_tick()
    );

    wire [13:0] w_sec;
    couter_tick #(
        .TICK_COUNT(6000)
    ) U_Count_sec (  // msec
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_sec),
        .o_tick()
    );

    fnd_controller U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .msec(w_msec),  // 14 biit
        .sec(w_sec),  // 14 biit
        .seg(seg),
        .seg_comm(seg_comm)
    );


    btn_debounce U_BTN_Debounce_RUN_STOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_stop),   // from btn
        .o_btn(o_btn_run_stop)  // to control unit
    );
    btn_debounce U_BTN_Debounce_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear),   // from btn
        .o_btn(o_btn_clear)  // to control unit
    );
    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),  // input 
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
endmodule

// 100Hz tick generator
module tick_100hz (
    input clk,  // 100Mhz
    input reset,
    input run_stop,
    output o_tick_100hz
);

    reg [$clog2(1_000_000)-1:0] r_counter;
    reg r_tick_100hz;

    assign o_tick_100hz = r_tick_100hz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_tick_100hz <= 0;
        end else begin
            if (run_stop == 1'b1) begin
                if (r_counter == (1_000_000 - 1)) begin
                    r_counter <= 0;
                    r_tick_100hz <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick_100hz <= 1'b0;
                end
            end
        end
    end

endmodule

module couter_tick #(
    parameter TICK_COUNT = 10_000
) (  // 100Hz
    input clk,
    input reset,
    input tick,
    input clear,
    output [$clog2(TICK_COUNT)-1 : 0] counter,
    output o_tick
);

    //    state         next
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg r_tick;
    assign counter = counter_reg;
    assign o_tick  = r_tick;

    // state
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    // next
    always @(*) begin
        counter_next = counter_reg;
        r_tick = 1'b0;
        if (clear == 1'b1) begin
            counter_next = 0;
        end else if (tick == 1'b1) begin  // tick count
            if (counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                r_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                r_tick = 1'b0;
            end
        end
    end

endmodule

module control_unit (
    input clk,
    input reset,
    input i_run_stop,  // input 
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;
    // state 관리
    reg [2:0] state, next;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end


    // next combinational logic
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else begin
                    next = state;
                end
            end
            RUN: begin
                if (i_run_stop == 1'b1) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end
            CLEAR: begin
                if (i_clear == 1'b1) begin
                    next = STOP;
                end
            end
            default: begin
                next = state;
            end
        endcase
    end

    // combinational output logic
    always @(*) begin
        // 초기화 필요.
        o_run_stop = 1'b0;
        o_clear = 1'b0;
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
