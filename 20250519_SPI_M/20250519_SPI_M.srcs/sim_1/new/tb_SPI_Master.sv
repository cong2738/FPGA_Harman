`timescale 1ns / 1ps

module tb_SPI_Master ();
    // global signals
    logic       clk;
    logic       reset;
    // internam signals
    logic       cpol;
    logic       cpha;
    logic       start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       done;
    logic       ready;
    // external port
    logic       SCLK;
    logic       MOSI;
    logic       MISO;

    SPI_Master dut (.*);

    assign MISO = MOSI;
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;

        repeat (3) @(posedge clk);

        cpol = 0;
        cpha = 1;

        tx_data = 8'haa;
        start   = 1;
        @(posedge clk);
        start = 0;
        wait (done);
        @(posedge clk);

        cpol = 0;
        cpha = 0;

        repeat (3) @(posedge clk);
        tx_data = 8'h55;
        start   = 1;
        @(posedge clk);
        start = 0;
        wait (done);
        @(posedge clk);

        #1000 $finish;
    end

endmodule
