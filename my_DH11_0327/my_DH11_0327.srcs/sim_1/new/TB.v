`timescale 1ns / 1ps

module TB ();
    localparam  IDLE  = 7'b0000000, 
                START = 7'b0000001, 
                WAIT  = 7'b0000010,
                SYNC0 = 7'b0000100, 
                SYNC1 = 7'b0001000, 
                READY = 7'b0010000,
                DATA1 = 7'b0100000,
                DATA0 = 7'b1000000;


    reg clk;
    reg rst;
    reg start_trigger;



    reg data_in;
    reg data_t;
    wire dht_IO;
    assign dht_IO = (data_t) ? data_in : 1'bz;
    TOP_DHT11 uut (
        .clk(clk),
        .rst(rst),
        .btn_start(start_trigger),
        .dht_IO(dht_IO),
        .CU_LED( ),
        .ERROR_LED( ),
        .fpga_LED( ),
        .fnd_font( ),
        .fnd_comm( )
    );


    task send_data(input [39:0] data);
        integer i;
        begin
            $display("Sending data: %d", data);

            for (i = 0; i < 40; i = i + 1) begin
                data_in = 0;
                #50000;
                if (data[39-i] == 0) begin
                    data_in = 1;
                    #30000;
                end else if (data[39-i] == 1) begin
                    data_in = 1;
                    #70000;
                end
            end
        end

    endtask
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        data_t = 0;
        start_trigger = 0;
        #100 rst = 0;
        start_trigger = 1;
        wait (uut.u_btn_debounce.o_btn);
        start_trigger = 0;
        wait (uut.U_DHT_CU.state == START);
        wait (uut.U_DHT_CU.state == WAIT);
        data_t = 1;
        #10;
        data_in = 0;
        #80000;
        data_in = 1;
        #80000;
        send_data(40'b10100000_00000000_00000000_00000000_00000001);
        data_in = 0;
        wait(uut.U_DHT_CU.state == IDLE);
        #10000 $stop;
    end

endmodule






