module watch #(
    parameter COUNT_100HZ = 1_000_000,
    parameter MSEC_MAX = 100,
    parameter SEC_MAX = 60,
    parameter MIN_MAX = 60,
    parameter HOUR_MAX = 24
) (
    input clk,
    input reset,
    input btn_l,
    input btn_r,
    input btn_u,
    input btn_d,
    input setting_sw,
    input watch_mod_sw,
    output [$clog2(MSEC_MAX)-1:0] w_msec,
    output [$clog2(SEC_MAX)-1:0] w_sec,
    output [$clog2(MIN_MAX)-1:0] w_min,
    output [$clog2(HOUR_MAX)-1:0] w_hour
);
    wire d_btn_l;
    btn_debounce U_BTN_Debounce_btn_l (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_l),   // from btn
        .o_btn(d_btn_l)  // to control unit
    );
    wire d_btn_r;
    btn_debounce U_BTN_Debounce_btn_r (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_r),   // from btn
        .o_btn(d_btn_r)  // to control unit
    );
    wire d_btn_u;
    btn_debounce U_BTN_Debounce_btn_u (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_u),   // from btn
        .o_btn(d_btn_u)  // to control unit
    );
    wire d_btn_d;
    btn_debounce U_BTN_Debounce_btn_d (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_d),   // from btn
        .o_btn(d_btn_d)  // to control unit
    );

    wire [1:0] updown;
    wire [3:0] cursor;
    watch_control_unit U_watch_CU (
        .clk(clk),
        .reset(reset),
        .left(d_btn_l),
        .right(d_btn_r),
        .up(d_btn_u),
        .down(d_btn_d),
        .i_mod(watch_mod_sw),
        .setting_sw(setting_sw),
        .updown(updown),
        .cursor(cursor)
    );

    watch_dp #(
        .COUNT_100HZ(COUNT_100HZ),
        .MSEC_MAX(MSEC_MAX),
        .SEC_MAX(SEC_MAX),
        .MIN_MAX(MIN_MAX),
        .HOUR_MAX(HOUR_MAX)
    ) U_watch_DP (
        .clk(clk),
        .reset(reset),
        .updown(updown),
        .cursor(cursor),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );
endmodule

module watch_control_unit (
    input clk,
    input reset,
    input left,
    input right,
    input up,
    input down,
    input i_mod,
    input setting_sw,
    output [1:0] updown,
    output [3:0] cursor
);
    parameter STOP = 4'b0000, MIN1 = 4'b0001, MIN10 = 4'b0010,  HOUR1 = 4'b0100, HOUR10 = 4'b1000;
    // state 관리
    reg [1:0] r_updown, n_updown;
    reg [3:0] state, next;

    assign updown = r_updown;
    assign cursor = state;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_updown <= 0;
            state <= STOP;
        end else begin
            r_updown <= n_updown;
            state <= next;
        end
    end

    // next combinational logic
    always @(*) begin
        next = state;
        n_updown = r_updown;
        if (i_mod && setting_sw) begin
            case (state)
                STOP: begin
                    if (setting_sw) begin
                        next = MIN1;
                        n_updown = 0;
                    end else begin
                        next = state;
                        n_updown = 0;
                    end
                end

                MIN1: begin
                    if (left) begin
                        next = MIN10;
                    end else if (right) begin
                        next = HOUR10;
                    end else if (up) begin
                        n_updown = 1;
                    end else if (down) begin
                        n_updown = 2;
                    end else begin
                        next = state;
                        n_updown = r_updown;
                    end
                end

                MIN10: begin
                    if (left) begin
                        next = HOUR1;
                    end else if (right) begin
                        next = MIN1;
                    end else if (up) begin
                        n_updown = 1;
                    end else if (down) begin
                        n_updown = 2;
                    end else begin
                        next = state;
                        n_updown = r_updown;
                    end
                end

                HOUR1: begin
                    if (left) begin
                        next = HOUR10;
                    end else if (right) begin
                        next = MIN1;
                    end else if (up) begin
                        n_updown = 1;
                    end else if (down) begin
                        n_updown = 2;
                    end else begin
                        next = state;
                        n_updown = r_updown;
                    end
                end

                HOUR10: begin
                    if (left) begin
                        next = MIN1;
                    end else if (right) begin
                        next = HOUR1;
                    end else if (up) begin
                        n_updown = 1;
                    end else if (down) begin
                        n_updown = 2;
                    end else begin
                        next = state;
                        n_updown = r_updown;
                    end
                end

                default: begin
                    next = state;
                    n_updown = r_updown;
                end
            endcase
        end else begin
            next = state;
            n_updown = r_updown;
        end
    end
endmodule
