//===================================================  
// Module: AND Gate  
// Description: 2-input AND gate
//===================================================  
module AND(
   output wire LED,
   input [1:0] SW
);

   //-------------- Logic Implementation --------------
   assign LED = SW[1] & SW[0];  // AND of both switches

endmodule