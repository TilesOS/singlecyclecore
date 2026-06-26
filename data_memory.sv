`define DATA_WIDTH 32

module data_memory # (
    parameter MEM_TOTAL = 1024
) (
    input logic  clk,
    input logic  we,
    input logic  [DATA_WIDTH-1:0] data_in,
    input logic  [$clog2(MEM_TOTAL)-1:0] addr,
    output logic [DATA_WIDTH-1:0] data_out
);

endmodule
