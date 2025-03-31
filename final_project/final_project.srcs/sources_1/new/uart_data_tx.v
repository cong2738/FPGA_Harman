`timescale 1ns / 1ps
`timescale 1ns / 1ps



module uart_clock (
    input reset,
    input clk,
    input finish_tick,
    input start_trigger,
    output tx,
    input [15:0] sensor_data,
    input rx,
    input [6:0] msec,
    input [6:0] sec,
    input [6:0] min,
    input [6:0] hour,
    input [15:0] dis_data
);

    
    wire [7:0] w_o_data;
    wire [7:0] w_o_data10;
    wire [7:0] w_o_data100;
    wire [7:0] w_o_data1000;
    wire [7:0] w_o_data_2;
    wire [7:0] w_o_data10_2;
    wire [7:0] w_o_data100_2;
    wire [7:0] w_o_data1000_2;
    wire [7:0] w_data, w_data2, w_data3;
    wire [7:0] w_sec2, w_min2, w_hour2;
    wire [7:0] w_sec10, w_min10, w_hour10;


    fifo2 utx2 (
        .clk(clk),
        .reset(reset),
        .wdata(w_data),
        .wr(w_tx_start),
        .rd(~tx_done & ~w_empty2),
        .rdata(w_data2),
        .empty(w_empty2),
        .full(w_full)
    );
    tick_9600hz2 utick9600hz2 (
        .clk  (clk),
        .reset(reset),
        .tick (w_tick)
    );
    uart_tx2 u_uart_tx2 (
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .data_in(w_data3),
        .start_trigger(~w_empty2 & ~tx_done),
        .o_tx(tx),
        .tx_done(tx_done)
    );

    clock_tx_control uclock_Tx (
        .msec(msec),
        .sec(w_sec2),
        .min(w_min2),
        .hour(w_hour2),
        .sec10(w_sec10),
        .min10(w_min10),
        .hour10(w_hour10),
        .o_data(w_o_data),
        .o_data10(w_o_data10),
        .o_data100(w_o_data100),
        .o_data1000(w_o_data1000),
        .o_data_2(w_o_data_2),
        .o_data10_2(w_o_data10_2),
        .o_data100_2(w_o_data100_2),
        .o_data1000_2(w_o_data1000_2),
        .clk(clk),
        .tick(w_tick),
        .full(w_full),
        .reset(reset),
        .tx_start(w_tx_start),
        .finish_tick(finish_tick),
        .start_trigger(start_trigger),
        .data(w_data),
        .w_empty2(w_empty2)
    );
    data_save d_save2 (
        .clk(clk),
        .reset(reset),
        .rd(~tx_done & ~w_empty2),
        .data_in(w_data2),
        .data_out(w_data3)
    );
    bit_asci u_bit (
        .data(sensor_data),
        .o_data(w_o_data),
        .o_data10(w_o_data10),
        .o_data100(w_o_data100),
        .o_data1000(w_o_data1000)
    );
        bit_asci_dis u_bit5 (
        .data(dis_data),
        .o_data(w_o_data_2),
        .o_data10(w_o_data10_2),
        .o_data100(w_o_data100_2),
        .o_data1000(w_o_data1000_2)
    );
    bit_asci_clock u_bit2 (
        .data(sec),
        .o_data(w_sec2),
        .o_data10(w_sec10)
    );
    bit_asci_clock u_bit3 (
        .data(min),
        .o_data(w_min2),
        .o_data10(w_min10)
    );
    bit_asci_clock u_bit4 (
        .data(hour),
        .o_data(w_hour2),
        .o_data10(w_hour10)
    );



endmodule







module clock_tx_control (
    input [6:0] msec,
    input [7:0] sec,
    input [7:0] min,
    input [7:0] hour,
    input [7:0] sec10,
    input [7:0] min10,
    input [7:0] hour10,
    input [7:0] o_data,
    input [7:0] o_data10,
    input [7:0] o_data100,
    input [7:0] o_data1000,
    input [7:0] o_data_2,
    input [7:0] o_data10_2,
    input [7:0] o_data100_2,
    input [7:0] o_data1000_2,
    input finish_tick,
    input start_trigger,
    input w_empty2,
    input clk,
    input full,
    input tick,
    input reset,
    output tx_start,
    output [7:0] data
);
    parameter
    IDLE    = 7'b0000000, // 0
    DATA    = 7'b0000001, // 1
    DATA2   = 7'b0000010, // 2
    DATA3   = 7'b0000011, // 3
    DATA4   = 7'b0000100, // 4
    DATA5   = 7'b0000101, // 5
    DATA6   = 7'b0000110, // 6
    DATA7   = 7'b0000111, // 7
    DATA8   = 7'b0001000, // 8
    DATA9   = 7'b0001001, // 9
    DATA10  = 7'b0001010, // 10
    DATA11  = 7'b0001011, // 11
    DATA12  = 7'b0001100, // 12
    DATA13  = 7'b0001101, // 13
    DATA14  = 7'b0001110, // 14
    DATA15  = 7'b0001111, // 15
    DATA16  = 7'b0010000, // 16
    DATA17  = 7'b0010001, // 17
    DATA18  = 7'b0010010, // 18
    DATA19  = 7'b0010011, // 19
    DATA20  = 7'b0010100, // 20
    DATA21  = 7'b0010101, // 21
    DATA22  = 7'b0010110, // 22
    DATA23  = 7'b0010111, // 23
    DATA24  = 7'b0011000, // 24
    DATA25  = 7'b0011001, // 25
    DATA26  = 7'b0011010, // 26
    DATA27  = 7'b0011011, // 27
    DATA28  = 7'b0011100, // 28
    DATA29  = 7'b0011101, // 29
    DATA30  = 7'b0011110, // 30
    DATA31  = 7'b0011111, // 31
    DATA32  = 7'b0100000, // 32
    DATA33  = 7'b0100001, // 33
    DATA34  = 7'b0100010, // 34
    DATA35  = 7'b0100011, // 35
    SPACE0  = 7'b0100100, // 36
    WAIT    = 7'b0100101, // 37
    SPACE1  = 7'b0100110, // 38
    ENTER   = 7'b0100111, // 39
    FULL    = 7'b0101000; // 40
    reg start, start_next;
    reg [3:0] data_count, data_count_next;
    reg [6:0] state, next;
    reg [7:0] data_reg, data_next;
    reg [6:0] full_state, full_next;  // full로 이동하기 전 상태
    reg [15:0] tick_count, tick_count_next;

    assign tx_start = start;
    assign data = data_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            start <= 0;
            data_reg <= 0;
            data_count <= 0;
            full_state <= 0;
            tick_count <= 0;

        end else begin
            start <= start_next;
            state <= next;
            data_count <= data_count_next;
            data_reg <= data_next;
            full_state <= full_next;
            tick_count <= tick_count_next;

        end
    end
    always @(*) begin
        start_next = 0;
        next = state;
        data_next = data_reg;
        data_count_next = data_count;
        full_next = full_state;
        tick_count_next = tick_count;

        if (full) begin
            next = FULL;
        end else begin
            full_next = state;
            case (state)
                FULL: begin
                    if (full == 0) begin
                        next = full_state;
                    end
                end
                IDLE:
                if (msec == 1) begin
                    next = DATA;
                end
                DATA: begin
                    start_next = 1;
                    data_next = hour10;
                    next = DATA2;
                end
                DATA2: begin
                    start_next = 1;
                    data_next = hour;
                    next = DATA3;
                end
                DATA3: begin
                    start_next = 1;
                    data_next = ":";
                    next = DATA4;
                end
                DATA4: begin
                    start_next = 1;
                    data_next = min10;
                    next = DATA5;
                end
                DATA5: begin
                    start_next = 1;
                    data_next = min;
                    next = DATA6;
                end
                DATA6: begin
                    start_next = 1;
                    data_next = ":";
                    next = DATA7;
                end
                DATA7: begin
                    start_next = 1;
                    data_next = sec10;
                    next = DATA8;
                end
                DATA8: begin
                    start_next = 1;
                    data_next = sec;
                    next = SPACE0;
                end
                SPACE0: begin
                    start_next = 1;
                    data_next = 8'h20;
                        next =DATA9;
                end
                DATA9: begin
                    start_next = 1;
                    data_next = "t";
                    next = DATA10;
                end
                DATA10: begin
                    start_next = 1;
                    data_next = "e";
                    next = DATA11;
                end
                DATA11: begin
                    start_next = 1;
                    data_next = "m";
                    next = DATA12;
                end
                DATA12: begin
                    start_next = 1;
                    data_next = "p";
                    next = DATA13;
                end
                DATA13: begin
                       start_next = 1;
                    data_next = ":";
                    next = DATA14;
                end
                DATA14: begin
                    start_next = 1;
                    data_next = o_data1000;
                    next = DATA15;
                end
                DATA15: begin
                    start_next = 1;
                    data_next = o_data100;
                    next = DATA16;
                end
                DATA16: begin
                    start_next = 1;
                    data_next = 8'h20;
                    next = DATA17;
                end
                DATA17: begin
                    start_next = 1;
                    data_next = "h";
                    next = DATA18;
                end
                DATA18: begin
                    start_next = 1;
                    data_next = "u";
                    next = DATA19;
                end
                DATA19: begin
                    start_next = 1;
                    data_next = "m";
                    next = DATA20;
                end
                DATA20: begin
                    start_next = 1;
                    data_next = ":";
                    next = DATA21;
                end
                DATA21: begin
                    start_next = 1;
                    data_next = o_data10;
                    next = DATA22;
                end
                DATA22: begin
                    start_next = 1;
                    data_next = o_data;
                    next = DATA23;
                end 
                    DATA23: begin
                    start_next = 1;
                    data_next = 8'h20;
                    next = DATA24;
                end 
                    DATA24: begin
                    start_next = 1;
                    data_next = "d";
                    next = DATA25;
                end 
                    DATA25: begin
                    start_next = 1;
                    data_next = "i";
                    next = DATA26;
                end 
                    DATA26: begin
                    start_next = 1;
                    data_next = "s";
                    next = DATA27;
                end 
                    DATA27: begin
                    start_next = 1;
                    data_next = ":";
                    next = DATA28;
                end 
                    DATA28: begin
                    start_next = 1;
                    data_next = o_data1000_2;
                    next = DATA29;
                end 
                    DATA29: begin
                    start_next = 1;
                    data_next = o_data100_2;
                    next = DATA30;
                end 
                    DATA30: begin
                    start_next = 1;
                    data_next = o_data10_2;
                    next = DATA31;
                end 
                    DATA31: begin
                    start_next = 1;
                    data_next =o_data_2;
                    next = ENTER;
                end 

                ENTER: begin
                    start_next = 1;
                    data_next = "\n";
                    next = WAIT;
                end

                WAIT: begin
                    if (msec == 20) begin
                        next = IDLE;
                    end
                end

            endcase
        end
    end


endmodule

module bit_asci_dis (
    input [15:0] data,
    output reg [7:0] o_data,
    o_data10,
    o_data100,
    o_data1000
);
    reg [7:0] data0, data10, data100, data1000;
    always @(*) begin
        data0 = data % 10;
        data10 = data / 10 % 10 ;
        data100 = data / 100 %10 ;
        data1000 = data / 1000 % 10 ;
        case (data0)
            0: o_data = "0";
            1: o_data = "1";
            2: o_data = "2";
            3: o_data = "3";
            4: o_data = "4";
            5: o_data = "5";
            
            6: o_data = "6";
            7: o_data = "7";
            8: o_data = "8";
            9: o_data = "9";

            default: o_data = "0";
        endcase
        case (data10)
            0: o_data10 = "0";
            1: o_data10 = "1";
            2: o_data10 = "2";
            3: o_data10 = "3";
            4: o_data10 = "4";
            5: o_data10 = "5";
            6: o_data10 = "6";
            7: o_data10 = "7";
            8: o_data10 = "8";
            9: o_data10 = "9";
            default: o_data10 = "0";
        endcase
        case (data100)
            0: o_data100 = "0";
            1: o_data100 = "1";
            2: o_data100 = "2";
            3: o_data100 = "3";
            4: o_data100 = "4";
            5: o_data100 = "5";
            6: o_data100 = "6";
            7: o_data100 = "7";
            8: o_data100 = "8";
            9: o_data100 = "9";
            default: o_data100 = "0";
        endcase
        case (data1000)
            0: o_data1000 = "0";
            1: o_data1000 = "1";
            2: o_data1000 = "2";
            3: o_data1000 = "3";
            4: o_data1000 = "4";
            5: o_data1000 = "5";
            6: o_data1000 = "6";
            7: o_data1000 = "7";
            8: o_data1000 = "8";
            9: o_data1000 = "9";
            default: o_data1000 = "0";
        endcase
    end

endmodule
module bit_asci (
    input [15:0] data,
    output reg [7:0] o_data,
    o_data10,
    o_data100,
    o_data1000
);
    reg [7:0] data0, data10, data100, data1000;
    always @(*) begin
        data0 = data[15:8] % 10;
        data10 = data[15:8] / 10 % 10 ;
        data100 = data[7:0] % 10;
        data1000 = data[7:0] / 10 % 10 ;
        case (data0)
            0: o_data = "0";
            1: o_data = "1";
            2: o_data = "2";
            3: o_data = "3";
            4: o_data = "4";
            5: o_data = "5";
            
            6: o_data = "6";
            7: o_data = "7";
            8: o_data = "8";
            9: o_data = "9";

            default: o_data = "0";
        endcase
        case (data10)
            0: o_data10 = "0";
            1: o_data10 = "1";
            2: o_data10 = "2";
            3: o_data10 = "3";
            4: o_data10 = "4";
            5: o_data10 = "5";
            6: o_data10 = "6";
            7: o_data10 = "7";
            8: o_data10 = "8";
            9: o_data10 = "9";
            default: o_data10 = "0";
        endcase
        case (data100)
            0: o_data100 = "0";
            1: o_data100 = "1";
            2: o_data100 = "2";
            3: o_data100 = "3";
            4: o_data100 = "4";
            5: o_data100 = "5";
            6: o_data100 = "6";
            7: o_data100 = "7";
            8: o_data100 = "8";
            9: o_data100 = "9";
            default: o_data100 = "0";
        endcase
        case (data1000)
            0: o_data1000 = "0";
            1: o_data1000 = "1";
            2: o_data1000 = "2";
            3: o_data1000 = "3";
            4: o_data1000 = "4";
            5: o_data1000 = "5";
            6: o_data1000 = "6";
            7: o_data1000 = "7";
            8: o_data1000 = "8";
            9: o_data1000 = "9";
            default: o_data1000 = "0";
        endcase
    end

endmodule

module bit_asci_clock (
    input [15:0] data,
    output reg [7:0] o_data,
    o_data10
);
    reg [7:0] data0, data10;
    always @(*) begin
        data0  = data % 10;
        data10 = data / 10 % 10 ;
    case (data0)
            0: o_data = "0";
            1: o_data = "1";
            2: o_data = "2";
            3: o_data = "3";
            4: o_data = "4";
            5: o_data = "5";
            6: o_data = "6";
            7: o_data = "7";
            8: o_data = "8";
            9: o_data = "9";

            default: o_data = "0";
        endcase
        case (data10)
            0: o_data10 = "0";
            1: o_data10 = "1";
            2: o_data10 = "2";
            3: o_data10 = "3";
            4: o_data10 = "4";
            5: o_data10 = "5";
            6: o_data10 = "6";
            7: o_data10 = "7";
            8: o_data10 = "8";
            9: o_data10 = "9";
            default: o_data10 = "0";
        endcase

    end


endmodule

module tick_9600hz2 (
    input  clk,
    input  reset,
    output tick
);

    parameter BAUD_RATE = 9600;
    localparam BAUD_COUNT = (100_000_000 / BAUD_RATE) / 16;
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





module fifo2 (
    input clk,
    input reset,
    // write
    input [7:0] wdata,
    input wr,
    // read
    input rd,
    output [7:0] rdata,
    output empty,
    output full
);

    wire [3:0] w_waddr, w_raddr;


    register_file uregister (
        .clk(clk),
        .waddr(w_waddr),
        .wdata(wdata),
        .raddr(w_raddr),
        .wr({~full & wr}),
        .rdata(rdata)
    );


    fifo_cu ufifo_cu (
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .waddr(w_waddr),
        .raddr(w_raddr),
        .full(full),
        .empty(empty)
    );

endmodule


module register_file (
    input clk,
    input [3:0] waddr,
    input [7:0] wdata,
    input [3:0] raddr,
    input wr,
    output [7:0] rdata
);

    reg [7:0] ram[0:2**4-1];

    assign rdata = ram[raddr];  // 0 0 일떄 우선순위?

    always @(posedge clk) begin
        if (wr) begin
            ram[waddr] = wdata;
        end
    end

endmodule


module fifo_cu (
    input clk,
    input reset,
    input wr,
    input rd,
    output [3:0] waddr,
    output [3:0] raddr,
    output full,
    output empty
);

    reg full_reg, full_next, empty_reg, empty_next;
    reg [3:0] w_ptr, w_ptr_next, r_ptr, r_ptr_next;
    assign empty = empty_reg;
    assign full  = full_reg;
    assign waddr = w_ptr;
    assign raddr = r_ptr;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            w_ptr <= 0;
            r_ptr <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            full_reg <= full_next;
            empty_reg <= empty_next;
            w_ptr <= w_ptr_next;
            r_ptr <= r_ptr_next;
        end
    end

    always @(*) begin
        full_next  = full_reg;
        empty_next = empty_reg;
        w_ptr_next = w_ptr;
        r_ptr_next = r_ptr;
        case ({
            wr, rd
        })  // state 입력은 외부에서서
            2'b01: begin
                if (empty_reg == 0) begin
                    r_ptr_next = r_ptr + 1;
                    full_next  = 1'b0;
                    if (w_ptr_next == r_ptr_next) begin
                        empty_next = 1'b1;
                    end
                end
            end
            2'b10: begin
                if (full_reg == 0) begin
                    w_ptr_next = w_ptr + 1;
                    empty_next = 1'b0;
                    if (w_ptr_next == r_ptr_next) begin
                        full_next = 1'b1;
                    end
                end
            end

            2'b11: begin
                if(empty_reg == 1'b1) begin // 동시에 들어올때 empty면 read는 무시
                    w_ptr_next = w_ptr + 1;
                    empty_next = 1'b0;
                end else if (full_reg == 1'b1) begin
                    r_ptr_next = r_ptr + 1;
                    full_next  = 1'b0;
                end else begin
                    r_ptr_next = r_ptr + 1;
                    w_ptr_next = w_ptr + 1;
                end
            end

        endcase
    end

endmodule


module data_save (
    input clk,
    input reset,
    input rd,
    input [7:0] data_in,
    output [7:0] data_out
);
    reg [7:0] data_reg, data_next;
    assign data_out = data_reg;
    always @(posedge clk) begin
        if (reset) begin
            data_reg <= 0;
        end else begin
            data_reg <= data_next;
        end
    end
    always @(*) begin
        data_next = data_reg;
        if (rd) begin
            data_next = data_in;
        end


    end

endmodule


module uart_tx2 (
    input clk,
    input reset,
    input tick,
    input [7:0] data_in,
    input start_trigger,
    output o_tx,
    output tx_done
);
    parameter R_IDLE = 4'h0, START = 4'h1, DATA_STATE = 4'h2, STOP = 4'h3;

    reg [3:0] data_count, data_count_next;
    reg [3:0] state, next;
    reg [3:0] tick_count, tick_count_next;
    reg [7:0] temp_data_reg, temp_data_next;

    reg tx, tx_next;
    reg r_tx_done, r_tx_done_next;
    assign tx_done = r_tx_done;
    assign o_tx = tx;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            tx <= 1;
            r_tx_done <= 0;
            data_count <= 0;
            tick_count <= 0;
        end else begin
            state <= next;
            tx <= tx_next;
            r_tx_done <= r_tx_done_next;
            data_count <= data_count_next;
            tick_count <= tick_count_next;
        end
    end


    always @(*) begin
        next = state;
        tx_next = tx;
        r_tx_done_next = r_tx_done;
        data_count_next = data_count;
        tick_count_next = tick_count;
        case (state)
            R_IDLE: begin
                tx_next = 1'b1;
                r_tx_done_next = 0;
                tick_count_next = 0;
                if (start_trigger == 1) begin
                    next = START;
                    r_tx_done_next = 1;
                end
            end
            START: begin
                if (tick == 1) begin
                    if (tick_count == 15) begin
                        tx_next = 1'b0;
                        data_count_next = 0;
                        tick_count_next = 0;
                        next = DATA_STATE;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end

            DATA_STATE: begin
                if (tick == 1) begin
                    if (tick_count == 15) begin
                        begin
                            tx_next = data_in[data_count];
                            data_count_next = data_count + 1;
                            tick_count_next = 0;
                            if (data_count_next == 8) begin
                                next = STOP;
                            end
                        end
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
            STOP: begin
                if (tick == 1) begin
                    if (tick_count == 15) begin
                        data_count_next = 0;
                        tx_next = 1'b1;
                        tick_count_next = 0;
                        next = R_IDLE;
                    end else begin
                        tick_count_next = tick_count + 1;
                    end
                end
            end
        endcase
    end
endmodule


// module uart_fsm (
//     input reset,
//     input clk,
//     output tx,
//     inout w_empty,
//     output [7:0] w_o_data2,
//     input rx
// );
//     wire w_tick, w_btn_start;
//     wire w_tx_done, w_rx_done;
//     wire [7:0] w_o_data, w_o_data3, w_o_data4;


//     uart_tx u_uart_tx (
//         .clk(clk),
//         .reset(reset),
//         .tick(w_tick),
//         .data_in(w_o_data4),
//         .start_trigger(~w_empty2 & ~tx_done),
//         .o_tx(tx),
//         .tx_done(tx_done)
//     );

//     uart_rx urx (
//         .clk(clk),
//         .reset(reset),
//         .tick(w_tick),
//         .rx(rx),
//         .rx_done(w_rx_done),
//         .o_data(w_o_data)
//     );

//     tick_9600hz utick9600hz (
//         .clk  (clk),
//         .reset(reset),
//         .tick (w_tick)
//     );

//     fifo urxa (
//         .clk(clk),
//         .reset(reset),
//         .wdata(w_o_data),
//         .wr(w_rx_done),
//         .rd(~w_full),
//         .rdata(w_o_data2),
//         .empty(w_empty),
//         .full()
//     );
//     fifo utx (
//         .clk(clk),
//         .reset(reset),
//         .wdata(w_o_data2),
//         .wr(~w_empty),
//         .rd(~w_empty2 & ~tx_done),
//         .rdata(w_o_data3),
//         .empty(w_empty2),
//         .full(w_full)
//     );
//     data_save d_save (
//         .clk(clk),
//         .reset(reset),
//         .rd(~w_empty2),
//         .data_in(w_o_data3),
//         .data_out(w_o_data4)
//     );


// endmodule





// module uart_rx (
//     input clk,
//     input reset,
//     input tick,
//     input rx,
//     output rx_done,
//     output [7:0] o_data
// );


//     reg [7:0] data, data_next;
//     reg [4:0] tick_count, tick_count_next;
//     reg [1:0] state, next;
//     reg r_rx_done, r_rx_done_next;
//     reg [3:0] data_count, data_count_next;
//     parameter R_IDLE = 4'h0, START = 4'h1, DATA_STATE = 4'h2, STOP = 4'h3;
//     assign o_data  = data;
//     assign rx_done = r_rx_done;
//     assign o_data  = data;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             state <= 0;
//             data <= 0;
//             data_count <= 0;
//             tick_count <= 0;
//             r_rx_done <= 0;
//         end else begin
//             state <= next;
//             r_rx_done <= r_rx_done_next;
//             data_count <= data_count_next;
//             tick_count <= tick_count_next;
//             data <= data_next;

//         end
//     end


//     always @(*) begin
//         next = state;
//         r_rx_done_next = 0;
//         data_count_next = data_count;
//         tick_count_next = tick_count;
//         data_next = data;
//         case (state)
//             R_IDLE: begin
//                 if (rx == 0) begin
//                     next = START;
//                 end
//             end
//             START: begin
//                 if (tick == 1) begin
//                     tick_count_next = tick_count + 1;
//                     if (tick_count_next == 8) begin
//                         next = DATA_STATE;
//                         tick_count_next = 0;
//                     end
//                 end
//             end
//             DATA_STATE: begin
//                 if (tick == 1) begin
//                     tick_count_next = tick_count + 1;
//                     if (tick_count_next == 16) begin
//                         data_next[data_count] = rx;
//                         tick_count_next = 0;
//                         data_count_next = data_count + 1;
//                         if (data_count_next == 8) begin
//                             data_count_next = 0;
//                             tick_count_next = 0;
//                             next = STOP;
//                         end
//                     end
//                 end
//             end

//             STOP: begin
//                 if (tick == 1) begin
//                     tick_count_next = tick_count + 1;
//                     if (tick_count_next == 24) begin
//                         next = R_IDLE;
//                         tick_count_next = 0;
//                         r_rx_done_next = 1;
//                     end
//                 end
//             end


//         endcase

//     end
// endmodule
