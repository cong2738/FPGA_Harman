`timescale 1ns / 1ps

module tb_uart_fifo ();
    reg clk;
    reg reset;
    reg rx;
    reg sw_mode;
    reg btnL;
    reg btnR;
    reg btnU;
    reg btnD;
    reg d_HC_SR04_i;
    wire tx;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;
    wire start_tick;

    Real_Top u_Real_Top (
        .clk        (clk),
        .reset      (reset),
        .sw_mode    (sw_mode),
        .btnL       (btnL),
        .btnR       (btnR),
        .btnU       (btnU),
        .btnD       (btnD),
        .d_HC_SR04_i(d_HC_SR04_i),
        .rx         (rx),
        .tx         (tx),
        .fnd_comm   (fnd_comm),
        .fnd_font   (fnd_font),
        .start_tick (start_tick)
    );

    // uart_tx_done = w_tx_done
    // uart_rx_done = w_rx_done
    // fifo_tx_rdata = w_tx_data
    // fifo_rx_rdata = w_rx_data
    /////////////////
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        sw_mode = 0;
        btnL =0;
        btnR =0;
        btnU =0;
        btnD =0;
        d_HC_SR04_i =0;

        #50 reset = 0;
        #1;

        send_data(8'h52);
        send_data(8'h52);
        send_data(8'h43);


        //wait_for_rx();



        //wait(uart_tx_done); //w_tx_done
        //wait(!uart_tx_done);  
    end


    // Task: 데이터 송신 시뮬레이션 (TX -> RX LoopBack)
    task send_data(input [7:0] data);
        integer i;
        begin
            $display("Sending data: %h", data);

            // Start bit (Low)
            rx = 0;
            #(10 * 10417);  // Baud Rate에 따른 시간 지연 (9600bps 기준)

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(10 * 10417);  // 각 비트 전송 시간 지연
            end

            // Stop bit (High)
            rx = 1;
            #(10 * 10417);  // 정지 비트 시간 지연

            $display("Data sent: %h", data);
        end
    endtask
    /*
        task wait_for_rx();
            begin
                wait(uart_rx_done);
                if (fifo_rx_rdata !== fifo_tx_rdata) begin
                    $display
                end
            end
        endtask*/

endmodule
