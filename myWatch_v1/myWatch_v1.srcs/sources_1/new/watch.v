module watch #(
    parameter COUNT_100HZ = 1_000_000,
    parameter MSEC_MAX = 100,
    parameter SEC_MAX = 60,
    parameter MIN_MAX = 60,
    parameter HOUR_MAX = 24
) (
    input clk,
    input reset,
    input btn_sec,
    input btn_min,
    input btn_hour,
    input setting_sw,
    input watch_mod_sw,
    output [$clog2(MSEC_MAX)-1:0] w_msec,
    output [$clog2(SEC_MAX)-1:0] w_sec,
    output [$clog2(MIN_MAX)-1:0] w_min,
    output [$clog2(HOUR_MAX)-1:0] w_hour
);
    wire d_sec_add;
    btn_debounce U_BTN_Debounce_Sec (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_sec),   // from btn
        .o_btn(d_sec_add)  // to control unit
    );
    wire d_min_add;
    btn_debounce U_BTN_Debounce_Min (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_min),   // from btn
        .o_btn(d_min_add)  // to control unit
    );
    wire d_hour_add;
    btn_debounce U_BTN_Debounce_Hour (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_hour),   // from btn
        .o_btn(d_hour_add)  // to control unit
    );

    wire [2:0] w_hms;
    watch_control_unit U_watch_CU (
        .clk(clk),
        .reset(reset),
        .sec_add(d_sec_add),
        .min_add(d_min_add),
        .hour_add(d_hour_add),
        .i_mod(watch_mod_sw),
        .setting_sw(setting_sw),
        .o_hms(w_hms)
    );

    watch_dp #(
        .COUNT_100HZ(COUNT_100HZ),
        .MSEC_MAX(MSEC_MAX),
        .SEC_MAX(SEC_MAX),
        .MIN_MAX(MIN_MAX),
        .HOUR_MAX(HOUR_MAX)
    ) U_watch_DP (
        .clk  (clk),
        .reset(reset),
        .hms  (w_hms),
        .msec (w_msec),
        .sec  (w_sec),
        .min  (w_min),
        .hour (w_hour)
    );
endmodule

module watch_control_unit (
    input  clk,
    input  reset,
    input  left,
    input  right,
    input  up,
    input  down,
    input  i_mod,
    input  setting_sw,
    output reg updown,
    output reg [3:0]cursor
);
    parameter STOP = 4'b0000, MIN1 = 4'b0001, MIN10 = 4'b0010,  HOUR1 = 4'b0100, HOUR10 = 4'b1000;
    // state 관리
    reg [2:0] state, next;
    reg r_updown, n_updown;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            r_updown <= 0;
        end else begin
            state <= next;
            r_updown <= n_updown;
        end
    end

    // next combinational logic
    reg [2:0] i_hms;
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
                        n_updown = r_updown;
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
                        n_updown = -1;
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
                        n_updown = -1;
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
                        n_updown = -1;
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
                        n_updown = -1;
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

    // combinational output logic
    always @(*) begin
        // 초기화 필요.
        updown = 0;
        case (state)
            STOP: begin
                updown = 0;
                cursor = 0;
            end

            MIN1: begin
                updown = r_updown;
                cursor = MIN1;
            end
            MIN10: begin
                updown = r_updown;
                cursor = MIN10;
            end
            
            HOUR1: begin
                updown = r_updown;
                cursor = HOUR1;
            end
            HOUR10: begin
                updown = r_updown;
                cursor = HOUR10;
            end

            default: begin
                updown = 0;
                cursor = 0;
            end
        endcase
    end
endmodule
