`timescale 1ns / 1ps

module b_nb_exam ();
    reg clk, a, b;
    initial begin
        a   = 0;
        b   = 1;
        clk = 0;
    end
    always begin
        clk = #5 ~clk;
    end
    always @(posedge clk) begin
        a <= b;
        b <= a;
    end
endmodule
