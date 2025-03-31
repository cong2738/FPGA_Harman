`timescale 1ns / 1ps

module clock_dp (
    input clk,
    input reset,
    input [1:0] mode_sel,
    input i_btn_sec,
    input i_btn_min,
    input i_btn_hour,
    input i_start,
    output [6:0] msec,
    output [6:0] sec, //1bit는 남아서 그라운드로 묶일 것임.
    output [6:0] min,
    output [6:0] hour
);

    wire w_clk_100hz, w_start;
    wire w_msec_tick, w_sec_tick, w_min_tick; // w_hour_tick은 받을 애가 없으니까 없어도 됨

    

// msec
    time_msec_counter U_Time_Msec (
        .clk(clk),
        .reset(reset),
        .tick(w_clk_100hz),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );
// sec
    time_sec_counter U_Time_Sec (
        .clk(clk),
        .reset(reset),
        .tick(w_msec_tick),
        .i_sec(i_btn_sec),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );
// min
    time_min_counter U_Time_Min (
        .clk(clk),
        .reset(reset),
        .tick(w_sec_tick),
        .i_min(i_btn_min),
        .o_time(min),
        .o_tick(w_min_tick)
    );
// hour
    time_hour_counter U_Time_Hour (
        .clk(clk),
        .reset(reset),
        .tick(w_min_tick),
        .i_hour(i_btn_hour),
        .o_time(hour),
        .o_tick() //출력이 없으니 그냥 비워놓음
    );

    clk_div_100_watch U_CLK_Div (
        .clk  (clk),
        .reset(reset),
        .run  (w_start),
        .o_clk(w_clk_100hz)
    );
    clock_cu U_Clock_Cu (
        .clk(clk), 
        .reset(reset),
        .i_btn_start(1),
        .o_start(w_start)
    );
    


endmodule

module time_msec_counter #(parameter TICK_COUNT = 100, BIT_WIDTH = 7)(
    input  clk,
    input  reset,
    input  tick,
    output [6:0] o_time,
    output o_tick
);
    //reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg [BIT_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;   // 0 -> ->0 2clk // 
        
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end


endmodule

module time_sec_counter #(parameter TICK_COUNT = 60, BIT_WIDTH = 6)(
    input  clk,
    input  reset,
    input  tick,
    input i_sec,
    input com_sec,
    output [6:0] o_time,
    output o_tick
);
    //reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg [BIT_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end


    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;   // 0 -> ->0 2clk // 
        
        if (i_sec == 1'b1) begin
            if (count_next == 59) begin
                count_next = 0;
            end else
            count_next = count_reg + 1;
        end
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end


endmodule

module time_min_counter #(parameter TICK_COUNT = 60, BIT_WIDTH = 6)(
    input  clk,
    input  reset,
    input  tick,
    input i_min,
    input com_min,
    output [6:0] o_time,
    output o_tick
);
    //reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg [BIT_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;   // 0 -> ->0 2clk // 

        if (i_min == 1'b1 || com_min == 1'b1) begin
            if (count_next == 59) begin
                count_next = 0;
            end else
            count_next = count_reg + 1;
            
        end
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end


endmodule

module time_hour_counter #(parameter TICK_COUNT = 24, BIT_WIDTH = 5)(
    input  clk,
    input  reset,
    input  tick,
    input i_hour,
    input com_hour,
    output [6:0] o_time,
    output o_tick
);
    //reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg [BIT_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;   // 0 -> ->0 2clk // 

        if (i_hour == 1'b1) begin
            if (count_next == 23) begin
                count_next = 0;
            end else
            count_next = count_reg + 1;
        end
        if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end


endmodule

module clk_div_100_watch (
    input  clk,
    input  reset,
    input  run,
    output o_clk
);

    parameter FCOUNT =  1_000_000;
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  // 출력을 f/f으로 내보내기 위해서.

    assign o_clk = clk_reg;  // 최종 출력.
    

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            clk_reg   <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg   <= clk_next;
        end
    end
    // next
    always @(*) begin
        count_next = count_reg;
        clk_next   = 1'b0; //clk_reg;
        
        if (run == 1'b1) begin
            if (count_reg == FCOUNT - 1) begin
                count_next = 0;
                clk_next   = 1'b1;  // 출력 high
            end else begin
                count_next = count_reg + 1;
                clk_next   = 1'b0;
            end
        end
    end
    

endmodule

module clock_cu (
    input clk, reset,
    input i_btn_start,
    input com_start,
    output reg o_start
);
    localparam STOP = 1'b0, RUN = 1'b1;    
    reg state, next;

    // state register
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next <= state;
        case (state)
           STOP :begin
              if (i_btn_start) begin
                next <= RUN;
              end
           end
    endcase
    end

    always @(*) begin
        o_start = 1'b0;
        case (state)
           STOP : begin
              o_start = 1'b0;
           end
           RUN : begin
              o_start = 1'b1;
           end
    endcase
    end

endmodule