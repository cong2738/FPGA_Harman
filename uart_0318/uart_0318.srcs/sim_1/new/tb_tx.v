`timescale 1ns / 1ps
module tb_tx (
);
    // send_tx_btn #(
    //     .BAUD_RATE(100)
    // ) DUT (
    //     .clk(clk),
    //     .rst(rst),
    //     .btn_start(btn),
    //     .tx(tx)
    // );

    // always #10 clk = ~clk;

    // initial begin
    //     clk = 0;
    //     rst = 1;
    //     wait (DUT.tx == 1);
    //     rst = 0;
    //     #10;
    //     btn = 1;
    //     wait (DUT.U_btn_Debounce.o_btn == 1);
    //     btn = 0;
    //     // #10000000;
    //     // btn = 1;
    //     // wait (DUT.U_btn_Debounce.o_btn == 1);
    //     // btn = 0;
    // end
endmodule
