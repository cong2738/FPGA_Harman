`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/03 20:16:26
// Design Name: 
// Module Name: tb_btn_DB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// module tb_btn_DB ();
//     reg  clk;
//     reg  reset;
//     reg  i_btn;
//     wire o_btn;

//     btn_debounce u_btn_debounce (
//         .clk  (clk),
//         .reset(reset),
//         .i_btn(i_btn),
//         .o_btn(o_btn)
//     );


//     always #5 clk = ~clk;

//     initial begin
//         clk   = 0;
//         reset = 1;
//         i_btn = 0;
//         #100;
//         reset = 0;
//         i_btn = 1;
//         wait (o_btn);
//         #1000;
//     end
// endmodule


module tb_btn_DB ();
    reg clk;
    reg reset;
    reg btnU;
    reg btnL;
    reg btnR;
    reg btnD;
    reg rx;
    wire tx;
    wire [3:0] fndCom;
    wire [7:0] fndFont;
    wire led;

    top u_top (
        .clk    (clk),
        .reset  (reset),
        .btnU   (btnU),
        .btnL   (btnL),
        .btnR   (btnR),
        .btnD   (btnD),
        .rx     (rx),
        .tx     (tx),
        .fndCom (fndCom),
        .fndFont(fndFont),
        .led    (led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        btnU = 0;
        btnL = 0;
        btnR = 0;
        btnD = 0;
        rx = 1;
        #100;
        reset=0;
        #1;
        btnL = 1;
        wait(u_top.u_control_unit.d_btnL);
        #1 btnL = 0;
        #1000;
        $stop;
    end
endmodule
