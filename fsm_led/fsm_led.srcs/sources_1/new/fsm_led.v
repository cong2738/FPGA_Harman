`timescale 1ns / 1ps

module fsm_led (
    input clk,
    input reset,
    input [2:0] sw,
    output reg [1:0] led
);

    localparam IDLE = 2'b00, LED01 = 2'b01, LED02 = 2'b10;
    reg [1:0] state, next;

    // state 저장
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
            // next  <= 0;
        end else begin
            // 상태관리
            state <= next;
        end
    end

    // next combinational logic
    // 다음 상태로 가기 위 한 로직
    always @(*) begin
        if (reset) begin
            next = 0;
        end else  next = state;
        case (state)
            IDLE: begin
                if (sw == 3'b001) begin
                    next = LED01;
                end
            end
            LED01: begin
                if (sw == 3'b011) begin
                    next = LED02;
                end
            end
            LED02: begin
                if (sw == 3'b110) begin
                    next = LED01;
                end else if (sw == 3'b111) begin
                    next = IDLE;
                end else next = state;
            end
            default: begin
                next = state;
            end
        endcase
    end

    // output combinational logic
    always @(*) begin
        case (next) //case인자에 state로 하면 
            IDLE: begin
                led = IDLE;
            end
            LED01: begin
                led = LED01;
            end
            LED02: begin
                led = LED02;
            end
            default: begin
                led = IDLE;
            end
        endcase
    end

endmodule
