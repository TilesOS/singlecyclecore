`timescale 1ns/1ps

module sign_extender_tb;

    localparam int IN_WIDTH  = 12;
    localparam int OUT_WIDTH = 32;

    logic [IN_WIDTH-1:0]  in;
    logic [OUT_WIDTH-1:0] out;

    int errors;

    sign_extender # (
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .in (in),
        .out(out)
    );

    task automatic check (
        input logic [IN_WIDTH-1:0]  in_val,
        input logic [OUT_WIDTH-1:0] expected,
        input string tag
    );
        begin
            in = in_val;
            #1;

            if (out !== expected) begin
                errors++;
                $display("Error [%s] in=%h got=%h expected=%h",
                         tag, in_val, out, expected);
            end
        end
    endtask

    initial begin
        errors = 0;

        // test 1zero input
        check(12'h000, 32'h0000_0000, "zero");

        // test positive value (MSB = 0)
        check(12'h7FF, 32'h0000_07FF, "max-positive");

        // test negative value (MSB = 1)
        check(12'h800, 32'hFFFFF800, "min-negative");

        // test all ones
        check(12'hFFF, 32'hFFFF_FFFF, "all-ones");

        // test small positive
        check(12'h001, 32'h0000_0001, "one");

        // test arbitrary negative
        check(12'hFEC, 32'hFFFF_FFEC, "neg-20");

        // test arbitrary positive
        check(12'h064, 32'h0000_0064, "pos-100");

        // summary
        if (errors == 0)
            $display("PASS: all sign_extender tests passed.");
        else
            $display("FAIL: %0d error(s).", errors);

        $finish;
    end

endmodule
