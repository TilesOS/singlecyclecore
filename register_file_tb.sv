`timescale 1ns/1ps

module register_file_tb;

    localparam int DATA_WIDTH = 32;
    localparam int NUM_REGS = 32;
    localparam int ADDR_WIDTH = 5;

    logic clk;
    logic rstn;

    logic [ADDR_WIDTH-1:0] rs1_addr;
    logic [DATA_WIDTH-1:0] rs1_data;

    logic [ADDR_WIDTH-1:0] rs2_addr;
    logic [DATA_WIDTH-1:0] rs2_data;

    logic we;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [DATA_WIDTH-1:0] rd_data;

    int errors;

    logic [DATA_WIDTH-1:0] model [NUM_REGS];

    register_file # (
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),

        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data),

        .we(we),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_read (
        input logic [ADDR_WIDTH-1:0] a1,
        input logic [ADDR_WIDTH-1:0] a2,
        input string tag
    );

        logic [DATA_WIDTH-1:0] expected1;
        logic [DATA_WIDTH-1:0] expected2;

        begin
            rs1_addr = a1;
            rs2_addr = a2;

            #1;

            expected1 = (a1 == '0) ? '0 : model[a1];
            expected2 = (a2 == '0) ? '0 : model[a2];

            if (rs1_data !== expected1) begin
                errors++;
                $display("Error [%s] rs1: addr=%0d got=%h expected=%h",
                         tag, a1, rs1_data, expected1);
            end

            if (rs2_data !== expected2) begin
                errors++;
                $display("Error [%s] rs2: addr=%0d got=%h expected=%h",
                         tag, a2, rs2_data, expected2);
            end
        end
    endtask

    initial begin
        errors = 0;
        we = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 0;

        for (int i = 0; i < NUM_REGS; i++) model[i] = '0;

        // assert reset
        rstn = 0;
        @(posedge clk);
        #1;

        // all registers should read zero during reset
        check_read(5'd0, 5'd1, "reset");

        // release reset
        rstn = 1;
        @(posedge clk);
        #1;

        // ------------------------------------------------
        // test 1: write then read back each register
        // ------------------------------------------------
        for (int i = 0; i < NUM_REGS; i++) begin
            we      = 1;
            rd_addr = i[ADDR_WIDTH-1:0];
            rd_data = 32'hA000_0000 + i;
            @(posedge clk);
            #1;

            if (i != 0) model[i] = 32'hA000_0000 + i;
        end
        we = 0;

        for (int i = 0; i < NUM_REGS; i++) begin
            check_read(i[ADDR_WIDTH-1:0], 5'd0, "write-readback");
        end

        // ------------------------------------------------
        // test 2: x0 is always zero (write should be ignored)
        // ------------------------------------------------
        we      = 1;
        rd_addr = 5'd0;
        rd_data = 32'hDEAD_BEEF;
        @(posedge clk);
        #1;
        we = 0;

        check_read(5'd0, 5'd0, "x0-hardwired");

        // ------------------------------------------------
        // test 3: read two different registers simultaneously
        // ------------------------------------------------
        check_read(5'd1, 5'd2, "dual-read");

        // ------------------------------------------------
        // test 4: write-enable low — register should not change
        // ------------------------------------------------
        we      = 0;
        rd_addr = 5'd3;
        rd_data = 32'hFFFF_FFFF;
        @(posedge clk);
        #1;

        check_read(5'd3, 5'd3, "we-low");

        // ------------------------------------------------
        // test 5: overwrite a register
        // ------------------------------------------------
        we      = 1;
        rd_addr = 5'd1;
        rd_data = 32'h1234_5678;
        @(posedge clk);
        #1;
        we = 0;
        model[1] = 32'h1234_5678;

        check_read(5'd1, 5'd1, "overwrite");

        // ------------------------------------------------
        // test 6: reset clears all registers
        // ------------------------------------------------
        rstn = 0;
        @(posedge clk);
        #1;

        for (int i = 0; i < NUM_REGS; i++) model[i] = '0;

        for (int i = 0; i < NUM_REGS; i++) begin
            check_read(i[ADDR_WIDTH-1:0], 5'd0, "post-reset");
        end

        rstn = 1;
        @(posedge clk);
        #1;

        // ------------------------------------------------
        // summary
        // ------------------------------------------------
        if (errors == 0)
            $display("PASS: all register_file tests passed.");
        else
            $display("FAIL: %0d error(s).", errors);

        $finish;
    end

endmodule
