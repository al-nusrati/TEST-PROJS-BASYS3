//===================================================
// Module: multiplexer
// Description: Master module integrating three MUX implementations
//===================================================

module multiplexer(
    input wire A, B, SEL,       // Inputs for the multiplexer
    output wire led_gate,       // Output from Gate-Level MUX
    output wire led_data,       // Output from Dataflow-Level MUX
    output wire led_behavioral  // Output from Behavioral-Level MUX
);

    //--------------- Module Instantiations ---------------
    // Each of the three multiplexers is instantiated and connected.
    // Positional port mapping
    
    // **Gate-Level Multiplexer**
    multiplexer_GateLevel CUT1 (A, B, SEL, led_gate);

    // **Dataflow-Level Multiplexer**
    multiplexer_DataFlowLevel CUT2 ( A, B, SEL, led_data );
    
    // **Behavioral-Level Multiplexer**
    multiplexer_BehavioralLevel CUT3 ( A, B, SEL, led_behavioral);

endmodule