`timescale 1ns / 1ps

module tb_processor ();
    reg clk;
    reg reset;
    wire [7:0] A_out;

    top_DedicatedProcessor uut (
        .clk  (clk),
        .reset(reset),
        .A_out(A_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;
        while (!uut.comp_Aand10) begin
           @(uut.u_ControlUnit.out_sel) $display("A:%d", uut.A_out); 
        end
        #100 $stop;
    end
endmodule
