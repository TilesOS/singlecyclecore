module control_unit (
    input [6:0] opcode,
    output 

);

    always_comb begin
        // default signals
        RegWrite  = 1'b0;
        ImmSrc    = 3'b000;
        ALUSrc    = 1'b0;
        MemRead   = 1'b0;
        MemWrite  = 1'b0;
        ResultSrc = 2'b00;
        Branch    = 1'b0;
        Jump      = 1'b0;
        ALUOp     = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin // I-type
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ImmSrc   = 3'b000;
                ALUOp    = 2'b10;
            end
            7'b0000011: begin // Load codes
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                
            end
            7'b0100011: begin // Store codes
            end
            7'b1100011: begin // Branch codes
            end
            7'b1101111: begin // Jump and Link
            end
            7'b1100111: begin // Jump and Link Reg
            end
            7'b0110111: begin // Load Upper Imm
            end
            7'b0010111: begin // Add Upper Imm to PC
            end
            7'b1110011: begin // Env Codes
            end
        endcase
    end
endmodule
