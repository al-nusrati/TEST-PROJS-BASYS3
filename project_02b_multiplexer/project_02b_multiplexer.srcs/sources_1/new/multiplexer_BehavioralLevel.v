//===================================================
// Module: multiplex_BehavioralLevel
// Description: 2-to-1 multiplexer using Behavioral modeling
//  Code Style:     Uses always @(*) block
//  Execution Type: Sequential (Procedural) but still Combinational
//  How it works:   Uses conditional statements (if, case) to infer logic.
//===================================================

module multiplexer_BehavioralLevel(
    input wire a, b, sel,
    output wire out1
);

    reg out_reg;  // Intermediate reg for always block

    always @(*) begin       // always @(*) -> it triggers on any change in its input signals 
        if (sel)
            out_reg = b;
        else
            out_reg = a;
    end

    assign out1 = out_reg;  // Assign reg to wire output

endmodule