`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [$clog2(9999)-1:0] num,
    output [7:0] seg,
    output [3:0] an
);
    clk_div #(10_000) u_clk_div (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    wire [1:0] sel;
    count_4 u_count_4 (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .count(sel)
    );

    decoder_2x4 u_decoder_2x4 (
        .sel(sel),
        .an (an)
    );

    wire [3:0] num1;
    wire [3:0] num10;
    wire [3:0] num100;
    wire [3:0] num1000;
    digitSplitter u_digitSplitter (
        .num    (num),
        .num1   (num1),
        .num10  (num10),
        .num100 (num100),
        .num1000(num1000)
    );

    wire [3:0] selNum;
    mux_4x1 u_mux_4x1 (
        .sel    (sel),
        .num1   (num1),
        .num10  (num10),
        .num100 (num100),
        .num1000(num1000),
        .selNum (selNum)
    );
    
    digit_to_seg u_digit_to_seg (
        .num(selNum),
        .seg(seg)
    );


endmodule

module count_4 (
    input        clk,
    input        reset,
    input        tick,
    output [1:0] count
);
    reg [1:0] r_count;
    assign count = r_count;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end else begin
            if (tick) r_count <= r_count + 1;
        end
    end
endmodule

module decoder_2x4 (
    input [1:0] sel,
    output reg [3:0] an
);
    always @(*) begin
        an = 4'b1111;
        case (sel)
            0: an = 4'b1110;
            1: an = 4'b1101;
            2: an = 4'b1011;
            3: an = 4'b0111;
        endcase
    end
endmodule

module digitSplitter (
    input  [13:0] num,
    output [ 3:0] num1,
    output [ 3:0] num10,
    output [ 3:0] num100,
    output [ 3:0] num1000
);
    assign num1 = num % 10;
    assign num10 = num / 10 % 10;
    assign num100 = num / 100 % 10;
    assign num1000 = num / 1000 % 10;
endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] num1,
    input [3:0] num10,
    input [3:0] num100,
    input [3:0] num1000,
    output reg [3:0] selNum
);
    always @(*) begin
        case (sel)
            0: selNum = num1;
            1: selNum = num10;
            2: selNum = num100;
            3: selNum = num1000;
        endcase
    end
endmodule

module digit_to_seg (
    input [3:0] num,
    output reg [7:0] seg
);
    always @(*) begin
        case (num)
            0: seg = 8'hc0;
            1: seg = 8'hF9;
            2: seg = 8'hA4;
            3: seg = 8'hB0;
            4: seg = 8'h99;
            5: seg = 8'h92;
            6: seg = 8'h82;
            7: seg = 8'hf8;
            8: seg = 8'h80;
            9: seg = 8'h90;
            default: seg = 8'hff;
        endcase
    end
endmodule
