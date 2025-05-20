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
    logic       SS;

    SPI_Master master_dut (.*);
    SPI_Slave slave_dut (.*);

    always #5 clk = ~clk;

    task Write(logic [7:0] write_data);
        @(posedge clk);
        tx_data = write_data;
        start = 1;
        cpol = 0;
        cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);
    endtask  //

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;

        repeat (5) @(posedge clk);

        SS = 0; // start Write
        Write(8'b10000000); // adress byte
        Write(8'h10); //write data byte on 0x00 address
        Write(8'h20); //write data byte on 0x01 address
        Write(8'h30); //write data byte on 0x02 address
        Write(8'h40); //write data byte on 0x03 address
        SS = 1; // end Write

        repeat (5) @(posedge clk); 
        
        SS = 0; // start Read
        //adress byte
        Write(8'b00000000);
        // send dumy WriteData for done signal
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
        end
        SS = 1; // end Read

        #1000 $finish;
    end

endmodule
