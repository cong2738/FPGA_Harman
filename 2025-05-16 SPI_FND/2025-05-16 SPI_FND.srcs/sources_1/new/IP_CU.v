`timescale 1ns / 1ps

module IP_CU (
    input  wire        sys_clk,
    input  wire        SCLK,
    input  wire        reset,
    input  wire        CS,
    input  wire [ 7:0] i_data,
    input  wire        done,
    output wire [13:0] bcd
);
    localparam IDLE = 0, L_BYTE = 1, H_BYTE = 2, WAIT = 3;

    reg [1:0] state, next;
    reg [15:0] data_reg, data_next;

    assign bcd = data_reg[13:0];

    always @(posedge sys_clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_reg <= 0;
        end else begin
            state <= next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        next = state;
        data_next = data_reg;
        case (state)
            IDLE: begin
                if (!CS) begin
                    next = L_BYTE;
                end
            end
            L_BYTE: begin
                if (CS && done) begin
                    data_next[7:0] = i_data;
                    next = WAIT;
                end
            end
            WAIT: begin
                if (!done) begin
                    next = H_BYTE;
                end
            end
            H_BYTE: begin
                if (CS && done) begin
                    data_next[15:8] = i_data;
                    next = IDLE;
                end
            end
        endcase
    end
endmodule
