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
    I2C_Slave u_I2C_Slave (
        .clk  (clk),
        .reset(reset),
        .sda  (sda),
        .scl  (scl)
    );

    logic [7:0] data;
    int bit_count;

    logic IO_Sel;
    logic master_sda;
    assign IO_Sel = u_I2C_Slave.IO_Sel;
    assign sda = IO_Sel ? master_sda : 1'bz;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        master_sda = 1;
        scl = 1;
        #10 reset = 0;
        #25000 master_sda = 0;
        wait (u_I2C_Slave.state == START);
        #25000 scl = 0;
        bit_count = 0;

        data = 8'h00;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        data = 8'h01;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        data = 8'haa;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        data = 8'h99;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        data = 8'h88;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        data = 8'h77;
        for (int i = 0; i < 8; i++) begin
            wait (u_I2C_Slave.state == DATA_CL0);
            master_sda = data[7];
            repeat (500) @(posedge clk);
            scl = 1;

            wait (u_I2C_Slave.state == DATA_CL1);
            bit_count++;
            repeat (500) @(posedge clk);
            scl  = 0;
            data = {data[6:0], 1'b0};
        end
        master_sda = 1'bz;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        scl = 0;
        bit_count = 0;

        // master sen stopsig
        master_sda = 1'b0;
        repeat (500) @(posedge clk);
        scl = 1;
        repeat (500) @(posedge clk);
        master_sda = 1;


        #25000 $finish;
    end

endmodule
