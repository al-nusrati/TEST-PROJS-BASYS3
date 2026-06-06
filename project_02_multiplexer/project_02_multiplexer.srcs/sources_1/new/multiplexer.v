`timescale 1ns / 1ps  // **Simulation Time Unit: 1ns, Precision: 1ps**  
//===================================================  
// Module: multiplexer  
// Description: 2-to-1 Multiplexer implemented in three ways:  
//              - Gate Level
//              - Dataflow Level
//              - Behavioral Level
//===================================================  
  
module multiplexer(  
    output wire out1,   // **MUX Output (wire for all levels)**  
    input wire A,       // **MUX Input 0**  
    input wire B,       // **MUX Input 1**  
    input wire X        // **MUX Select Signal**  
);  

/*
    //-------------- Internal Signals --------------  
    wire not_X;        // **Inverted Select Signal**  
    wire out_and1;     // **Output of AND gate 1**  
    wire out_and2;     // **Output of AND gate 2**  
     
    //-------------- Gate Level Implementation --------------
    not not1(not_X, X);          // **NOT Gate: not_X = ~X**  
    and and1(out_and1, not_X, A); // **AND Gate: out_and1 = (~X & A)**  
    and and2(out_and2, X, B);     // **AND Gate: out_and2 = (X & B)**  
    or  or1(out1, out_and1, out_and2); // **OR Gate: out1 = (out_and1 | out_and2)**  
*/

/*
    //-------------- Dataflow Level Implementation / Bitwise Logic Description --------------  
    assign out1 = (~X & A) | (X & B);
*/


    //-------------- Behavioral Level Internal Reg --------------  
    reg out_beh;       // **Internal reg for Behavioral Level** 
     
    //-------------- Behavioral Level Implementation --------------  
    always @(*) begin
        if (X)
            out_beh = B;
        else
            out_beh = A;
    end

    // Connect the Behavioral output reg to the wire out1
    assign out1 = out_beh;


    // Alternative Single-Line Behavioral Implementation (commented out)
    // assign out1 = X ? B : A;

endmodule // multiplexer

/*
  Notes: In Verilog, when you use assign for assigning a value to a signal, that signal must be declared as a wire.
*/
