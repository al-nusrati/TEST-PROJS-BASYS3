`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 08:39:49 PM
// Design Name: Coordinate System Module for 96x64 OLED Display
// Module Name: coordinate_system
// Project Name: 
// Target Devices: Digilent OLED 96x64 pixels
// Tool Versions: 
// Description: 
//      Input:
//          pixel_index - 13-bit input (covers 0-6143 for 96x64)
//      Outputs:
//          x - 8-bit Horizontal coordinate (0-95)
//          y - 8-bit Vertical coordinate (0-63)
//      Operation:
//          x = pixel_index % 96  // Horizontal position (wraps every row)
//          y = pixel_index / 96  // Vertical position (increments every row)
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module coordinate_system(
        output [7:0] x,
        output [7:0] y,
        input [12:0] pixel_index
);
    assign x = pixel_index % 96;  // Column position
    assign y = pixel_index / 96;  // Row position
endmodule

