`timescale 1ns / 1ps
module calculator (
    input [3:0] num1, num2,
    input [1:0] button,
    output [7:0] seg_out,
    output [3:0] seg_comm,
    output seg_overflow
);
    wire[3:0] sum;
    bit4adder U_adder (
        num1,
        num2,
        sum,
        seg_overflow
    );

    fnd_controlloer U_cotrol (
        .bcd_num (sum),
        .button(button),
        .seg_out (seg_out),
        .seg_comm(seg_comm)
    );
endmodule

module decoder_2x4 (
    input[1:0] seg_sel,
    output reg[3:0] seg_comm
);
    always @(seg_sel) begin
        case (seg_sel)
            2'b00:  seg_comm = 4'b1110;
            2'b01:  seg_comm = 4'b1101;
            2'b10:  seg_comm = 4'b1011;
            2'b11:  seg_comm = 4'b0111;
            default:;
        endcase
    end
endmodule

module fnd_controlloer (  //control anod segments
    input  [3:0] bcd_num,
    input[1:0] button,
    output [7:0] seg_out,
    output [3:0] seg_comm
);
    
    decoder_2x4 U_sellection(
        .seg_sel(button),
        .seg_comm(seg_comm)
    );
    bcdtoseg U_bcdToSeg (
        .bcd(bcd_num),
        .seg_out(seg_out)
    );

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
