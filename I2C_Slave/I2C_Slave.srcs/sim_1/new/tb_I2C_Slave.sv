`timescale 1ns / 1ps

module tb_I2C_Slave ();
    localparam 
        IDLE = 0,
        START = 1,
        DATA_CL0 = 2,
        DATA_CL1 = 3,
        ACK_CL0 = 4,
        ACK_CL1 = 5;

    logic clk;
    logic reset;
    wire  sda;
    logic scl;
    I2C_Slave u_I2C_Slave (.*);

    logic IO_Sel;
    logic master_sda;
    assign IO_Sel = u_I2C_Slave.IO_Sel;
    assign sda = IO_Sel ? master_sda : 1'bz;

    logic [7:0] slave_set;
    logic [7:0] word_addr;

    task write_data(logic [7:0] data);
        logic [7:0] temp_data;
        int bit_count;
        temp_data = data;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = temp_data[7];
            repeat (500) @(posedge clk) scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk) scl = 0;
            temp_data = {temp_data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk) scl = 1;
        repeat (500) @(posedge clk) scl = 0;
        bit_count = 0;
    endtask  //

    task start_transmission();
        // master send start sig
        master_sda = 1;
        scl = 1;
        repeat (500) @(posedge clk) master_sda = 0;
        repeat (500) @(posedge clk) scl = 0;
    endtask  //

    task end_transmission();
        // master send stop sig
        scl = 0;
        master_sda = 1'b0;
        repeat (500) @(posedge clk) scl = 1;
        repeat (500) @(posedge clk) master_sda = 1;
    endtask  //

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        repeat (2500) @(posedge clk);
        $display("test start");

        slave_set = 8'b0000_0;
        word_addr = 1;

        start_transmission();

        write_data(slave_set);
        write_data(word_addr);
        write_data(8'haa);
        write_data(8'h99);
        write_data(8'h88);
        write_data(8'h77);

        end_transmission();

        repeat (2500) @(posedge clk);
        $finish;
    end

endmodule
