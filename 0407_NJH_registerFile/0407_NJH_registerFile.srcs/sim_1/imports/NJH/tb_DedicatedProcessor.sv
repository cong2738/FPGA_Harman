`timescale 1ns / 1ps

module tb_DedicatedProcessor ();
    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        S8,
        S9,
        S10
    } state_e;

    logic       clk;
    logic       reset;
    logic [7:0] outPort;

    top_DedicatedProcessor dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;
        wait (dut.U_ControlUnit.state == S10);
        #20 $finish;
    end
endmodule
