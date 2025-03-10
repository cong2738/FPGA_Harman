`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    input [2:0] sw,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire [13:0] w_count;
    wire w_tick_100hz, w_run_stop, w_clear;

    tick_100hz U_Tick_100hz (
        .clk(clk),  //100Mhz
        .reset(reset),
        .run_stop(w_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );

    // counter_10000 U_Counter_10000 (
    //     .clk  (clk),
    //     .reset(reset),
    //     .clear(w_clear),  // clear
    //     .count(w_count)   // 14비트
    // );

    counter_tick #(
        .COUNT_MAX(10_000)
    ) U_Counter_Tick (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_100hz),
        .counter(w_count)
    );

    fnd_controller U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .bcd_num(w_count),  // 14 biit
        .seg_out(seg),
        .seg_comm(seg_comm)
    );

    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(sw[0]),  // input 
        .i_clear(sw[1]),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
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
// module tick_100hz (
//     input clk,  //100Mhz
//     input reset,
//     input run_stop,
//     output o_tick_100hz
// );

//     reg [$clog2(1_000_000)-1:0] r_counter;
//     reg r_tick_100hz;

//     assign o_tick_100hz = r_tick_100hz;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_counter <= 0;
//         end else begin
//             if (run_stop == 1'b1) begin
//                 if (r_counter == (1_000_000 - 1)) begin
//                     r_counter <= 0;
//                     r_tick_100hz <= 1'b1;
//                 end else begin
//                     r_counter <= r_counter + 1;
//                 end
//             end else r_counter <= r_counter;
//         end
//     end

// endmodule

// module counter_10000 (
//     input clk,
//     input reset,
//     input clear,
//     output [13:0] count  // 14비트
// );

//     reg [$clog2(10000)-1:0] r_counter;

//     assign count = r_counter;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_counter <= 0;
//         end else begin
//             if (r_counter == 10000 - 1) begin
//                 r_counter <= 0;
//             end else if (clear == 1'b1) begin
//                 r_counter <= 0;
//             end else begin
//                 r_counter <= r_counter + 1;
//             end
//         end
//     end
// endmodule

module counter_tick #(
    COUNT_MAX = 10_000
) (
    input clk,
    input reset,
    input tick,
    output [$clog2(COUNT_MAX) - 1:0] counter
);
    //                          state        next
    reg [$clog2(COUNT_MAX) - 1:0] counter_reg, counter_next;

    //output logic
    assign counter = counter_reg;

    //state
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next
    always @(*) begin
        counter_next = counter_reg;
        if (tick == 1'b1) begin
            if (counter_reg == 10_000 - 1) begin
                counter_next = 0;
            end else begin
                counter_next = counter_reg + 1;
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
                if (i_run_stop == 1'b0) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end
            CLEAR: begin
                if (i_clear == 1'b0) begin
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
                o_run_stop = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
