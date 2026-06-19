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

    