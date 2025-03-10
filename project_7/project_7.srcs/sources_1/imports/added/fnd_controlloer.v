`timescale 1ns / 1ps

module calculator (
    input clk,
    input reset,
    input [7:0] num1,
    input [7:0] num2,
    output [8:0] o_sum,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    wire carry;
    wire [7:0] sum;
    wire [1:0] sel;
    assign o_sum = {carry,sum};

    //조합논리회로
    bit8adder U_adder (
        num1,
        num2,
        sum,
        carry
    );

    //순차논리회로(clk가 동작 값이 결정.)
    fnd_controlloer U_cotrol (
        .clk(clk),
        .reset(reset),
        .bcd_num({carry, sum}),
        .seg_out(seg_out),
        .seg_comm(seg_comm)
    );
endmodule

module fnd_controlloer (  //control anod segments
    input clk,
    input reset,
    input [8:0] bcd_num,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    wire [3:0] digit_1, digit_10, digit_100, digit_1000;
    wire [3:0] splited_bcd;
    wire [1:0] w_sel;
    wire w_clk;

    clock_devider U_clock_devider (
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

    digit_splitter U_splitter (
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

module digit_splitter (
    input  [8:0] sum,
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

module clock_devider (
    input clk,
    input reset,
    output reg o_clk
);  
    parameter DELAY_TIME = 100_000;

    //reg[$clog2(DELAY_TIME) - 1 : 0] count = 0; // $clog2(숫자) 숫자를 표현할 수 있는 최소 비트수를 찾아옴
    integer  count = 0;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            o_clk <= 0  ;
        end else begin
            if (count == DELAY_TIME - 1) begin
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
