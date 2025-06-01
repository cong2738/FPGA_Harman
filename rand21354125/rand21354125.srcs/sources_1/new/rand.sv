module random_test_top (
    input clk,
    input rst,
    input ce_btn,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    clk_divider #(100_000_000) u_ceGen (
        .clk  (clk),
        .reset(rst),
        .o_clk(ce)
    );

    btn_debounce u_btn_debounce (
        .clk  (clk),
        .reset(rst),
        .i_btn(ce_btn),
        .btn_debounce(seed_en)
    );

    logic [31:0] rnd;
    xorshift128 u_xorshift128 (
        .clk    (clk),
        .rst    (rst),
        .ce     (ce),
        .seed_en(seed_en),
        .seed   (~128'h0),
        .rnd    (rnd)
    );

    fnd_controller u_fnd_controller (
        .clk     (clk),
        .reset   (rst),
        .bcd32   (rnd),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

endmodule

module pseudo_random (
    input clk,
    ce,
    rst,
    output reg [31:0] q
);
    wire feedback = q[31]^q[29]^q[28]^ q[27]^ q[23]^q[20]^ q[19]^q[17]^ q[15]^q[14]^q[12]^ q[11]^q[9]^ q[4]^ q[3]^q[2];

    always @(posedge clk or posedge rst) begin
        if (rst) q <= 32'haaaaaaaa;
        else if (ce) q <= {q[30:0], feedback};
    end
endmodule

module xorshift128 (
    input              clk,
    input              rst,
    input              ce,
    input              seed_en,
    input      [127:0] seed,     // 128비트 시드 입력 (x, y, z, w 순서)
    output reg [ 31:0] rnd       // 난수 출력
);

    reg [31:0] x, y, z, w;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 기본 시드
            x <= 32'h12345678;
            y <= 32'h87654321;
            z <= 32'hABCDEF01;
            w <= 32'h10FEDCBA;
        end else if (seed_en) begin
            // 외부 시드 설정
            x <= seed[127:96];
            y <= seed[95:64];
            z <= seed[63:32];
            w <= seed[31:0];
        end else if (ce) begin
            // XORSHIFT128 알고리즘
            reg [31:0] t;
            t = x ^ (x << 11);
            x   <= y;
            y   <= z;
            z   <= w;
            w   <= w ^ (w >> 19) ^ (t ^ (t >> 8));
            rnd <= w;
        end
    end

endmodule

module xorshift64 (
    input              clk,
    input              rst,
    input              ce,
    input              seed_en,
    input      [63:0]  seed,     // 64비트 시드 입력
    output reg [31:0]  rnd       // 난수 출력
);

    reg [31:0] x, y, z, w;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 기본 시드
            x <= 32'h12345678;
            y <= 32'h87654321;
            z <= 32'hABCDEF01;
            w <= 32'h10FEDCBA;
        end else if (seed_en) begin
            // 64비트 시드를 4개 상태로 분해
            x <= seed[63:48] ^ seed[31:16]; // 간단한 spread 방식
            y <= seed[47:32] ^ seed[15:0];
            z <= seed[31:16] ^ seed[63:48];
            w <= seed[15:0]  ^ seed[47:32];
        end else if (ce) begin
            // XORSHIFT128 알고리즘
            reg [31:0] t;
            t = x ^ (x << 11);
            x   <= y;
            y   <= z;
            z   <= w;
            w   <= w ^ (w >> 19) ^ (t ^ (t >> 8));
            rnd <= w;
        end
    end

endmodule
