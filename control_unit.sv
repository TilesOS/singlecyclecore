module control_unit
    import alu_pkg::*;
    import immediate_type_pkg::*;
(
    input  logic [6:0] opcode,   // instr[6:0]
    input  logic [2:0] funct3,   // instr[14:12]
    input  logic       funct7b5, // instr[30] (funct7[5])

    output logic       reg_write,
    output imm_type_t  imm_src,
    output logic [1:0] alu_src_a,  // 00=rs1, 01=pc, 10=zero
    output logic       alu_src_b,  // 0=rs2, 1=imm
    output alu_op_t    alu_op,
    output logic       mem_write,
    output logic [1:0] result_src, // 00=alu, 01=mem, 10=pc+4
    output logic       branch,     // conditional branch
    output logic       jump,       // JAL  (target = pc + imm)
    output logic       jalr        // JALR (target = alu result, rs1 + imm)
);

    // ------------------------------------------------------------------
    // opcodes
    // ------------------------------------------------------------------
    localparam logic [6:0]
        OPCODE_LOAD   = 7'b0000011,
        OPCODE_STORE  = 7'b0100011,
        OPCODE_OP     = 7'b0110011, // R-type
        OPCODE_OP_IMM = 7'b0010011, // I-type ALU
        OPCODE_BRANCH = 7'b1100011,
        OPCODE_JAL    = 7'b1101111,
        OPCODE_JALR   = 7'b1100111,
        OPCODE_LUI    = 7'b0110111,
        OPCODE_AUIPC  = 7'b0010111,
        OPCODE_FENCE  = 7'b0001111,
        OPCODE_SYSTEM = 7'b1110011;

    // alu_src_a select
    localparam logic [1:0]
        SRCA_RS1  = 2'b00,
        SRCA_PC   = 2'b01,
        SRCA_ZERO = 2'b10;

    // result_src select
    localparam logic [1:0]
        RES_ALU = 2'b00,
        RES_MEM = 2'b01,
        RES_PC4 = 2'b10;

    // ------------------------------------------------------------------
    // main decoder
    // ------------------------------------------------------------------
    always_comb begin
        // NOP-safe defaults: no register or memory writes
        reg_write  = 1'b0;
        imm_src    = IMM_I;
        alu_src_a  = SRCA_RS1;
        alu_src_b  = 1'b0;
        mem_write  = 1'b0;
        result_src = RES_ALU;
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;

        unique case (opcode)

            OPCODE_OP: begin        // R-type: rd = rs1 op rs2
                reg_write  = 1'b1;
                alu_src_a  = SRCA_RS1;
                alu_src_b  = 1'b0;  // rs2
                result_src = RES_ALU;
            end

            OPCODE_OP_IMM: begin    // I-type ALU: rd = rs1 op imm
                reg_write  = 1'b1;
                imm_src    = IMM_I;
                alu_src_a  = SRCA_RS1;
                alu_src_b  = 1'b1;  // imm
                result_src = RES_ALU;
            end

            OPCODE_LOAD: begin      // rd = mem[rs1 + imm]
                reg_write  = 1'b1;
                imm_src    = IMM_I;
                alu_src_a  = SRCA_RS1;
                alu_src_b  = 1'b1;  // address = rs1 + imm
                result_src = RES_MEM;
            end

            OPCODE_STORE: begin     // mem[rs1 + imm] = rs2
                imm_src    = IMM_S;
                alu_src_a  = SRCA_RS1;
                alu_src_b  = 1'b1;  // address = rs1 + imm
                mem_write  = 1'b1;
            end

            OPCODE_BRANCH: begin    // if (cmp) pc = pc + imm
                imm_src    = IMM_B;
                branch     = 1'b1;
                // ALU unused: branch_comparator does the compare,
                // the pc-target adder does pc + imm
            end

            OPCODE_JAL: begin       // rd = pc + 4 ; pc = pc + imm
                reg_write  = 1'b1;
                imm_src    = IMM_J;
                result_src = RES_PC4;
                jump       = 1'b1;
            end

            OPCODE_JALR: begin      // rd = pc + 4 ; pc = (rs1 + imm) & ~1
                reg_write  = 1'b1;
                imm_src    = IMM_I;
                alu_src_a  = SRCA_RS1;
                alu_src_b  = 1'b1;  // ALU computes the jump target rs1 + imm
                result_src = RES_PC4;
                jalr       = 1'b1;
            end

            OPCODE_LUI: begin       // rd = imm
                reg_write  = 1'b1;
                imm_src    = IMM_U;
                alu_src_a  = SRCA_ZERO;
                alu_src_b  = 1'b1;  // 0 + imm
                result_src = RES_ALU;
            end

            OPCODE_AUIPC: begin     // rd = pc + imm
                reg_write  = 1'b1;
                imm_src    = IMM_U;
                alu_src_a  = SRCA_PC;
                alu_src_b  = 1'b1;  // pc + imm
                result_src = RES_ALU;
            end

            OPCODE_FENCE:  ; // NOP for a single-cycle core (defaults)
            OPCODE_SYSTEM: ; // ecall/ebreak: NOP here (defaults, no writes)
            default:       ; // illegal / unimplemented: NOP (defaults)

        endcase
    end

    // ------------------------------------------------------------------
    // ALU decoder section
    //
    // funct7[5] distinguishes ADD/SUB and SRL/SRA. It is only a real
    // funct field for R-type ops and for the two shift-right immediates;
    // for ADDI (OP_IMM, funct3=000) those bits belong to the immediate,
    // so we never turn ADDI into SUB.
    // ------------------------------------------------------------------
    always_comb begin
        unique case (opcode)

            OPCODE_OP: begin        // R-type
                unique case (funct3)
                    3'b000:  alu_op = funct7b5 ? ALU_SUB : ALU_ADD;
                    3'b001:  alu_op = ALU_SLL;
                    3'b010:  alu_op = ALU_SLT;
                    3'b011:  alu_op = ALU_SLTU;
                    3'b100:  alu_op = ALU_XOR;
                    3'b101:  alu_op = funct7b5 ? ALU_SRA : ALU_SRL;
                    3'b110:  alu_op = ALU_OR;
                    3'b111:  alu_op = ALU_AND;
                endcase
            end

            OPCODE_OP_IMM: begin    // I-type ALU
                unique case (funct3)
                    3'b000:  alu_op = ALU_ADD;   // ADDI (funct7 is immediate)
                    3'b001:  alu_op = ALU_SLL;   // SLLI
                    3'b010:  alu_op = ALU_SLT;   // SLTI
                    3'b011:  alu_op = ALU_SLTU;  // SLTIU
                    3'b100:  alu_op = ALU_XOR;   // XORI
                    3'b101:  alu_op = funct7b5 ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    3'b110:  alu_op = ALU_OR;    // ORI
                    3'b111:  alu_op = ALU_AND;   // ANDI
                endcase
            end

            // loads, stores, lui, auipc, jalr, jal all need an add
            default: alu_op = ALU_ADD;

        endcase
    end

endmodule
