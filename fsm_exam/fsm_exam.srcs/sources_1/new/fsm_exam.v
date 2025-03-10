`timescale 1ns / 1ps

module fsm_exam (
    input clk,
    input reset,
    input [2:0] sw,
    output reg [2:0] led
);
    localparam  IDLE =  3'b000,
                ST1 =   3'b001,
                ST2 =   3'b010,
                ST3 =   3'b100,
                ST4 =   3'b111;

    reg [2:0] state, next;

    //state control
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end

    //next logic
    always @(*) begin
        case (state)
            IDLE: begin
                case (sw)
                    3'b001:  next = ST1;
                    3'b010:  next = ST2;
                    default: next = state;
                endcase
            end

            ST1: begin
                case (sw)
                    3'b010:  next = ST2;
                    default: next = state;
                endcase
            end

            ST2: begin
                case (sw)
                    3'b100:  next = ST3;
                    default: next = state;
                endcase
            end

            ST3: begin
                case (sw)
                    3'b000:  next = IDLE;
                    3'b001:  next = ST1;
                    3'b111:  next = ST4;
                    default: next = state;
                endcase
            end

            ST4: begin
                case (sw)
                    3'b100:  next = ST3;
                    default: next = state;
                endcase
            end
            
            default: next = state; //주의!! 이거 안하면 합성과정중 래치생김.
        endcase
    end

    // output logic
    // always @(*) begin
    //     case (next) //무어모델 "다음"상태에 따라(1클럭 이후) 바로 출력
    //         IDLE: led = IDLE;
    //         ST1: led = ST1;
    //         ST2: led = ST2;
    //         ST3: led = ST3;
    //         ST4: led = ST4;
    //         default: led = IDLE; 
    //     endcase
    // end

    // output logic 밀리모델 지금상태의 "입력"에 따라 출력
    always @(*) begin
        case (state)
            IDLE: begin
                case (sw)
                    3'b001:  led = ST1;
                    3'b010:  led = ST2;
                    default: led = IDLE;
                endcase
            end

            ST1: begin
                case (sw)
                    3'b010:  led = ST2;
                    default: led = ST1;
                endcase
            end

            ST2: begin
                case (sw)
                    3'b100:  led = ST3;
                    default: led = ST2;
                endcase
            end

            ST3: begin
                case (sw)
                    3'b000:  led = IDLE;
                    3'b001:  led = ST1;
                    3'b111:  led = ST4;
                    default: led = ST3;
                endcase
            end

            ST4: begin
                case (sw)
                    3'b100:  led = ST3;
                    default: led = ST4;
                endcase
            end

            default: led = IDLE;
        endcase
    end

endmodule
