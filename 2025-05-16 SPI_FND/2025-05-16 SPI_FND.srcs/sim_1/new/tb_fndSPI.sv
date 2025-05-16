`timescale 1ns / 1ps

module tb_fndSPI ();
    logic sys_clk;
    logic reset;
    logic btn;
    logic [15:0] sw;
    logic [15:0] led;
    logic [3:0] comm;
    logic [7:0] font;

    top_SPI_FND #(2) DUT (
        .sys_clk(sys_clk),
        .reset  (reset),
        .btn    (btn),
        .sw     (sw),
        .led    (led),
        .comm   (comm),
        .font   (font)
    );

    always #5 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 0;
        reset = 1;
        sw = 16'd1111;
        btn = 0;
        #10 reset = 0;
        btn = 1;
        @(DUT.start) btn = 0;
        @(DUT.u_SPI_FND.done);
        @(!DUT.u_SPI_FND.done);
        @(DUT.u_SPI_FND.done);
        #1000 $finish;

    end

endmodule
