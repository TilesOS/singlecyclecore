module branch_comparator
    import branch_pkg::*;
# (
    parameter int DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,
    input  branch_op_t            branch_op,
    output logic                  branch_taken
);

    logic signed [DATA_WIDTH-1:0] rs1_signed;
    logic signed [DATA_WIDTH-1:0] rs2_signed;

    assign rs1_signed = rs1_data;
    assign rs2_signed = rs2_data;

    always_comb begin
        unique case (branch_op)

            BR_BEQ: begin
                branch_taken = (rs1_data == rs2_data);
            end

            BR_BNE: begin
                branch_taken = (rs1_data != rs2_data);
            end

            BR_BLT: begin
                branch_taken = (rs1_signed < rs2_signed);
            end

            BR_BGE: begin
                branch_taken = (rs1_signed >= rs2_signed);
            end

            BR_BLTU: begin
                branch_taken = (rs1_data < rs2_data);
            end

            BR_BGEU: begin
                branch_taken = (rs1_data >= rs2_data);
            end

            default: begin
                branch_taken = 1'b0;
            end

        endcase
    end

endmodule
