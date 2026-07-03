//===================================================  
// Module: top_SevenSegmentDisplaying  
// Description:  
//   - Controls the 7-segment displays on the Basys 3 FPGA board.  
//   - Uses a SevenSegmentController module to drive each 7-segment display.  
//   - Manages multiplexing to show digits on multiple displays.  
//===================================================  

module top_SevenSegmentDisplaying (
    //-------------- Outputs --------------  
    output wire [6:0] seg,         // 7-segment display segments (a-g)  
    output wire [3:0] an,          // 4 anode control pins (for multiplexing)  
    //-------------- Inputs --------------  
    input wire clk,                // System clock  
    input wire [3:0] digit         // 4-bit digit to display (0-9)
);

    //-------------- Instantiate SevenSegmentController --------------  
    // This module converts a 4-bit digit into 7-segment display control signals  
    SevenSegmentController display_controller (
        .seg(seg),            // Output 7-segment display segments  
        .digit(digit)         // Input 4-bit digit to display
    );

    //-------------- Anode Control (Multiplexing) --------------  
    // Example multiplexing: Activate the first display  
    // We extend this logic to handle multiplexing between displays  
    assign an = 4'b1110;    // Display on the first display (multiplexing example)  

endmodule // top_SevenSegmentDisplaying