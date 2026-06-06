//===================================================
// Module: multiplex_DataFlowLevel
// Description: 2-to-1 multiplexer using Dataflow modeling
//  Code Style:     Uses assign statement
//  Execution Type: Combinational (Concurrent)
//  How it works:   Uses Boolean equations and logical operators.
//===================================================

module multiplexer_DataFlowLevel(
    input wire a, b, sel,
    output wire out1
);

    assign out1 = (sel) ? b : a;

endmodule