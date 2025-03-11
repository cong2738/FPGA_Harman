`timescale 1ns / 1ps

module fnd_controller #(
    parameter BCD_MAX = 100
) (
    input clk,
    input reset,
    input sw_mod,
    input [$clog2(BCD_MAX)-1:0] msec,
    input [$clog2(BCD_MAX)-1:0] sec,
    input [$clog2(BCD_MAX)-1:0] min,
    input [$clog2(BCD_MAX)-1:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);

    wire w_tick;
    clk_divider #(
        .FCOUNT(10_000) //100_000_000/10_000 = 10_000hz
    )U_Clk_Divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_tick)
    );

    wire [2:0] w_seg_sel;
    counter_8 U_Counter_8 (
        .clk  (w_tick),
        .reset(reset),
        .o_sel(w_seg_sel)
    );

    decoder_3x8 U_decoder_3x8 (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );

    wire [$clog2(BCD_MAX)-1:0] w_msec_1, w_msec_10;
    digit_splitter U_Digit_Splitter_Msec (
        .bcd(msec),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10)
    );

    wire [$clog2(BCD_MAX)-1:0] w_sec_1, w_sec_10;
    digit_splitter U_Digit_Splitter_Sec (
        .bcd(sec),
        .digit_1(w_sec_1),
        .digit_10(w_sec_10)
    );

    wire [$clog2(BCD_MAX)-1:0] w_min_1, w_min_10;
    digit_splitter U_Digit_Splitter_Min (
        .bcd(min),
        .digit_1(w_min_1),
        .digit_10(w_min_10)
    );

    wire [$clog2(BCD_MAX)-1:0] w_hour_1, w_hour_10;
    digit_splitter U_Digit_Splitter_Hour (
        .bcd(hour),
        .digit_1(w_hour_1),
        .digit_10(w_hour_10)
    );

    wire [3:0] w_bcd_in1;
    mux_8x1 umux0 (
        .sel(w_seg_sel),
        .digit_1_ms(w_msec_1),
        .digit_10_ms(w_msec_10),
        .digit_1_s(w_sec_1),
        .digit_10_s(w_sec_10),
        .digit_1_m(4'hf),
        .digit_10_m(4'hf),
        .digit_1_h(4'hf),
        .digit_10_h(4'hf),
        .bcd(w_bcd_in1)
    );

    wire [3:0] w_bcd_in2;
    mux_8x1 umux1 (
        .sel(w_seg_sel),
        .digit_1_ms(4'hf),
        .digit_10_ms(4'hf),
        .digit_1_s(4'hf),
        .digit_10_s(4'hf),
        .digit_1_m(w_min_1),
        .digit_10_m(w_min_10),
        .digit_1_h(w_hour_1),
        .digit_10_h(w_hour_10),
        .bcd(w_bcd_in2)
    );


    wire [3:0] w_bcd;
    mux_2x1 U_MUX2x1 (
        .sw_mod(sw_mod),
        .bcd_in1(w_bcd_in1),
        .bcd_in2(w_bcd_in2),
        .bcd(w_bcd)
    );
    // mux_4x1 U_Mux_4x1 (
    //     .sel(w_seg_sel),
    //     .digit_1(w_msec_1),
    //     .digit_10(w_msec_10),
    //     .digit_100(w_sec_1),
    //     .digit_1000(w_sec_10),
    //     .bcd(w_bcd)
    // );

    wire [7:0] w_seg;
    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),  // [3:0] sum 값 
        .seg(w_seg)
    );

    wire w_dot;
    light_dot U_Light_Dot (
        .clk  (w_tick), //10Khz
        .reset(reset),
        .dot  (w_dot)
    );

    mux_dot U_Mux_dot (
        .dot(w_dot),
        .seg_sel(w_seg_sel),
        .seg_font(w_seg),
        .fnd_font(fnd_font)
    );
endmodule

module mux_2x1 (
    input sw_mod,
    input [3:0] bcd_in1,
    input [3:0] bcd_in2,
    output reg [3:0] bcd
);
    always @(*) begin
        case (sw_mod)
            1'b0: bcd = bcd_in1;
            1'b1: bcd = bcd_in2;
            default: bcd = bcd_in1;
        endcase

    end

endmodule


module mux_8x1 (
    input [2:0] sel,
    input [3:0] digit_1_ms,
    input [3:0] digit_10_ms,
    input [3:0] digit_1_s,
    input [3:0] digit_10_s,
    input [3:0] digit_1_m,
    input [3:0] digit_10_m,
    input [3:0] digit_1_h,
    input [3:0] digit_10_h,
    output reg [3:0] bcd
);


    always @(*) begin
        case (sel)
            3'b000:  bcd = digit_1_ms;
            3'b001:  bcd = digit_10_ms;
            3'b010:  bcd = digit_1_s;
            3'b011:  bcd = digit_10_s;
            3'b100:  bcd = digit_1_m;
            3'b101:  bcd = digit_10_m;
            3'b110:  bcd = digit_1_h;
            3'b111:  bcd = digit_10_h;
            default: bcd = 4'hf;
        endcase
    end
endmodule


module clk_divider #(
    parameter FCOUNT = 100_000  // 이름을 상수화하여 사용.
)(
    input  clk,
    input  reset,
    output o_clk
);
    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin  // 
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 200hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지.;
            end
        end
    end

endmodule

module counter_8 (
    input        clk,
    input        reset,
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
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(seg_sel) begin
        case (seg_sel)
            3'b000:  seg_comm = 4'b1110;
            3'b001:  seg_comm = 4'b1101;
            3'b010:  seg_comm = 4'b1011;
            3'b011:  seg_comm = 4'b0111;
            3'b100:  seg_comm = 4'b1110;
            3'b101:  seg_comm = 4'b1101;
            3'b110:  seg_comm = 4'b1011;
            3'b111:  seg_comm = 4'b0111;
            default: seg_comm = 4'b1111;
        endcase
    end

endmodule

module digit_splitter (
    input  [13:0] bcd,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10
);
    assign digit_1  = bcd % 10;  // 10의 1의 자리
    assign digit_10 = bcd / 10 % 10;  // 10의 10의 자리
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
    // * : input 모두 감시, 아니면 개별 입력 선택 할 수 있다.
    // alwasys : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행해라.
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end

endmodule

module bcdtoseg (
    input [3:0] bcd,  // [3:0] sum 값 
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            // 4'hA: seg = 8'h88;
            // 4'hB: seg = 8'h83;
            // 4'hC: seg = 8'hc6;
            // 4'hD: seg = 8'ha1;
            // 4'hE: seg = 8'h86;
            // 4'hF: seg = 8'h8E;
            default: seg = 8'hff;
        endcase
    end
endmodule

module mux_dot (
    input dot,
    input [2:0] seg_sel,
    input [7:0] seg_font,
    output reg [7:0] fnd_font
);
    reg [7:0] dot_led;
    always @(*) begin
        dot_led = {dot, 7'b0000000};
        case (seg_sel)
            3'b010:
            fnd_font = seg_font - dot_led;  //seg[7]을 켠다. 8'b0000000
            3'b110: fnd_font = seg_font - dot_led;
            default: fnd_font = seg_font;
        endcase
    end
endmodule

module light_dot #(
    parameter COUNT_MAX = 10_000    // 10_000/20_000 => period = 1sec
) (
    input clk,
    input reset,
    output dot
);
    reg w_dot;
    reg [$clog2(COUNT_MAX)-1:0] count;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            w_dot <= 0;
        end else begin
            if (count == COUNT_MAX - 1) begin
                count <= 0;
                w_dot   <= 1;
            end else if (count == ((COUNT_MAX / 2) - 1)) begin
                w_dot <= 0;
                count <= count + 1;
            end else begin
                count <= count + 1;
            end
        end
    end

    assign dot = w_dot;
endmodule
