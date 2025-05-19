`timescale 1ns / 1ps

module tb_slave ();
    logic       reset;
    // external signals
    logic       SCLK;
    logic       SS;
    logic       MOSI;
    logic       MISO;
    // internal signals
    logic       done;
    logic       write;
    logic [1:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;

    SlaveInterface u_SlaveInterface (
        .reset(reset),
        .SCLK (SCLK),
        .SS   (SS),
        .MOSI (MOSI),
        .MISO (MISO),
        .done (done),
        .write(write),
        .addr (addr),
        .wdata(wdata),
        .rdata(rdata)
    );
    
    logic write_done;
    assign write_done = u_SlaveInterface.write_done;

    always #5 SCLK = ~SCLK;

    initial begin
        SCLK  = 0;
        reset = 1;
        SS = 1;
        #10 reset = 0;

        SS = 0;

        MOSI = 0;
        wait(write_done);

        rdata = 8'haa;
        wait(done);

        rdata = 8'h55;
        wait(done);

        #50 $finish;
    end
endmodule
