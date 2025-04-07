module Top_Processor (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] out_data
);
    logic       comp_10;
    logic       initial_sig;
    logic       mux_sel01;
    logic       wen;
    logic [2:0] wptr;
    logic [2:0] rptr1;
    logic [2:0] rptr2;
    logic       out_sel;

    ControlUnit u_ControlUnit (.*);

    DataPath u_DataPath (.*);

endmodule
