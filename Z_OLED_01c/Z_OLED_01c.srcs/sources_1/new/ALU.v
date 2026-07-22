`timescale 1ns / 1ps
//===================================================
// Module: ALU (Arithmetic Logic Unit)
// Description: 8-bit ALU with support for gate-level AND,
//              dataflow OR, behavioral XOR, ADD, and SUB.
//              First operation (Op_NOP) is a no-op.
//===================================================

// Note: wire / reg type only matters for the output
module ALU(
    output wire [7:0] Result,   // 8-bit result output  (wire / reg type only matters for the output)

    input       [7:0] A,        // 8-bit input A        (inputs are always treated as wires)
    input       [7:0] B,        // 8-bit input B
    input       [3:0] OpSelect  // 4-bit operation selection input
);

    // ---------- Parameters ----------
    parameter Op_NOP = 4'b0000;  // No operation
    parameter Op_AND = 4'b0001;
    parameter Op_OR  = 4'b0010;
    parameter Op_XOR = 4'b0011;
    parameter Op_ADD = 4'b0100;
    parameter Op_SUB = 4'b0101;


    // ========== ALU Control logic (Procedural Block) ==========
    reg [7:0] result_reg;
    always @(*) begin
        case (OpSelect)
            Op_NOP: begin
                result_reg = 8'h00;       // No operation
            end
            Op_AND: begin
                result_reg = A & B;       // AND operation (bitwise)
            end
            Op_OR: begin
                result_reg = A | B;       // OR operation (bitwise)
            end
            Op_XOR: begin
                result_reg = A ^ B;       // XOR operation (bitwise)
            end
            Op_ADD: begin
                result_reg = A + B;       // Addition (bitwise, with carry)
            end
            Op_SUB: begin
                result_reg = A - B;       // Subtraction (bitwise, with borrow)
            end
            // default: begin
            //     result_reg = 8'h00;       // Default case safety
            // end
        endcase
    end


// ========== Final Assignments ==========
    assign Result = result_reg;

endmodule // ALU