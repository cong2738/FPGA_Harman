`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    // input [2:0] sw,
    input btn_run_stop,
    input btn_clear,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire w_debounce_runstop, w_debounce_clear;
    wire w_tick_100hz, w_run_stop, w_clear;

    btn_debounce U_Debounce_RunStopBtn (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_run_stop),
        .o_btn(w_debounce_runstop)  // to control unit
    );

    btn_debounce U_Debounce_ClearBtn (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(w_debounce_clear)  // to control unit
    );

    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_debounce_runstop),  // input 
        .i_clear(w_debounce_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    tick_100hz U_Tick_100hz (
        .clk(clk),  //100Mhz
        .reset(reset),
        .run_stop(w_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );

    wire [13:0] w_msec, w_tick_msec;
    count_tick #(
        .COUNT(10_000) // 100_000_000/10_000 = 100_000
    ) U_Counter_Tick100 (
        .clk(w_tick_100hz),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_msec),
        .o_tick(w_tick_msec)
    );

    wire [13:0] w_sec, w_tic_sec;
    count_tick #(
        .COUNT(100)
    ) U_Counter_Tick60sec (
        .clk(w_tick_msec),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_sec),
        .o_tick(w_tic_sec)
    );

    fnd_controller U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .bcd(w_sec),
        .seg(seg),
        .seg_comm(seg_comm)
    );

endmodule

// 100hz tick generator
module tick_100hz (
    input clk,  //100mhz
    input reset,
    input run_stop,
    output o_tick_100hz
);
    parameter STOP = 1'b0, RUN = 1'b1;
    parameter FCOUNT = 1000_000;
    reg state, next;
    reg r_clk;
    reg u_clk;
    assign o_tick_100hz = r_clk;
    reg [$clog2(FCOUNT)-1:0] r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state = STOP;
        end else begin
            state = next;
        end
    end
    always @(*) begin
        next = state;
        case (state)
            RUN:
            if (run_stop == 1'b0) begin
                next = STOP;
            end else begin
                next = state;
            end
            STOP:
            if (run_stop == 1'b1) begin
                next = RUN;
            end else begin
                next = state;
            end
            default: next = state;
        endcase
    end
    always @(*) begin
        case (state)
            RUN: r_clk = u_clk;

            STOP: r_clk = 0;
            default: r_clk = 0;
        endcase
    end

    always @(posedge clk, posedge reset) begin
        if (reset == 1'b1) begin
            r_counter <= 0;
            u_clk <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                u_clk <= 1;
            end else begin
                u_clk <= 1'b0;
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule

module count_tick #(
    COUNT = 10_000
) (
    input clk,
    input reset,
    input clear,
    input tick,
    output [$clog2(COUNT) - 1:0] counter,
    output o_tick
);
    
    //                          state        next
    reg [$clog2(COUNT) - 1:0] counter_reg, counter_next;

    //state
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next
    reg r_tick;
    always @(*) begin
        counter_next = counter_reg;
        if (clear == 1) begin
            counter_next = 0;
        end else if (tick == 1'b1) begin
            if (counter_reg == COUNT - 1) begin
                r_tick = 1;
                counter_next = 0;
            end else begin
                r_tick = 0;
                counter_next = counter_reg + 1;
            end
        end
    end

    //output logic
    assign counter = counter_reg;
    assign o_tick = r_tick;
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
                end else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end else begin
                    next = state;
                end
            end

            CLEAR: begin
                if (i_clear == 1'b0) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end

            default: begin
                next = state;
            end

        endcase
    end

    // combinational output logic
    always @(*) begin
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
                o_clear    = 1'b1;
                o_run_stop = 1'b0;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
