`timescale 1ns / 1ps
/*M41T93-SPI_Slave*/

module SPI_Slave (
    input  clk,
    input  reset,
    input  SCLK,
    input  SS,
    input  MOSI,
    output MISO
);
    wire [7:0] si_data;
    wire si_done;
    wire [7:0] so_data;
    wire so_start;
    wire so_done;

    SPI_Slave_Interface u_SPI_Slave_Interface (
        .clk     (clk),
        .reset   (reset),
        .SCLK    (SCLK),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .SS      (SS),
        .si_data (si_data),
        .si_done (si_done),
        .so_data (so_data),
        .so_start(so_start),
        .so_done (so_done)
    );

    SPI_Slave_Reg u_SPI_Slave_Reg (
        .clk     (clk),
        .reset   (reset),
        .ss_n    (SS),
        .si_data (si_data),
        .si_done (si_done),
        .so_data (so_data),
        .so_start(so_start),
        .so_done (so_done)
    );

endmodule

module SPI_Slave_Interface (
    // global signals
    input        clk,
    input        reset,
    // external signals
    input        SCLK,
    input        MOSI,
    output       MISO,
    input        SS,
    // internal signals
    output [7:0] si_data,
    output       si_done,
    input  [7:0] so_data,
    input        so_start,
    output       so_done
);
    // edge detector
    reg sclk_sync0, sclk_sync1;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sclk_sync0 <= 0;
            sclk_sync1 <= 0;
        end else begin
            sclk_sync0 <= SCLK;
            sclk_sync1 <= sclk_sync0;
        end
    end

    wire sclk_rising, sclk_falling;
    assign sclk_rising  = sclk_sync0 & ~sclk_sync1;
    assign sclk_falling = ~sclk_sync0 & sclk_sync1;
    ///////////////////////////////////////////////

    // Slave Input Circuit(MO_SI)
    localparam si_IDLE = 0, si_PHASE = 1;

    reg si_state, si_next;
    reg [7:0] si_data_reg, si_data_next;
    reg [2:0] si_bit_cnt, si_bit_cnt_next;
    reg si_done_reg, si_done_next;

    assign si_data = si_data_reg;
    assign si_done = si_done_reg;

    always @(posedge clk, posedge reset) begin  // si state logic
        if (reset) begin
            si_state    <= si_IDLE;
            si_data_reg <= 0;
            si_bit_cnt  <= 0;
            si_done_reg <= 1'b0;
        end else begin
            si_state    <= si_next;
            si_data_reg <= si_data_next;
            si_bit_cnt  <= si_bit_cnt_next;
            si_done_reg <= si_done_next;
        end
    end

    always @(*) begin  // si next logic
        si_next         = si_state;
        si_data_next    = si_data_reg;
        si_bit_cnt_next = si_bit_cnt;
        si_done_next    = si_done_reg;
        case (si_state)
            si_IDLE: begin
                si_done_next = 0;
                if (!SS) begin
                    si_next = si_PHASE;
                    si_bit_cnt_next = 0;
                end
            end
            si_PHASE: begin
                if (SS) begin
                    si_next = si_IDLE;
                end else begin
                    if (sclk_rising) begin
                        si_data_next = {si_data_reg[6:0], MOSI};
                        if (si_bit_cnt == 7) begin
                            si_done_next = 1'b1;
                            si_bit_cnt_next = 0;
                            si_next = si_IDLE;
                        end else begin
                            si_bit_cnt_next = si_bit_cnt + 1;
                        end
                    end
                end
            end
        endcase
    end
    ///////////////////////////////////////////////

    // Slave Output Circuit(MI_SO)
    localparam SO_IDLE = 0, SO_PHASE = 1;

    reg so_state, so_next;
    reg [7:0] so_data_reg, so_data_next;
    reg [2:0] so_bit_cnt, so_bit_cnt_next;
    reg so_done_reg, so_done_next;

    assign so_done = so_done_reg;
    assign MISO = SS ? 1'bz : so_data_reg[7];

    always @(posedge clk, posedge reset) begin  // so state logic
        if (reset) begin
            so_state    <= SO_IDLE;
            so_data_reg <= 0;
            so_bit_cnt  <= 0;
            so_done_reg <= 1'b0;
        end else begin
            so_state    <= so_next;
            so_data_reg <= so_data_next;
            so_bit_cnt  <= so_bit_cnt_next;
            so_done_reg <= so_done_next;
        end
    end

    always @(*) begin  // so next logic
        so_next         = so_state;
        so_data_next    = so_data_reg;
        so_bit_cnt_next = so_bit_cnt;
        so_done_next    = so_done_reg;
        case (so_state)
            SO_IDLE: begin
                so_done_next = 0;
                if (!SS && so_start) begin
                    so_bit_cnt_next = 0;
                    so_data_next    = so_data;
                    so_next         = SO_PHASE;
                end
            end
            SO_PHASE: begin
                if (SS) begin
                    so_next = SO_IDLE;
                end else begin
                    if (sclk_falling) begin
                        if (so_bit_cnt == 7) begin
                            so_done_next    = 1;
                            so_bit_cnt_next = 0;
                            so_next         = SO_IDLE;
                        end else begin
                            so_data_next = {so_data_reg[6:0], 1'b0};
                            so_bit_cnt_next = so_bit_cnt + 1;
                        end
                    end
                end
            end
        endcase
    end
    ///////////////////////////////////////////////

endmodule

module SPI_Slave_Reg (
    // global signals
    input            clk,
    input            reset,
    // internal signals
    input            ss_n,
    input      [7:0] si_data,
    input            si_done,
    // input            so_ready,
    output reg [7:0] so_data,
    output           so_start,
    input            so_done
);
    localparam IDLE = 0, ADDR_PHASE = 1, WRITE_PHASE = 2, READ_PHASE = 3;

    reg [7:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;
    reg [1:0] state, next;
    reg [1:0] addr_reg, addr_next;
    reg so_start_reg, so_start_next;

    assign so_start = so_start_reg;

    always @(posedge clk, posedge reset) begin  // slvreg state logic
        if (reset) begin
            state <= IDLE;
            addr_reg <= 0;
            so_start_reg <= 0;
        end else begin
            state <= next;
            addr_reg <= addr_next;
            so_start_reg <= so_start_next;
        end
    end

    always @(*) begin  // slvreg next logic
        next = state;
        addr_next = addr_reg;
        so_start_next = so_start_reg;
        case (state)
            IDLE: begin
                so_start_next = 0;
                if (!ss_n) begin
                    next = ADDR_PHASE;
                end
            end
            ADDR_PHASE: begin
                if (ss_n) begin
                    next = IDLE;
                end else begin
                    if (si_done) begin
                        addr_next = si_data[1:0];
                        if (si_data[7]) next = WRITE_PHASE;
                        else next = READ_PHASE;
                    end
                end
            end
            WRITE_PHASE: begin
                if (ss_n) begin
                    next = IDLE;
                end else begin
                    if (si_done) begin
                        case (addr_reg)
                            2'd0: slv_reg0 = si_data;
                            2'd1: slv_reg1 = si_data;
                            2'd2: slv_reg2 = si_data;
                            2'd3: slv_reg3 = si_data;
                        endcase
                        if (addr_reg == 3) begin
                            addr_next = 0;
                        end else addr_next = addr_reg + 1;
                    end
                end
            end
            READ_PHASE: begin
                if (ss_n) begin
                    next = IDLE;
                end else begin
                    so_start_next = 1;
                    so_data = 8'bx;
                    case (addr_reg)
                        2'd0: so_data = slv_reg0;
                        2'd1: so_data = slv_reg1;
                        2'd2: so_data = slv_reg2;
                        2'd3: so_data = slv_reg3;
                    endcase
                    if (so_done) begin
                        if (addr_reg == 3) addr_next = 0;
                        else addr_next = addr_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule
