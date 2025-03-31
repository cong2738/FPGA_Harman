`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input sw_mode,
    input [6:0] msec,
    input [6:0] sec,
    input [6:0] min,
    input [6:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    // 10000진 카운터
    // 0~9999 -> 몇 비트로 처리해야 하는가? -> log2(9999)
    // $clog2())-1:0
    // assign seg_comm = 4'b1110;  // segment 0의 자리 on, seg는 anode type

    wire [3:0] w_digit_msec_1, w_digit_msec_10;
    wire [3:0] w_digit_sec_1, w_digit_sec_10;
    wire [3:0] w_digit_min_1, w_digit_min_10;
    wire [3:0] w_digit_hour_1, w_digit_hour_10;
    wire [3:0] w_bcd, w_dot, w_min_hour, w_msec_sec;
    wire [2:0] w_seg_sel;
    wire w_clk_100hz; 

    clk_divider U_Clk_Divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_8 U_counter_8 (
        .clk  (w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );
    
    decoder_3x8 U_decoder_3x8 (
        .seg_sel (w_seg_sel),
        .fnd_comm(fnd_comm)
    );

    digit_splitter #(.BIT_WIDTH(7)) U_Msec_ds (
        .bcd(msec),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );
    digit_splitter #(.BIT_WIDTH(7)) U_Sec_ds (
        .bcd(sec),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );
    digit_splitter #(.BIT_WIDTH(7)) U_Min_ds (
        .bcd(min),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10)
    );
    digit_splitter #(.BIT_WIDTH(7)) U_Hour_ds (
        .bcd(hour),
        .digit_1(w_digit_hour_1),
        .digit_10(w_digit_hour_10)
    );
    MUX_8X1 U_Mux_8x1_ms (
        .sel(w_seg_sel),
        .x0(w_digit_msec_1),
        .x1(w_digit_msec_10),
        .x2(w_digit_sec_1),
        .x3(w_digit_sec_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(w_dot),
        .x7(4'hf),
        .y(w_msec_sec)
    );
    MUX_8X1 U_Mux_8x1_mh (
        .sel(w_seg_sel),
        .x0(w_digit_min_1),
        .x1(w_digit_min_10),
        .x2(w_digit_hour_1),
        .x3(w_digit_hour_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(4'hf),
        .x7(4'hf),
        .y(w_min_hour)
    );
    comparartor_msec U_Comp_dot (
        .msec(msec),
        .dot(w_dot)
    );
    MUX_2X1 U_mux_2x1 (
        .sw_mode(sw_mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );
    
    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),
        .fnd_font(fnd_font)
    );
    
endmodule


module clk_divider (
    input  clk,
    input  reset,
    output o_clk
);

    // reg [19:0] r_counter;
    parameter FCOUNT = 200_000 ;
    reg [$clog2(FCOUNT)-1:0] r_counter;  //$clog2 : 수의 필요한 비트수 계산
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 100hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 1->0, 0->0 : 0으로 유지
            end
        end
    end

endmodule

    
module counter_8 (
    input clk,
    input reset,
    output [2:0] o_sel
);
    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule


module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] fnd_comm
);

    // 3x8 decoder
    always @(seg_sel) begin  // * : 모든 입력을 감시한다
        case (seg_sel)
            3'b000:   fnd_comm = 4'b1110;
            3'b001:   fnd_comm = 4'b1101;
            3'b010:   fnd_comm = 4'b1011;
            3'b011:   fnd_comm = 4'b0111;
            3'b100:   fnd_comm = 4'b1110;
            3'b101:   fnd_comm = 4'b1101;
            3'b110:   fnd_comm = 4'b1011;
            3'b111:   fnd_comm = 4'b0111;
            default: fnd_comm = 4'b1111;
        endcase
    end

endmodule

module digit_splitter #(parameter BIT_WIDTH = 7) (
    input  [BIT_WIDTH-1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = bcd % 10;
    assign digit_10 = bcd / 10 % 10;

endmodule

module MUX_8X1 (
    input [2:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    input [3:0] x4,
    input [3:0] x5,
    input [3:0] x6,
    input [3:0] x7,
    output reg [3:0] y
);
    
    always @(*) begin
        case (sel)
           3'b000 : y = x0;
           3'b001 : y = x1;
           3'b010 : y = x2;
           3'b011 : y = x3;
           3'b100 : y = x4;
           3'b101 : y = x5;
           3'b110 : y = x6;
           3'b111 : y = x7;
            default: y = 4'hf;
        endcase
    end
endmodule

module MUX_2X1 (
    input sw_mode,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output reg [3:0] bcd
);
    always @(*) begin
        case (sw_mode)
          1'b0 : bcd = msec_sec;
          1'b1 : bcd = min_hour;
            default: bcd = 4'hf;
        endcase
    end
endmodule

module bcdtoseg (
    input [3:0] bcd,  // [3:0] sum 값
    output reg [7:0] fnd_font  // reg type 지정 (default: wire)
);
    // always 구문은 출력으로 wire X, reg type을 가져야 한다
    always @(bcd) begin     // 항상 @(이벤트 대상) 감시. begin부터 end를 실행

        case (bcd)  // if문
            4'h0: fnd_font = 8'hC0;
            4'h1: fnd_font = 8'hF9;
            4'h2: fnd_font = 8'hA4;
            4'h3: fnd_font = 8'hB0;
            4'h4: fnd_font = 8'h99;
            4'h5: fnd_font = 8'h92;
            4'h6: fnd_font = 8'h82;
            4'h7: fnd_font = 8'hF8;
            4'h8: fnd_font = 8'h80;
            4'h9: fnd_font = 8'h90;
            4'hA: fnd_font = 8'h88;
            4'hB: fnd_font = 8'h83;
            4'hC: fnd_font = 8'hC6;
            4'hD: fnd_font = 8'hA1;
            4'hE: fnd_font = 8'h7f; //dot
            4'hF: fnd_font = 8'hff;
            default: fnd_font = 8'hff;
        endcase
    end
endmodule

module comparartor_msec (
    input [6:0] msec,
    //input [6:0] hour,
    output [3:0] dot
);
    assign dot = (msec<50 ) ? 4'he : 4'hf; // dot on, off // ( ) ? a : b -> ( ) 가 참이면 a, 거짓 b

endmodule

