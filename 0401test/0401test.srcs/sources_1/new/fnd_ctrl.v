`timescale 1ns / 1ps

module fnd_ctrl #(
    parameter BCD_MAX = 9999
) (
    input clk,
    input reset,
    input [$clog2(BCD_MAX)-1:0] bcd,
    output [7:0] seg,
    output [3:0] an
);
    assign dot = 0;

    clk_div #(
        .COUNT_MAX(10_000)
    ) Tick_Gen (
        .clk  (clk),
        .reset(reset),
        .tick (tick_10us)
    );

    wire [1:0] seg_sel;
    count4 u_count4 (
        .clk    (tick_10us),
        .reset  (reset),
        .seg_sel(seg_sel)
    );

    an_ctrl u_an_MUX (
        .seg_sel(seg_sel),
        .an     (an)
    );

    wire [3:0] num;
    num_MUX u_num_MUX (
        .bcd    (bcd),
        .seg_sel(seg_sel),
        .num    (num)
    );

    display_ctrl u_display_MUX (
        .num(num),
        .seg(seg)
    );

endmodule

module num_MUX (
    input [$clog2(9999)-1:0] bcd,
    input [1:0] seg_sel,
    output reg [3:0] num
);
    always @(*) begin
        case (seg_sel)
            0: num = bcd % 10;
            1: num = bcd / 10 % 10;
            2: num = bcd / 100 % 10;
            3: num = bcd / 1000 % 10;
        endcase
    end
endmodule

module count4 #(
    parameter COUNT_MAX = 4
) (
    input clk,
    input reset,
    output [1:0] seg_sel
);
    reg [$clog2(COUNT_MAX)-1:0] count_curr, count_next;

    assign seg_sel = count_curr;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_curr <= 0;
        end else begin
            count_curr <= count_next;
        end
    end

    always @(*) begin
        count_next = count_curr;
        if (count_curr == COUNT_MAX - 1) begin
            count_next = 0;
        end else begin
            count_next = count_next + 1;
        end
    end
endmodule

module an_ctrl (
    input [1:0] seg_sel,
    output reg [3:0] an
);
    always @(*) begin
        case (seg_sel)
            0: an = 4'b1110;
            1: an = 4'b1101;
            2: an = 4'b1011;
            3: an = 4'b0111;
        endcase
    end

endmodule

module display_ctrl (
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
