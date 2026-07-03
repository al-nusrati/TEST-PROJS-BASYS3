//===================================================  
// Module: SevenSegmentController  
// Description:  
//   - Converts a 4-bit input digit (0-9) into the corresponding 7-segment display segments.  
//   - Outputs the segment control signals (a-g) for a 7-segment display.  
//===================================================  

module SevenSegmentController (
    output reg [6:0] seg,   // Output 7-segment display segments (a-g)  
    input wire [3:0] digit  // Input digit (0-9) to be displayed on the 7-segment  
);

    //-------------- Segment Mapping Logic --------------  
    always @(*) begin  
        case (digit)
            4'b0000: seg = 7'b0000001; // 0  
            4'b0001: seg = 7'b1001111; // 1  
            4'b0010: seg = 7'b0010010; // 2  
            4'b0011: seg = 7'b0000110; // 3  
            4'b0100: seg = 7'b1001100; // 4  
            4'b0101: seg = 7'b0100100; // 5  
            4'b0110: seg = 7'b0100000; // 6  
            4'b0111: seg = 7'b0001111; // 7  
            4'b1000: seg = 7'b0000000; // 8  
            4'b1001: seg = 7'b0000100; // 9  
            default: seg = 7'b1111111; // Default: turn off all segments  
        endcase  
    end

endmodule // SevenSegmentController