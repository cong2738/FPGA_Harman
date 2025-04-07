`timescale 1ns / 1ps

module tb_Processor ();
    logic       clk;
    logic       reset;
    logic [7:0] out_data;

    Top_Processor uut (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;
        $monitor("sum:%d", out_data);
        wait(uut.u_ControlUnit.state == 7);
        #100 $stop;
    end
endmodule
