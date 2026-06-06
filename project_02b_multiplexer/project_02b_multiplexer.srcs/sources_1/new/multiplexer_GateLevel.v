//===================================================
// Module: multiplex_GateLevel
// Description: 2-to-1 multiplexer using Gate Level modeling
//  Code Style:     Uses and, or, not gates
//  Execution Type: Structural (Manual Gate Instantiation)
//  How it works:   Directly models physical gates.
//===================================================

module multiplexer_GateLevel(
    input wire a, b, sel,
    output wire out1
);

    wire not_sel, and1_out, and2_out;

    not (not_sel, sel);
    and (and1_out, a, not_sel);
    and (and2_out, b, sel);
    or  (out1, and1_out, and2_out);

endmodule