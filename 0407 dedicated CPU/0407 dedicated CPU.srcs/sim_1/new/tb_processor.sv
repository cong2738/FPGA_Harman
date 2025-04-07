`timescale 1ns / 1ps

module tb_processor ();
    logic clk;
    logic reset;
    logic [7:0] sum_out;

    top_DedicatedProcessor uut (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;
        $monitor("sum:%d", uut.sum_out);
        @(negedge uut.comp_Aand10);
        #100 $stop;
    end
endmodule
