`timescale 1ns / 1ps

module top_upcounter #(
    parameter BCD_BIT = 14
) (
    input clk,
    input reset,
    input [1:0] sw,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    wire w_clk;
    wire [BCD_BIT - 1:0] w_count;
    wire w_clear, w_run_stop;

    control_unit U_Control_Unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(sw[0]),
        .i_clear(sw[1]),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    localparam  BASYS3_CLK = 100_000_000,  //100Mhz
                TARGET_FREQUENCY = 100; //10HZ
    clock_devider #(
        .COUNT_TIME(BASYS3_CLK / TARGET_FREQUENCY)
    ) U_Tick (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk)
    );

    timer_10000 #(
        .BCD_BIT(BCD_BIT)
    ) U_timer (
        .clk(w_clk),
        .reset(reset),
        .stop(w_run_stop),
        .clear(w_clear),
        .count(w_count)
    );

    fnd_controlloer #(
        .BCD_BIT(BCD_BIT)
    ) U_Fnd_Cotrol (
        .clk(clk),
        .reset(reset),
        .bcd_num(w_count),
        .seg_out(seg_out),
        .seg_comm(seg_comm)
    );
endmodule

// module timer_10000 #(
//     parameter BCD_BIT = 14
// ) (
//     input clk,
//     input reset,
//     input stop_sw,
//     input clear_sw,
//     output reg [BCD_BIT - 1:0] count
// );
//     always @(posedge reset, posedge clk) begin
//         if (reset || clear_sw) begin
//             count <= 0;
//         end else begin
//             if (count == 10000) begin
//                 count <= 0;
//             end else if (stop_sw) begin
//                 count <= count;
//             end else count <= count + 1;
//         end
//     end
// endmodule

module timer_10000 #(
    parameter BCD_BIT = 14
) (
    input clk,
    input reset,
    input stop,
    input clear,
    output reg [BCD_BIT - 1:0] count
);
    localparam START = 2'b00, STOP = 2'b01, RUN = 2'b10, CLEAR = 2'b11;
    reg [2:0] state, next;

    //state managing
    always @(posedge reset, posedge clk) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end

    //next combination logic   
    always @(*) begin
        case (state)
            START:
            case (stop)
                0: next = RUN;
                1: next = STOP;
                default: next = START;
            endcase

            STOP:
            case (clear)
                1: next = CLEAR;
                default: begin
                    case (stop)
                        0: next = RUN;
                        default: next = STOP;
                    endcase
                end
            endcase

            RUN:
            case (clear)
                1: next = CLEAR;
                default: begin
                    case (stop)
                        1: next = STOP;
                        default: next = RUN;
                    endcase
                end
            endcase

            CLEAR:
            case (clear)
                0: next = START;
                default: next = CLEAR;
            endcase

            default: next = state; //default 꼭 안해주면 래치생겨서 좆됨.
        endcase
    end

    //output logic
    always @(posedge reset, posedge clk) begin
        if (reset) begin
            count <= 0;
        end else begin
            case (next)
                START: begin
                    count <= 0;
                end

                RUN: begin
                    //시계동작
                    if (count == 10000) begin
                        count <= 0;
                    end else count <= count + 1;
                end

                STOP: begin
                    //시계정지
                    count <= count;
                end

                CLEAR: begin
                    count <= 0;
                end

                default: begin
                    count <= 0;
                end
            endcase
        end
    end

endmodule

module fnd_controlloer #(
    parameter BCD_BIT = 14
) (  //control anod segments
    input clk,
    input reset,
    input [BCD_BIT - 1:0] bcd_num,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    wire [3:0] digit_1, digit_10, digit_100, digit_1000;
    wire [3:0] splited_bcd;
    wire [1:0] w_sel;
    wire w_clk;

    clock_devider #(
        .COUNT_TIME(10_000)
    ) U_clock_devider (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk)
    );

    counter_4 U_counter (
        .clk  (w_clk),
        .reset(reset),
        .sel  (w_sel)
    );
    decoder_2x4 U_sellection (
        .seg_sel (w_sel),
        .seg_comm(seg_comm)
    );

    digit_splitter #(
        .BCD_BIT(BCD_BIT)
    ) U_splitter (
        .sum(bcd_num),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(w_sel),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000),
        .bcd(splited_bcd)
    );

    bcdtoseg U_bcdToSeg (
        .bcd(splited_bcd),
        .seg_out(seg_out)
    );

endmodule

module decoder_2x4 (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);
    always @(seg_sel) begin
        case (seg_sel)
            2'b00:   seg_comm = 4'b1110;
            2'b01:   seg_comm = 4'b1101;
            2'b10:   seg_comm = 4'b1011;
            2'b11:   seg_comm = 4'b0111;
            default: ;
        endcase
    end
endmodule

module digit_splitter #(
    parameter BCD_BIT = 14
) (
    input [BCD_BIT - 1:0] sum,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = sum % 10;
    assign digit_10 = sum / 10 % 10;
    assign digit_100 = sum / 100 % 10;
    assign digit_1000 = sum / 1000 % 10;

endmodule

module clock_devider #(
    parameter COUNT_TIME = 10_000
) (
    input clk,
    input reset,
    output reg o_clk
);
    //reg[$clog2(COUNT_TIME) - 1 : 0] count = 0; // $clog2(숫자) 숫자를 표현할 수 있는 최소 비트수를 찾아옴
    integer count = 0;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            o_clk <= 0;
        end else begin
            if (count == COUNT_TIME - 1) begin
                count <= 0;
                o_clk <= 1'b1;
            end else begin
                count <= count + 1;
                o_clk <= 1'b0;
            end
        end
    end
endmodule

module counter_4 (
    input clk,
    input reset,
    output [1:0] sel
);
    reg [1:0] r_counter;
    assign sel = r_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            0: r_bcd = digit_1;
            1: r_bcd = digit_10;
            2: r_bcd = digit_100;
            3: r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end
endmodule

module bcdtoseg (
    input [3:0] bcd,
    output reg [7:0] seg_out
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg_out = 8'hC0;
            4'h1: seg_out = 8'hF9;
            4'h2: seg_out = 8'hA4;
            4'h3: seg_out = 8'hB0;
            4'h4: seg_out = 8'h99;
            4'h5: seg_out = 8'h92;
            4'h6: seg_out = 8'h82;
            4'h7: seg_out = 8'hf8;
            4'h8: seg_out = 8'h80;
            4'h9: seg_out = 8'h90;
            4'hA: seg_out = 8'h88;
            4'hB: seg_out = 8'h83;
            4'hC: seg_out = 8'hC6;
            4'hD: seg_out = 8'hA1;
            4'hE: seg_out = 8'h86;
            4'hF: seg_out = 8'h8E;
            default: seg_out = 8'hff;
        endcase
    end
endmodule



module control_unit (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    //state 관리
    reg [2:0] state, next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    //next combination logic
    always @(*) begin
        case (state)
            STOP:
            if (i_run_stop == 1) begin
                next = RUN;
            end else if (i_clear == 1) begin
                next = CLEAR;
            end else next = state;

            RUN:
            if (i_run_stop == 0) begin
                next = STOP;
            end else next = state;

            CLEAR:
            if (i_clear == 0) begin
                next = STOP;
            end else next = state;

            default: next = state;
        endcase
    end

    // combinational output logic
    always @(*) begin
        case (next)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                o_run_stop = 1'b0;
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end


endmodule
