`timescale 1ns/1ps

module alu_tb;
    import alu_pkg::*;

    alu_op_t op;
    logic [DATA_WIDTH-1:0] a;
    logic [DATA_WIDTH-1:0] b;
    logic [DATA_WIDTH-1:0] result;
    logic [DATA_WIDTH-1:0] expected;

    int tests;
    int errors;

    alu dut (
        .op(op),
        .a(a),
        .b(b),
        .result(result)
    );

    task automatic check (
        input alu_op_t op_i,
        input logic [DATA_WIDTH-1:0] a_i,
        input logic [DATA_WIDTH-1:0] b_i,
        input logic [DATA_WIDTH-1:0] expected_i,
        input string name
    );

            op = op_i;
            a = a_i;
            b = b_i;
            expected = expected_i;

            #1;

            tests++;

            if (result !== expected_i) begin
                errors++;
                $display("Error test %0d: %-8s a=%h b=%h result=%h expected=%h",
                         tests, name, a, b, result, expected);
            end
    endtask

    initial begin
        tests = 0;
        errors = 0;

        $display("Starting ALU directed tests...");

        // ADD tests
        check(ALU_ADD, 32'd0,        32'd0,        32'd0,        "ADD");
        check(ALU_ADD, 32'd1,        32'd2,        32'd3,        "ADD");
        check(ALU_ADD, 32'hFFFF_FFFF,32'd1,        32'h0000_0000,"ADD");
        check(ALU_ADD, 32'h7FFF_FFFF,32'd1,        32'h8000_0000,"ADD");
        check(ALU_ADD, 32'h1234_5678,32'h1111_1111,32'h2345_6789,"ADD");
        check(ALU_ADD, 32'h8000_0000,32'h8000_0000,32'h0000_0000,"ADD");

        // SUB tests
        check(ALU_SUB, 32'd0,        32'd0,        32'd0,        "SUB");
        check(ALU_SUB, 32'd5,        32'd3,        32'd2,        "SUB");
        check(ALU_SUB, 32'd3,        32'd5,        32'hFFFF_FFFE,"SUB");
        check(ALU_SUB, 32'd0,        32'd1,        32'hFFFF_FFFF,"SUB");
        check(ALU_SUB, 32'h8000_0000,32'd1,        32'h7FFF_FFFF,"SUB");

        // AND tests
        check(ALU_AND, 32'h0000_0000,32'hFFFF_FFFF,32'h0000_0000,"AND");
        check(ALU_AND, 32'hFFFF_FFFF,32'hFFFF_FFFF,32'hFFFF_FFFF,"AND");
        check(ALU_AND, 32'hAAAA_AAAA,32'h5555_5555,32'h0000_0000,"AND");
        check(ALU_AND, 32'hAAAA_AAAA,32'hAAAA_AAAA,32'hAAAA_AAAA,"AND");
        check(ALU_AND, 32'h1234_5678,32'hFFFF_0000,32'h1234_0000,"AND");

        // OR tests
        check(ALU_OR,  32'h0000_0000,32'h0000_0000,32'h0000_0000, "OR");
        check(ALU_OR,  32'h0000_0000,32'hFFFF_FFFF,32'hFFFF_FFFF, "OR");
        check(ALU_OR,  32'hAAAA_AAAA,32'h5555_5555,32'hFFFF_FFFF, "OR");
        check(ALU_OR,  32'hF0F0_0000,32'h0000_0F0F,32'hF0F0_0F0F, "OR");
        check(ALU_OR,  32'h1234_0000,32'h0000_5678,32'h1234_5678, "OR");

        //XOR tests
        check(ALU_XOR, 32'h0000_0000,32'h0000_0000,32'h0000_0000,"XOR");
        check(ALU_XOR, 32'hFFFF_FFFF,32'h0000_0000,32'hFFFF_FFFF,"XOR");
        check(ALU_XOR, 32'hFFFF_FFFF,32'hFFFF_FFFF,32'h0000_0000,"XOR");
        check(ALU_XOR, 32'hAAAA_AAAA,32'h5555_5555,32'hFFFF_FFFF,"XOR");
        check(ALU_XOR, 32'h1234_5678,32'hFFFF_0000,32'hEDCB_5678,"XOR");

        // SLL tests
        check(ALU_SLL, 32'h0000_0001,32'd0,        32'h0000_0001,"SLL");
        check(ALU_SLL, 32'h0000_0001,32'd1,        32'h0000_0002,"SLL");
        check(ALU_SLL, 32'h0000_0001,32'd31,       32'h8000_0000,"SLL");
        check(ALU_SLL, 32'hF000_000F,32'd4,        32'h0000_00F0,"SLL");
        check(ALU_SLL, 32'h1234_5678,32'd8,        32'h3456_7800,"SLL");
        check(ALU_SLL, 32'h0000_0001,32'd33,       32'h0000_0002,"SLL");

        // SRL tests
        check(ALU_SRL, 32'h8000_0000,32'd0,        32'h8000_0000,"SRL");
        check(ALU_SRL, 32'h8000_0000,32'd1,        32'h4000_0000,"SRL");
        check(ALU_SRL, 32'h8000_0000,32'd31,       32'h0000_0001,"SRL");
        check(ALU_SRL, 32'hF000_0000,32'd4,        32'h0F00_0000,"SRL");
        check(ALU_SRL, 32'h1234_5678,32'd8,        32'h0012_3456,"SRL");
        check(ALU_SRL, 32'h8000_0000,32'd33,       32'h4000_0000,"SRL");

        //SRA tests
        check(ALU_SRA, 32'h8000_0000,32'd1,        32'hC000_0000,"SRA");
        check(ALU_SRA, 32'h8000_0000,32'd31,       32'hFFFF_FFFF,"SRA");
        check(ALU_SRA, 32'hFFFF_FFFF,32'd4,        32'hFFFF_FFFF,"SRA");
        check(ALU_SRA, 32'h7FFF_FFFF,32'd1,        32'h3FFF_FFFF,"SRA");
        check(ALU_SRA, 32'hF000_0000,32'd4,        32'hFF00_0000,"SRA");
        check(ALU_SRA, 32'h8000_0000,32'd33,       32'hC000_0000,"SRA");
        check(ALU_SRA, 32'hFFFF_FFFF,32'd0,        32'hFFFF_FFFF,"SRA");

        // SLT tests
        check(ALU_SLT, 32'd0,        32'd1,        32'd1,        "SLT");
        check(ALU_SLT, 32'hFFFF_FFFF,32'd1,        32'd1,        "SLT");
        check(ALU_SLT, 32'd1,        32'hFFFF_FFFF,32'd0,        "SLT");
        check(ALU_SLT, 32'h8000_0000,32'h7FFF_FFFF,32'd1,        "SLT");
        check(ALU_SLT, 32'h7FFF_FFFF,32'h8000_0000,32'd0,        "SLT");
        check(ALU_SLT, 32'd5,        32'd5,        32'd0,        "SLT");

        //SLTU tests
        check(ALU_SLTU,32'd0,        32'd1,        32'd1,       "SLTU");
        check(ALU_SLTU,32'hFFFF_FFFF,32'd0,        32'd0,       "SLTU");
        check(ALU_SLTU,32'd0,        32'hFFFF_FFFF,32'd1,       "SLTU");
        check(ALU_SLTU,32'h8000_0000,32'h7FFF_FFFF,32'd0,       "SLTU");
        check(ALU_SLTU,32'h7FFF_FFFF,32'h8000_0000,32'd1,       "SLTU");
        check(ALU_SLTU,32'd5,        32'd5,        32'd0,       "SLTU");

        // Summary
        $display("ALU tests complete.");
        $display("Errors: %0d", errors);

        if (errors == 0)
            $display("All tests passed");
        else
            $display("At least one test failed");

        $finish;
    end

endmodule
