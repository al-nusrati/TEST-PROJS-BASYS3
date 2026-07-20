`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2025 04:24:33 PM
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer (
    input clk,           // 100MHz clock
    input button_in,     // Raw button input
    output reg button_out // Debounced button output
);
    // Counter for 25ms debounce at 100MHz
    // 100,000,000 Hz * 0.025 sec = 2,500,000 cycles
    // Need 22 bits (2^22 = 4,194,304 > 2,500,000)
    reg [21:0] counter;  // 22-bit counter for 25ms debounce
    
    always @(posedge clk) begin
        if (button_in != button_out) begin
            counter <= counter + 1;
            // Check if counter reached 2,500,000 - 1 (0 to 2,499,999)
            if (counter == 22'd2_499_999) begin
                button_out <= button_in;
            end
        end else begin
            counter <= 0;
        end
    end
endmodule