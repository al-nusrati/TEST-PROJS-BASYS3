//===================================================  
// Module: SWLED  
// Description: Simple NOT gate implementation  
//              LED output is the inverted value of SW input
//              we assigning the anode of 7 segments to high, else they will glow in light red if left floating  
//===================================================  

module SWLED(
    output wire LED,         // **Output**: LED (Inverted state of SW)  
    input  wire SW,          // **Input**: Switch (SW) signal
    
    output wire [3:0] an     // added the anodes as outputs  
    );  

    //-------------- Logic Implementation --------------  
    not u1 (LED, SW);   // **NOT Gate**: LED = ~SW
    //assign LED = ~(~(~SW));
    assign an = 4'b1111; //assigned the anode outputs as high

endmodule // SWLED

// Make sure that the 7-segment display pins in the XDC file are not unintentionally mapped to any unused logic or left floating.
// Otherwise they may show 7 segment displays in light red color.
// https://forum.digilent.com/topic/23883-basys-3-7-segment-display-on-while-not-used-in-configuration/ 
