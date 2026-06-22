`timescale 1ns/1ps

module branch_comparator_tb;

    import branch_pkg::*;

    localparam int DATA_WIDTH = 32;

    logic [DATA_WIDTH-1:0] rs1_data;
    logic [DATA_WIDTH-1:0] rs2_data;
    branch_op_t            branch_op;
    logic                  branch_taken;

    int errors;

    branch_comparator # (
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .branch_op(branch_op),
        .branch_taken(branch_taken)
    );

    task automatic check (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        input branch_op_t            op,
        input logic                  expected,
        input string                 tag
    );
        begin
            rs1_data  = a;
            rs2_data  = b;
            branch_op = op;
            #1;

            if (branch_taken !== expected) begin
                errors++;
                $display("Error [%s] rs1=%h rs2=%h op=%s got=%b expected=%b",
                         tag, a, b, op.name(), branch_taken, expected);
            end
        end
    endtask

    initial begin
        errors = 0;

        // ------------------------------------------------
        // BEQ
        // ------------------------------------------------
        check(32'd10, 32'd10, BR_BEQ, 1'b1, "beq-equal");
        check(32'd10, 32'd20, BR_BEQ, 1'b0, "beq-not-equal");

        // ------------------------------------------------
        // BNE
        // ------------------------------------------------
        check(32'd10, 32'd20, BR_BNE, 1'b1, "bne-not-equal");
        check(32'd10, 32'd10, BR_BNE, 1'b0, "bne-equal");

        // ------------------------------------------------
        // BLT (signed)
        // ------------------------------------------------
        check(32'hFFFF_FFFF, 32'd0, BR_BLT, 1'b1, "blt-neg-vs-zero");
        check(32'd0, 32'hFFFF_FFFF, BR_BLT, 1'b0, "blt-zero-vs-neg");
        check(32'd5,  32'd10, BR_BLT, 1'b1, "blt-less");
        check(32'd10, 32'd10, BR_BLT, 1'b0, "blt-equal");
        check(32'd10, 32'd5,  BR_BLT, 1'b0, "blt-greater");

        // ------------------------------------------------
        // BGE (signed)
        // ------------------------------------------------
        check(32'd10, 32'd10, BR_BGE, 1'b1, "bge-equal");
        check(32'd10, 32'd5,  BR_BGE, 1'b1, "bge-greater");
        check(32'd5,  32'd10, BR_BGE, 1'b0, "bge-less");
        check(32'hFFFF_FFFF, 32'd0, BR_BGE, 1'b0, "bge-neg-vs-zero");
        check(32'd0, 32'hFFFF_FFFF, BR_BGE, 1'b1, "bge-zero-vs-neg");

        // ------------------------------------------------
        // BLTU (unsigned)
        // ------------------------------------------------
        check(32'd5,  32'd10, BR_BLTU, 1'b1, "bltu-less");
        check(32'd10, 32'd10, BR_BLTU, 1'b0, "bltu-equal");
        check(32'd10, 32'd5,  BR_BLTU, 1'b0, "bltu-greater");
        // 0xFFFFFFFF is a large unsigned value, not negative
        check(32'd0, 32'hFFFF_FFFF, BR_BLTU, 1'b1, "bltu-zero-vs-max");
        check(32'hFFFF_FFFF, 32'd0, BR_BLTU, 1'b0, "bltu-max-vs-zero");

        // ------------------------------------------------
        // BGEU (unsigned)
        // ------------------------------------------------
        check(32'd10, 32'd10, BR_BGEU, 1'b1, "bgeu-equal");
        check(32'd10, 32'd5,  BR_BGEU, 1'b1, "bgeu-greater");
        check(32'd5,  32'd10, BR_BGEU, 1'b0, "bgeu-less");
        check(32'hFFFF_FFFF, 32'd0, BR_BGEU, 1'b1, "bgeu-max-vs-zero");
        check(32'd0, 32'hFFFF_FFFF, BR_BGEU, 1'b0, "bgeu-zero-vs-max");

        // ------------------------------------------------
        // summary
        // ------------------------------------------------
        if (errors == 0)
            $display("PASS: all branch_comparator tests passed.");
        else
            $display("FAIL: %0d error(s).", errors);

        $finish;
    end

endmodule
