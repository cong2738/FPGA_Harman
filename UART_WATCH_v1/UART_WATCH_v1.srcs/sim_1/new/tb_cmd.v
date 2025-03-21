`timescale 1ns / 1ns


module tb_cmd ();
    reg  clk;
    reg  rst;
    reg  hs_mod_sw;
    reg  watch_mod_sw = 0;
    reg  btnU = 0;
    reg  btnL = 0;
    reg  btnR = 0;
    reg  btnD = 0;
    reg  rx;
    wire tx;
    TOP_UART_WATCH uut (
        .clk(clk),
        .reset(rst),
        .hs_mod_sw(hs_mod_sw),
        .watch_mod_sw(watch_mod_sw),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .rx(rx),
        .tx(tx),
        .fnd_comm(),
        .fnd_font(),
        .mod_indicate_led()
    );

    task send_data(input [7:0] data);
        integer i;
        begin
            $display("Sending data %h", data);

            //Start bit(Low)
            rx = 0;
            #(10 * 10417);

            //Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(10 * 10417);
            end

            //Stop bit(High)
            rx = 1;
            #(10 * 10417);

            $display("Data sent: %h", data);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        hs_mod_sw = 0;
        #50 rst = 0;
        #10000;

        send_data("R");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        send_data("R");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        send_data("C");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        hs_mod_sw = 1;
        wait (clk);
        wait (!clk);

        send_data("H");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        send_data("M");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        send_data("S");
        wait (uut.U_UART.rx_done);
        wait (uut.U_UART.U_UART.tx_busy);
        wait (!uut.U_UART.U_UART.tx_busy);

        #10000;


        $stop;


    end

endmodule

