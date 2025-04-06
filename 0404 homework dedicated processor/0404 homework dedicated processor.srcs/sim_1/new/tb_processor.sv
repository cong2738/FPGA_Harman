`timescale 1ns / 1ps

module tb_processor ();
    reg clk;
    reg reset;
    wire [7:0] sum_out;

    top_DedicatedProcessor uut(
        .clk     (clk     ),
        .reset   (reset   ),
        .sum_out (sum_out )
    );
    
    always #5 clk = ~clk;

    always @(uut.sum_out) $monitor("sum:%d", uut.sum_out); 

    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;
        wait (uut.comp_Aand10);
        #100 $stop;
    end
endmodule
