module alu
    import alu_pkg::*;
(
    input alu_op_t op,
    input logic [DATA_WIDTH-1:0] a,
    input logic [DATA_WIDTH-1:0] b,
    output logic [DATA_WIDTH-1:0] result
);

    always_comb begin
        unique case (op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_SLL:  result = a << b[SHIFT_WIDTH-1:0];
            ALU_SRL:  result = a >> b[SHIFT_WIDTH-1:0];
            ALU_SRA:  result = $signed(a) >>> b[SHIFT_WIDTH-1:0];
            ALU_SLT:  result = {{(DATA_WIDTH-1){1'b0}}, ($signed(a) < $signed(b))};
            ALU_SLTU: result = {{(DATA_WIDTH-1){1'b0}}, (a < b)};
            default:  result = 'x;
        endcase
    end

endmodule
