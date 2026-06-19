module register_file #(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_REGS = 32,
    parameter int ADDR_WIDTH = 5
)(
    input logic clk,
    input logic n_rst,

    input logic [ADDR_WIDTH-1:0] rs1_addr,
    input logic [DATA_WIDTH-1:0] rs1_data,

    input logic [ADDR_WIDTH-1:0] rs2_addr,
    input logic [DATA_WIDTH-1:0] rs2_data,

    input logic we,
    input logic [ADDR_WIDTH-1:0] rd_addr,
    input logic [DATA_WIDTH-1:0] rd_data
);

    logic [DATA_WIDTH-1:0] rf [NUM_REGS];

    assign rs1_data = (rs1_addr == '0) ? '0 : rf [rs1_addr];
    assign rs2_data = (rs2_addr == '0) ? '0 : rf [rs2_addr];

    always_ff @ (posedge clk)
    

endmodule
