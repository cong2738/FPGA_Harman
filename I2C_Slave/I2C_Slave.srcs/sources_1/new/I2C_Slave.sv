`timescale 1ns / 1ps

module I2C_Slave #(
    localparam SLV_ADDR = 7'b0000000
) (
    input logic clk,
    input logic reset,
    inout logic sda,
    input logic scl
);
    logic [7:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    typedef enum logic [3:0] {
        IDLE,
        START,
        DATA_CL0,
        DATA_CL1,
        ACK_CL0,
        ACK_CL1
    } state_enum;
    typedef enum logic [1:0] {
        SLV_ADDR_SEL,
        WORD_ADDR_SEL,
        DATA_RUN
    } dataStage_enum;
    state_enum state, next;
    dataStage_enum data_stage, data_stage_next;
    logic [2:0] bit_count, bit_count_next;
    logic [1:0] reg_addr, reg_addr_next;
    logic [7:0] temp_data, temp_data_next;
    logic slv_mode, slv_mode_next;
    logic IO_Sel, IO_Sel_next;
    logic sda_reg;

    assign sda = IO_Sel ? 1'bz : sda_reg;

    always_ff @(posedge clk) begin : state_logic
        if (reset) begin
            state <= IDLE;
            data_stage <= SLV_ADDR_SEL;
            bit_count <= 0;
            reg_addr <= 0;
            temp_data <= 0;
            slv_mode <= 0;
            IO_Sel <= 1;
        end else begin
            state <= next;
            data_stage <= data_stage_next;
            bit_count <= bit_count_next;
            reg_addr <= reg_addr_next;
            temp_data <= temp_data_next;
            slv_mode <= slv_mode_next;
            IO_Sel <= IO_Sel_next;
        end
    end
    always_comb begin : next_logic
        next = state;
        data_stage_next = data_stage;
        bit_count_next = bit_count;
        reg_addr_next = reg_addr;
        temp_data_next = temp_data;
        slv_mode_next = slv_mode;
        IO_Sel_next = IO_Sel;
        sda_reg = 0;
        case (state)
            IDLE: begin  // sda = 1, scl = 1
                IO_Sel_next = 1;
                slv_mode_next = 0;
                data_stage_next = SLV_ADDR_SEL;
                if (!sda) begin
                    next = START;
                end
            end
            START: begin  // sda = 0, scl = 1
                if (!scl) begin
                    next = DATA_CL0;
                end
            end
            DATA_CL0: begin  // scl = 0
                if (scl) begin  // sda = data or stop_sig
                    next = DATA_CL1;
                    temp_data_next = {
                        temp_data[6:0], sda
                    };  // capture sda to temp_data;
                end
            end
            DATA_CL1: begin  // scl = 1, sda = data or stop_sig
                if (temp_data[0] != sda) begin  // master_stop
                    slv_mode_next = 0;
                    bit_count_next = 0;
                    IO_Sel_next = 1;
                    next = IDLE;
                end else if (!scl) begin
                    if (bit_count == 7) begin  // data_save
                        case (data_stage)
                            SLV_ADDR_SEL: begin
                                if (temp_data[6:0] == SLV_ADDR) begin
                                    slv_mode_next   = temp_data[0];
                                    data_stage_next = WORD_ADDR_SEL;
                                end else begin
                                    slv_mode_next = 0;
                                    IO_Sel_next = 1;
                                    data_stage_next = SLV_ADDR_SEL;
                                    next = IDLE;
                                end
                            end
                            WORD_ADDR_SEL: begin
                                reg_addr_next   = temp_data;
                                data_stage_next = DATA_RUN;
                            end
                            DATA_RUN: begin
                                reg_addr_next = reg_addr + 1;
                                case (reg_addr)
                                    0: slv_reg0 = temp_data;
                                    1: slv_reg1 = temp_data;
                                    2: slv_reg2 = temp_data;
                                    3: slv_reg3 = temp_data;
                                endcase
                            end
                        endcase
                        bit_count_next = 0;
                        next = ACK_CL0;
                    end else begin
                        bit_count_next = bit_count + 1;
                        next = DATA_CL0;
                    end
                end
            end
            ACK_CL0: begin  // scl = 0, IO_Moed = Input_mode                
                if (scl) begin
                    IO_Sel_next = 0;
                    next = ACK_CL1;
                end
            end
            ACK_CL1: begin  // scl = 1, sda = slave_out, IO_Moed = Output_mode
                sda_reg = 0;
                if (!scl) begin
                    IO_Sel_next = 1;
                    next = DATA_CL0;
                end
            end
        endcase
    end
endmodule
