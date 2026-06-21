module immediate_generator
    import immediate_type_pkg::*;
(
    input  logic [31:0] instr,
    input  imm_type_t   imm_type,
    output logic [31:0] imm
);

    logic [11:0] imm_i_raw;
    logic [11:0] imm_s_raw;
    logic [12:0] imm_b_raw;
    logic [20:0] imm_j_raw;

    logic [31:0] imm_i_ext;
    logic [31:0] imm_s_ext;
    logic [31:0] imm_b_ext;
    logic [31:0] imm_j_ext;
    logic [31:0] imm_u;

    // I-type immediate:
    // instr[31:20]
    assign imm_i_raw = instr[31:20];

    // S-type immediate:
    // instr[31:25] and instr[11:7]
    assign imm_s_raw = {instr[31:25], instr[11:7]};

    // B-type immediate:
    // {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
    // The final 1'b0 is included here, so the output is already the branch offset.
    assign imm_b_raw = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    // U-type immediate:
    // instr[31:12] followed by 12 zeros
    assign imm_u = {instr[31:12], 12'b0};

    // J-type immediate:
    // {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}
    // The final 1'b0 is included here, so the output is already the jump offset.
    assign imm_j_raw = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    // Use separate sign extender modules
    sign_extender # (
        .IN_WIDTH(12),
        .OUT_WIDTH(32)
    ) sign_ext_i (
        .in (imm_i_raw),
        .out(imm_i_ext)
    );

    sign_extender # (
        .IN_WIDTH(12),
        .OUT_WIDTH(32)
    ) sign_ext_s (
        .in (imm_s_raw),
        .out(imm_s_ext)
    );

    sign_extender # (
        .IN_WIDTH(13),
        .OUT_WIDTH(32)
    ) sign_ext_b (
        .in (imm_b_raw),
        .out(imm_b_ext)
    );

    sign_extender # (
        .IN_WIDTH(21),
        .OUT_WIDTH(32)
    ) sign_ext_j (
        .in (imm_j_raw),
        .out(imm_j_ext)
    );

    always_comb begin
        unique case (imm_type)

            IMM_I: begin
                imm = imm_i_ext;
            end

            IMM_S: begin
                imm = imm_s_ext;
            end

            IMM_B: begin
                imm = imm_b_ext;
            end

            IMM_U: begin
                imm = imm_u;
            end

            IMM_J: begin
                imm = imm_j_ext;
            end

            default: begin
                imm = 32'b0;
            end

        endcase
    end

endmodule
