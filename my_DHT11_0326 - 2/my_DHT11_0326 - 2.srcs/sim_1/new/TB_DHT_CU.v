`timescale 1ns / 1ps

module TB_DHT_CU ();
    localparam  IDLE  = 7'b0000000, 
                START = 7'b0000001, 
                WAIT  = 7'b0000010,
                SYNC0 = 7'b0000100, 
                SYNC1 = 7'b0001000, 
                DATA0 = 7'b0010000, 
                DATA1 = 7'b0100000,
                DEND0 = 7'b1000000;

    reg clk;
    reg rst;
    reg btn_start;
    reg io_oe_reg;
    wire [6:0]sensor_LED;
    wire dht_IO;

    reg dht_io_reg;
    assign dht_IO = (io_oe_reg) ? dht_io_reg : 1'bz;
    wire [39:0] data;
    assign data = uut.U_DHT_CU.data;
    
    TOP_DHT11 uut (
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start),
        .sensor_LED(sensor_LED),
        .dht_IO(dht_IO)
    );



    always #5 clk = ~clk;

    integer n;
    initial begin
        clk = 0;
        rst = 1;
        btn_start = 0;
        io_oe_reg = 1;
        #100 rst = 0;
        btn_start = 1;
        wait (uut.u_btn_debounce.o_btn);
        btn_start = 0;
        wait (uut.U_DHT_CU.state == SYNC0);
        io_oe_reg = 1;
        #10000 dht_io_reg = 1;
        wait (uut.U_DHT_CU.state == SYNC1);
        #10000 dht_io_reg = 0;
        for (n = 0; n < 40; n = n + 1) begin
            wait (uut.U_DHT_CU.state == DATA0);
            #10000 dht_io_reg = 1;
            wait (uut.U_DHT_CU.state == DATA1);
            #60000 dht_io_reg = 0;
        end
        wait(uut.U_DHT_CU.state == DEND0)
        
        wait(uut.U_DHT_CU.state == IDLE)
        
        #80000 $stop;
    end
endmodule
