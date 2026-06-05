
//===================================================  
// Module: AND Gate Top Level
// Description: 2 bits input & 1 LED output
//===================================================  

module top(
   output LED,
   input [1:0] SW, 
   input wire CLK
);

   //-------------- Logic Implementation --------------
   AND and1(.SW(SW), .LED(LED));

   //-------------- Internal Signals --------------  
   /// Define wires, registers, or parameters if needed

   //-------------- Initial Block (Preload Constants) --------------

   //-------------- Always Block (Combinational Logic) --------------  
   /// - Runs whenever an input changes, ensuring instant updates.  
   /// - This is NOT a sequential block (no clock involved).
   always @(*) begin
      // No operation
   end

   //-------------- Always Block (Sequential Logic) --------------  
   /// - Runs only on clock's rising edge (posedge CLK).  
   always @(posedge CLK) begin
      // No operation
   end

endmodule
