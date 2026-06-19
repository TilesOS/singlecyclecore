module register_file #(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_REGS = 32,
    parameter int ADDR_WIDTH = 5 // 2^{5} = 32
)(
    input logic clk,
    input logic rstn, // reset on negedge

    // read port 1
    input logic [ADDR_WIDTH-1:0] rs1_addr,
    input logic [DATA_WIDTH-1:0] rs1_data,

    // read port 2
    input logic [ADDR_WIDTH-1:0] rs2_addr,
    input logic [DATA_WIDTH-1:0] rs2_data,

    // write port
    input logic we,
    input logic [ADDR_WIDTH-1:0] rd_addr,
    input logic [DATA_WIDTH-1:0] rd_data
);

    logic [DATA_WIDTH-1:0] rf [NUM_REGS];

    // reads asynchronously
    assign rs1_data = (rs1_addr == '0) ? '0 : rf [rs1_addr];
    assign rs2_data = (rs2_addr == '0) ? '0 : rf [rs2_addr];

    // writes synchronously
    always_ff @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < NUM_REGS; i++) begin
                rf [i] <= '0;
            end
        end else if (we && (rd_addr != '0)) begin
            rf [rd_addr] <= rd_data;
        end
    end

endmodule
