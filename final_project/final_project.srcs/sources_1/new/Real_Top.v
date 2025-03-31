`timescale 1ns / 1ps

module Real_Top (
    input        clk,
    input        reset,
    input        sw_mode,
    input        btnL,         //btn_run_hour,
    input        btnR,         //btn_clear_start,
    input        btnU,         //btn_sec,
    input        btnD,         //btn_min,
    inout        DHT11_IO,
    input        d_HC_SR04_i,
    input        rx,
    output       tx,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output       start_tick
);
    wire [7:0] command;
    wire w_data;


    Top_module U_UART (
        .clk(clk),
        .reset(reset),
        .command(command),
        .data(w_data),
        .rx(rx),
        .tx()
    );

    wire [1:0] mode_sel;
    univ_cu u_univ_cu (
        .clk      (clk),
        .reset    (reset),
        .command  (command),
        .data     (w_data),
        .mode_sel (mode_sel),
        .com_run  (w_com_run),
        .com_clear(w_com_clear),
        .com_sec  (w_com_sec),
        .com_min  (w_com_min),
        .com_hour (w_com_hour),
        .com_start(w_com_start)
    );

    wire [6:0] w_stop_msec;
    wire [6:0] w_stop_sec;
    wire [6:0] w_stop_min;
    wire [6:0] w_stop_hour;
    wire [6:0] w_watch_msec;
    wire [6:0] w_watch_sec;
    wire [6:0] w_watch_min;
    wire [6:0] w_watch_hour;
    top_stopwatch u_top_stopwatch (
        .clk            (clk),
        .reset          (reset),
        .btn_run_hour   (btnL),
        .btn_clear_start(btnR),
        .btn_sec        (btnU),
        .btn_min        (btnD),
        .com_run        (w_com_run),
        .com_clear      (w_com_clear),
        .com_sec        (w_com_sec),
        .com_min        (w_com_min),
        .com_hour       (w_com_hour),
        .com_start      (w_com_start),
        .mode_sel       (mode_sel),
        .w_stop_msec    (w_stop_msec),
        .w_stop_sec     (w_stop_sec),
        .w_stop_min     (w_stop_min),
        .w_stop_hour    (w_stop_hour),
        .w_watch_msec   (w_watch_msec),
        .w_watch_sec    (w_watch_sec),
        .w_watch_min    (w_watch_min),
        .w_watch_hour   (w_watch_hour)
    );

    wire [7:0] rh;
    wire [7:0] t;
    DHT11_module u_DHT11_module (
        .clk          (clk),
        .reset        (reset),
        .data         (DHT11_IO),
        .start_trigger(0),
        .rh           (rh),
        .t            (t),
        .w_finish_tick(w_finish_tick)
    );

    gen_1s u_gen_1s (
        .clk  (clk),
        .reset(reset),
        .o_clk(clk_1s)
    );

    wire [15:0] HC_SR04_o;
    HC_SR04_module u_HC_SR04_module (
        .clk          (clk),
        .reset        (reset),
        .start_trigger(clk_1s),
        .data         (d_HC_SR04_i),
        .start_tick   (start_tick),
        .o_data       (HC_SR04_o),
        .done         (done)
    );


    wire [6:0] o1;
    wire [6:0] o2;
    wire [6:0] o3;
    wire [6:0] o4;
    mux_3mode u_mux_3mode (
        .mode(mode_sel),
        .a1  (w_stop_msec),
        .a2  (w_stop_sec),
        .a3  (w_stop_min),
        .a4  (w_stop_hour),
        .b1  (w_watch_msec),
        .b2  (w_watch_sec),
        .b3  (w_watch_min),
        .b4  (w_watch_hour),
        .c1  (rh),
        .c2  (t),
        .c3  (HC_SR04_o % 100),
        .c4  (HC_SR04_o / 100 %100),
        .o1  (o1),
        .o2  (o2),
        .o3  (o3),
        .o4  (o4)
    );


    uart_clock u_uart_clock (
        .reset      (reset),
        .clk        (clk),
        .tx         (tx),
        .sensor_data({rh,t}),
        .msec       (w_watch_msec),
        .sec        (w_watch_sec),
        .min        (w_watch_min),
        .hour       (w_watch_hour),
        .dis_data(HC_SR04_o)
    );


    fnd_controller U_Fnd_Ctrl (
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .msec(o1),
        .sec(o2),
        .min(o3),
        .hour(o4),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );


endmodule

module mux_3mode (
    input [1:0] mode,
    input [6:0] a1,
    input [6:0] a2,
    input [6:0] a3,
    input [6:0] a4,
    input [6:0] b1,
    input [6:0] b2,
    input [6:0] b3,
    input [6:0] b4,
    input [6:0] c1,
    input [6:0] c2,
    input [6:0] c3,
    input [6:0] c4,
    output reg [6:0] o1,
    output reg [6:0] o2,
    output reg [6:0] o3,
    output reg [6:0] o4
);
    always @(*) begin
        case (mode)
            0: begin
                o1 = a1;
                o2 = a2;
                o3 = a3;
                o4 = a4;
            end
            1: begin
                o1 = b1;
                o2 = b2;
                o3 = b3;
                o4 = b4;
            end
            2: begin
                o1 = c1;
                o2 = c2;
                o3 = c3;
                o4 = c4;
            end
        endcase
    end
endmodule


module gen_1s (
    input  clk,
    input  reset,
    output o_clk
);

    // reg [19:0] r_counter;
    parameter FCOUNT = 100_000_000;
    reg [$clog2(
FCOUNT
)-1:0] r_counter;  //$clog2 : 수의 필요한 비트수 계산
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
