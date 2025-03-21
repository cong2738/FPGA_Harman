/*
 * 8-bit UART Transmitter.
 * Able to transmit 8 bits of serial data, one start bit, one stop bit.
 * When transmit is complete {done} is driven high for one clock cycle.
 * When transmit is in progress {busy} is driven high.
 * Clock should be decreased to baud rate.
 */
module Uart8Transmitter (
    input  wire       clk,    // baud rate
    input  wire       en,
    input  wire       start,  // start of transaction
    input  wire [7:0] in,     // data to transmit
    output reg        out,    // tx
    output reg        done,   // end on transaction
    output reg        busy    // transaction is in process
);
    // states of state machine
    localparam  RESET =        3'b001
                ,IDLE =         3'b010
                ,START_BIT =    3'b011
                ,DATA_BITS =    3'b100
                ,STOP_BIT =     3'b101;

    reg [2:0] state = RESET;
    reg [7:0] data = 8'b0; 
    reg [2:0] bitIdx = 3'b0;  

    always @(posedge clk) begin
        case (state)
            default: begin
                state <= IDLE;
            end
            IDLE: begin
                out    <= 1'b1;  // default tx is high
                done   <= 1'b0;
                busy   <= 1'b0;
                bitIdx <= 3'b0;
                data   <= 8'b0;
                if (start & en) begin
                    data  <= in;  
                    state <= START_BIT;
                end
            end
            START_BIT: begin
                out   <= 1'b0;  // send start bit (low)
                busy  <= 1'b1;
                state <= DATA_BITS;
            end
            DATA_BITS: begin  // Wait 8 clock cycles for data bits to be sent
                out <= data[bitIdx];
                if (&bitIdx) begin
                    bitIdx <= 3'b0;
                    state  <= STOP_BIT;
                end else begin
                    bitIdx <= bitIdx + 1'b1;
                end
            end
            STOP_BIT: begin  // Send out Stop bit (high)
                out   <= 1'b1;
                done  <= 1'b1;
                data  <= 8'b0;
                state <= IDLE;
            end
        endcase
    end

endmodule
