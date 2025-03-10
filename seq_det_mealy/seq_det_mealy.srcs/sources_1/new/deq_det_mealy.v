`timescale 1ns / 1ps

module deq_det_mealy (
    input  clk,
    input  reset,
    input  din_bit,
    output reg dout_bit
);
    parameter   START = 3'b000,
                RD0_ONCE = 3'b001,
                RD1_ONCE = 3'b010,
                RD0_TWICE= 3'b011,
                RD1_TWICE= 3'b100;

    reg[2:0] state, next;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= START;
        end else begin
            state <= next;
        end
    end

    always @(state or din_bit) begin
        case (state)
            START: begin
                case (din_bit)
                    0: next = RD0_ONCE;
                    1: next = RD1_ONCE;
                    default: next = START;
                endcase
            end

            RD0_ONCE: begin
                case (din_bit)
                    0: next = RD0_TWICE;
                    1: next = RD1_ONCE;
                    default: next = START;
                endcase
            end

            RD1_ONCE: begin
                case (din_bit)
                    0: next = RD0_ONCE;
                    1: next = RD1_TWICE;
                    default: next = START;
                endcase
            end

            RD0_TWICE: begin
                case (din_bit)
                    0: next = RD0_TWICE;
                    1: next = RD1_ONCE;
                    default: next = START;
                endcase
            end

            RD1_TWICE: begin
                case (din_bit)
                    0: next = RD0_ONCE;
                    1: next = RD1_TWICE;
                    default: next = START;
                endcase
            end

            default: next = START;
        endcase
    end

    always @(*) begin
        case (state)
            START: case (din_bit)
                0: dout_bit = 0;
                1: dout_bit = 0;
            endcase
            
            RD0_ONCE: case (din_bit)
                0: dout_bit = 1;
                1: dout_bit = 0; 
            endcase

            RD1_ONCE: case (din_bit)
                0: dout_bit = 0;
                1: dout_bit = 1;
            endcase

            RD0_TWICE: case (din_bit)
                0: dout_bit = 1;
                1: dout_bit = 0;
            endcase

            RD1_TWICE: case (din_bit)
                0: dout_bit = 0;
                1: dout_bit = 1;
            endcase

            default: dout_bit = 0;
        endcase
    end

endmodule
