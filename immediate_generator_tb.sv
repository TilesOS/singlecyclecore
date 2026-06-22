`timescale 1ns/1ps

module immediate_generator_tb;

    import immediate_type_pkg::*;

    logic [31:0] instr;
    imm_type_t   imm_type;
    logic [31:0] imm;

    int errors;

    immediate_generator dut (
        .instr(instr),
        .imm_type(imm_type),
        .imm(imm)
    );

    task automatic check (
        input logic [31:0] instruction,
        input imm_type_t   itype,
        input logic [31:0] expected,
        input string       tag
    );
        begin
            instr    = instruction;
            imm_type = itype;
            #1;

            if (imm !== expected) begin
                errors++;
                $display("Error [%s] instr=%h type=%s got=%h expected=%h",
                         tag, instruction, itype.name(), imm, expected);
            end
        end
    endtask

    // helper: build an I-type instruction with a given 12-bit immediate
    // format: imm[11:0] | rs1 | funct3 | rd | opcode
    function automatic logic [31:0] build_i (input logic [11:0] imm12);
        return {imm12, 5'd0, 3'd0, 5'd0, 7'd0};
    endfunction

    // helper: build an S-type instruction with a given 12-bit immediate
    // format: imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode
    function automatic logic [31:0] build_s (input logic [11:0] imm12);
        return {imm12[11:5], 5'd0, 5'd0, 3'd0, imm12[4:0], 7'd0};
    endfunction

    // helper: build a B-type instruction with a given 13-bit immediate
    // format: imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode
    function automatic logic [31:0] build_b (input logic [12:0] imm13);
        return {imm13[12], imm13[10:5], 5'd0, 5'd0, 3'd0, imm13[4:1], imm13[11], 7'd0};
    endfunction

    // helper: build a U-type instruction with a given upper 20-bit value
    // format: imm[31:12] | rd | opcode
    function automatic logic [31:0] build_u (input logic [19:0] imm20);
        return {imm20, 5'd0, 7'd0};
    endfunction

    // helper: build a J-type instruction with a given 21-bit immediate
    // format: imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode
    function automatic logic [31:0] build_j (input logic [20:0] imm21);
        return {imm21[20], imm21[10:1], imm21[11], imm21[19:12], 5'd0, 7'd0};
    endfunction

    initial begin
        errors = 0;

        // I-type immediate tests

        // positive value: imm = 100 = 12'h064
        check(build_i(12'h064), IMM_I, 32'h0000_0064, "i-pos-100");

        // negative value: imm = -1 = 12'hFFF
        check(build_i(12'hFFF), IMM_I, 32'hFFFF_FFFF, "i-neg-1");

        // zero
        check(build_i(12'h000), IMM_I, 32'h0000_0000, "i-zero");

        // max positive: 2047 = 12'h7FF
        check(build_i(12'h7FF), IMM_I, 32'h0000_07FF, "i-max-pos");

        // min negative: -2048 = 12'h800
        check(build_i(12'h800), IMM_I, 32'hFFFFF800, "i-min-neg");

        // S-type immediate tests

        check(build_s(12'h064), IMM_S, 32'h0000_0064, "s-pos-100");
        check(build_s(12'hFFF), IMM_S, 32'hFFFF_FFFF, "s-neg-1");
        check(build_s(12'h000), IMM_S, 32'h0000_0000, "s-zero");
        check(build_s(12'h7FF), IMM_S, 32'h0000_07FF, "s-max-pos");

        // B-type immediate tests
        // imm is 13-bit, bit[0] is always 0 (half-word aligned)

        // +8: 13'b0_0000_0001_000 = 13'h008
        check(build_b(13'h008), IMM_B, 32'h0000_0008, "b-pos-8");

        // -8: 13'b1_1111_1111_000 = 13'h1FF8
        check(build_b(13'h1FF8), IMM_B, 32'hFFFF_FFF8, "b-neg-8");

        // zero
        check(build_b(13'h000), IMM_B, 32'h0000_0000, "b-zero");

        // max positive: +4094 = 13'h0FFE
        check(build_b(13'h0FFE), IMM_B, 32'h0000_0FFE, "b-max-pos");

        // U-type immediate tests
        // upper 20 bits, lower 12 zeroed

        check(build_u(20'h12345), IMM_U, 32'h12345000, "u-arbitrary");
        check(build_u(20'h00000), IMM_U, 32'h0000_0000, "u-zero");
        check(build_u(20'hFFFFF), IMM_U, 32'hFFFFF000, "u-all-ones");
        check(build_u(20'h80000), IMM_U, 32'h80000000, "u-msb");

        // J-type immediate tests
        // imm is 21-bit, bit[0] is always 0

        // +8: 21'h008
        check(build_j(21'h008), IMM_J, 32'h0000_0008, "j-pos-8");

        // -4: 21'h1FFFFC
        check(build_j(21'h1FFFFC), IMM_J, 32'hFFFF_FFFC, "j-neg-4");

        // zero
        check(build_j(21'h000000), IMM_J, 32'h0000_0000, "j-zero");

        // summary
        if (errors == 0)
            $display("PASS: all immediate_generator tests passed.");
        else
            $display("FAIL: %0d error(s).", errors);

        $finish;
    end

endmodule
