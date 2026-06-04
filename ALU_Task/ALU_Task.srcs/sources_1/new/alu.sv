module alu #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [1:0]       op,
    output logic [WIDTH-1:0] result
);

    always_comb begin
        case (op)
            2'b00: result = A + B;    // add
            2'b01: result = A - B;    // sub
            2'b10: result = A & B;    // and
            2'b11: result = A | B;    // or
            default: result = '0;
        endcase
    end

endmodule