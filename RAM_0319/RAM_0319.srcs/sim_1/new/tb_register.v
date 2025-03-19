`timescale 1ns / 1ps

module tb_register ();
    reg clk;
    reg [31:0] data;
    wire [31:0] q;

    register uut (
        .clk(clk),
        .data(data),
        .q(q)
    );

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        data = 0;
        #10;
        data = 32'h12345678;
        #10;
        @(posedge clk);
        if (data == q) begin
            $display("Test paased");
        end else begin
            $display("Test failed");
        end

        @(posedge clk);
        $finish;
    end

endmodule
