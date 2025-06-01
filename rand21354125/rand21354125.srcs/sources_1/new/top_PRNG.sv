`timescale 1ns / 1ps

module top_PRNG (
    input clk,
    input rst,
    input ce_btn,
    input seed_btn,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    logic [31:0] rnd, bptCount, sys_count;
    btn_debounce u_ce_btdb (
        .clk  (clk),
        .reset(rst),
        .i_btn(ce_btn),
        .o_btn(ce_db)
    );
    clk_divider #(50_000_000) u_ceGen (
        .clk  (clk),
        .reset(rst),
        .o_clk(ce)
    );
    ButtonPushTimeCounter u_ButtonPushTimeCounter (
        .clk      (clk),
        .reset    (rst),
        .i_btn    (seed_btn),
        .bptCount (bptCount),
        .seed_tick(seed_en)
    );
    sys_counter u_sys_counter (
        .clk  (clk),
        .en   (seed_en),
        .count(sys_count)
    );
    xorshift64 u_xorshift (
        .clk    (clk),
        .rst    (rst),
        .ce     (ce | ce_db),
        .seed_en(seed_en),
        .seed   ({bptCount, sys_count}),
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
