`timescale 1ns / 1ps

module TOP_DHT11 (
    input         clk,
    input         rst,
    input  [39:0] data,
    input         btn_start,
    output [ 6:0] CU_LED,
    output        ERROR_LED,
    output        fpga_LED,
    inout         dht_IO,
    output [ 7:0] fnd_font,
    output [ 3:0] fnd_comm
);
    wire tick_1us;
    tick_1us U_1us (
        .clk  (clk),
        .reset(rst),
        .tick (tick_1us)
    );

    wire o_btn;
    btn_debounce u_btn_debounce (
        .clk  (clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(o_btn)
    );

    wire io_sel;
    wire fpga;
    wire dht;
    IOBUF uIO (
        .I (fpga),
        .O (dht),
        .IO(dht_IO),
        .T (~io_sel)
    );

    wire [39:0] w_data;
    DHT_CU U_DHT_CU (
        .clk(clk),
        .rst(rst),
        .tick_1us(tick_1us),
        .btn_start(o_btn),
        .io_sel(io_sel),
        .fpga(fpga),
        .dht(dht),
        .CU_LED(CU_LED),
        .data(w_data)
        // .dht_IO(dht_IO)
    );

    wire [7:0] RH_i;
    wire [7:0] RH_d;
    wire [7:0] T_i;
    wire [7:0] T_d;
    data_div u_data_div (
        .data(w_data),
        .RH_i(RH_i),
        .RH_d(RH_d),
        .T_i(T_i),
        .T_d(T_d),
        .ERROR_LED(ERROR_LED)
    );

    fnd_controlloer u_fnd_controlloer (
        .clk     (clk),
        .reset   (rst),
        .count   (RH_i),
        .seg_out (fnd_font),
        .seg_comm(fnd_comm)
    );

    ila_0 ILA0_0 (
        .clk(clk),
        .probe0(dht),
        .probe1(CU_LED[6]),
        .probe2(RH_i)
    );

endmodule

module data_div (
    input  [39:0] data,
    output [ 7:0] RH_i,
    output [ 7:0] RH_d,
    output [ 7:0] T_i,
    output [ 7:0] T_d,
    output        ERROR_LED
);
    assign RH_i = data[39:32];
    assign RH_d = data[31:24];
    assign T_i = data[27:16];
    assign T_d = data[15:8];
    assign ERROR_LED = (RH_i + RH_d + T_i + T_d == data[7:0]) ? 0 : 1;

endmodule

module DHT_CU (
    input         clk,
    input         rst,
    input         tick_1us,
    input         btn_start,
    output        io_sel,
    output        fpga,
    input         dht,
    output [ 6:0] CU_LED,
    output [39:0] data
    // inout         dht_IO
);
    localparam  IDLE  = 7'b0000000, 
                START = 7'b0000001, 
                WAIT  = 7'b0000010,
                SYNC0 = 7'b0000100, 
                SYNC1 = 7'b0001000, 
                DATA0 = 7'b0010000, 
                DATA1 = 7'b0100000,
                DEND0 = 7'b1000000;

    localparam  START_TIME = 18000, 
                WAIT_TIME = 30, 
                SYNC_TIME = 80, 
                DATA_SYNC = 50, 
                TIEM_OUT_TIME = 2000;

    reg [6:0] state, next;
    reg [$clog2(START_TIME)-1:0] us_count_reg, us_count_next;
    reg io_out_reg, io_out_next;
    reg [39:0] mem_state, mem_next;
    reg [$clog2(40)-1:0] dataCount_reg, dataCount_next;
    reg io_sel_reg, io_sel_next;

    // out 3state on/off
    // assign dht_IO = (io_oe_reg) ? io_out_reg : 1'bz;
    assign io_sel = io_sel_reg;
    assign fpga   = io_out_reg;

    assign CU_LED = state;
    assign data   = mem_state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            us_count_reg <= 0;
            io_out_reg <= 1;
            mem_state <= 0;
            dataCount_reg <= 0;
            io_sel_reg <= 0;
        end else begin
            state <= next;
            us_count_reg <= us_count_next;
            io_out_reg <= io_out_next;
            mem_state <= mem_next;
            dataCount_reg <= dataCount_next;
            io_sel_reg <= io_sel_next;
        end
    end

    always @(*) begin
        next = state;
        us_count_next = us_count_reg;
        io_out_next = io_out_reg;
        mem_next = mem_state;
        dataCount_next = dataCount_reg;
        io_sel_next = io_sel_reg;
        case (state)
            IDLE: begin
                io_sel_next = 1;
                io_out_next = 1;
                if (btn_start) begin
                    us_count_next = 0;
                    next = START;
                end
            end
            START: begin
                io_out_next = 0;
                if (tick_1us) begin
                    if (us_count_reg == START_TIME - 1) begin
                        us_count_next = 0;
                        next = WAIT;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            WAIT: begin
                io_out_next = 1;
                if (tick_1us) begin
                    if (us_count_reg == WAIT_TIME - 1) begin
                        us_count_next = 0;
                        io_out_next = 0;
                        // io oe change
                        io_sel_next = 0;
                        next = SYNC0;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end
            SYNC0: begin
                dataCount_next = 0;
                mem_next = 0;

                if (dht == 1) begin
                    next = SYNC1;
                end
            end
            SYNC1: begin
                if (dht == 0) begin
                    next = DATA0;
                end
            end
            DATA0: begin
                /*
                    센서의 가장 처음 비트는 2^39자리 비트
                    센서의 가장 마지막 비트는 2^0자리 비트
                */
                if (dht == 1) begin
                    mem_next = mem_state << 1; //첫번째자리에 넣기 위해 좌시프트
                    next = DATA1;
                end
            end
            DATA1: begin
                if (dht == 1) begin
                    if (tick_1us) begin
                        if (us_count_reg == TIEM_OUT_TIME) begin
                            us_count_next = 0;
                            next = IDLE;
                        end else begin
                            us_count_next = us_count_reg + 1;
                        end
                    end
                end else begin
                    //첫번째 자리에 1또는0을 넣는다
                    if (us_count_reg > 30) begin
                        mem_next[0] = 1;
                    end else begin
                        mem_next[0] = 0;
                    end

                    if (dataCount_reg == 40) begin
                        us_count_next = 0;
                        dataCount_next = 0;
                        next = DEND0;
                    end else begin
                        dataCount_next = dataCount_reg + 1;
                        us_count_next = 0;
                        next = DATA0;
                    end
                end
            end
            DEND0: begin
                if (tick_1us == 1) begin
                    if (us_count_reg == 50) begin
                        us_count_next = 0;
                        next = IDLE;
                    end else begin
                        us_count_next = us_count_reg + 1;
                    end
                end
            end

            default: next = IDLE;
        endcase
    end
endmodule

module tick_1us (
    input  clk,
    input  reset,
    output tick
);

    parameter BAUD_RATE = 9600;
    localparam BAUD_COUNT = 100;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;

    reg tick_reg, tick_next;
    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset == 1) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end


    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next  = 1'b1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 1'b0;
        end
    end

endmodule
