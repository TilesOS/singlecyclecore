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




    endmodule
