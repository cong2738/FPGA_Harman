`timescale 1ns / 1ps

module tb_I2C_master_only ();
    logic clk;
    logic reset;
    logic [3:0] CMD;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic done;
    logic ready;
    logic sda;
    logic scl;

    I2C_Master u_I2C_Master (
        .clk    (clk),
        .reset  (reset),
        .ready  (ready),
        .CMD    (CMD),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .done   (done),
        .sda    (sda),
        .scl    (scl)
    );
    localparam         
        IDLE = 0,
        START1 = 1,
        START2 = 2,
        HOLD = 3,
        STOP1 = 4,
        STOP2 = 5,
        RESTART = 6,
        DATA1 = 7,
        DATA2 = 8,
        DATA3 = 9,
        DATA4 = 10,
        DATA_END1 = 11,
        DATA_END2 = 12;
    localparam 
        IDLE_CMD = 0,
        START_CMD = 1,
        STOP_CMD = 2,
        RESTART_CMD = 3,
        RD_CMD = 4,
        WR_CMD = 5;

    // get master state
    logic master_state;
    assign master_state = u_I2C_Master.state;

    // three state buffer
    logic sda_tb;
    assign master_IO_sel = u_I2C_Master.sda_IO;
    assign sda = master_IO_sel ? sda_tb : 1'bz;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        sda_tb = 1'bz;
        #10 reset = 0;

        // idle: start protocol
        CMD = START_CMD;
        wait (master_state == START1);  // wait for start1
        CMD = IDLE_CMD;
        wait (master_state == HOLD);  // wait for HOLD

        begin  // I2C_Init(choose Slave target, set start address)
            // Slave Addr Write
            CMD = WR_CMD;
            tx_data = 8'b0000000_0;  // use slave0
            wait (master_state == DATA1);
            CMD = IDLE_CMD;
            wait (master_state == DATA_END1);  // wait data_end
            sda_tb = 0;  // sda Slave Out Master In ACK: 0
            wait (master_state == HOLD);
            sda_tb = 1'bz;

            // Word Addr Write
            CMD = WR_CMD;
            tx_data = 8'b0000000_0;  // use slv_reg0
            wait (master_state == DATA1);
            CMD = IDLE_CMD;
            wait (master_state == DATA_END1);  // wait data_end
            sda_tb = 0;  // SLAVE Response(ACK): 0 (continue protocol)
            wait (master_state == HOLD);
            sda_tb = 1'bz;
        end

        // Data Write
        CMD = WR_CMD;
        tx_data = 8'hf;  // write data set
        wait (master_state == DATA1);
        CMD = IDLE_CMD;
        wait (master_state == DATA_END1);  // wait data_end
        sda_tb = 1;  // SLAVE Response(ACK): 1 (end protocol)
        wait (master_state == STOP1);
        sda_tb = 1'bz;
        if (master_state == STOP2) begin
            $display("End protocol.");
            #100 $finish;
        end
    end
endmodule
