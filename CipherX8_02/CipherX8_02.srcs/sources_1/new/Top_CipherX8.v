`timescale 1ns / 1ps
//=========================================================
// Top Module: Top_CipherX8
// Description: 
//  - Takes two 8-bit inputs (A and B) from 16 switches
//  - XORs A and B to check against a predefined 8-bit password
//  - When the center button (btnC) is pressed:
//      - If the XOR result matches the password, a 3-LED "Knight Rider" pattern is displayed
//      - If the XOR result does not match, all LEDs remain OFF
//  - If the button is not pressed, all LEDs remain OFF
//  - Knight Rider logic moves a 3-LED block left and right based on position and direction
//  - 7-segment display anodes are always turned OFF
//
// Inputs:
//  - sw[15:0] : Switches (lower 8 bits for A, upper 8 bits for B)
//  - btnC     : Center button to trigger password checking
//  - clk      : System clock input
//
// Outputs:
//  - led[15:0]: LEDs displaying Knight Rider pattern when password matches
//  - an[3:0]  : 7-segment display anodes (all turned OFF)
//=========================================================


module Top_CipherX8(
    // ---------- Outputs ----------
    output reg [15:0] led,  // LEDs to show output (must be reg for procedural assignment)
    output wire [3:0] an,   // Anodes of 7-segment display
    // ---------- Inputs ----------
    input [15:0] sw,        // 8 switches for input
    input btnC,             // Button for checking password
    input clk               // Clock input
    );

    // ---------- Internal Declarations ----------
    wire [7:0] A = sw[7:0];           // 8-bit input A (lower 8 switches)
    wire [7:0] B = sw[15:8];          // 8-bit input B (upper 8 switches)
    reg [7:0] password = 8'b00011110; // Predefined password for XOR check

    wire [15:0] led_pattern;          // LED pattern from Knight Rider module

    //-------------- Custom Clocks (pulses) --------------
    wire clk8;          // Slower clock (8 Hz) for visible Knight Rider animation
    clock_divider pulse_20 (.pulse_out(clk8), .frequency(8), .clk_in(clk));

    //-------------- Instantiate the Knight Rider logic --------------
    KnightRider knight_rider (
        .led_pattern(led_pattern),
        .clk_KR(clk8)
    );

    //=========================================================
    // ---------- Password Check and LEDs Update ---------
      always @(posedge clk) begin
         if (btnC) begin                    // Button pressed?
            if ((A ^ B) == password) begin // Password correct?
                  led <= led_pattern;        // Show Knight Rider
            end else begin
                  led <= 16'b0;             // Wrong password = no LEDs
            end
         end else begin
            led <= 16'b0;                 // No button = no LEDs
         end
      end
    //=========================================================

    // ---------- Turn off all 7-segments ----------
    assign an = 4'b1111;

endmodule // Top_CipherX8




module KnightRider(
    output reg [15:0] led_pattern,  // The updated LED pattern
    input clk_KR                    // Clock for Knight Rider movement
    );

    // Internal registers for position and direction
    reg [3:0] position = 4'b0000;   // Current position of the LED group
    reg direction = 0;              // Direction of movement: 0 = left to right, 1 = right to left

    // Knight Rider movement logic (position and direction control)
    always @(posedge clk_KR) begin
        // Knight Rider movement logic (position and direction control)

        // FIRST CLEAR ALL LEDs
        led_pattern <= 16'b0;
        
        // THEN Update position and direction
         if (direction == 0) begin           // Moving RIGHT
            if (position == 13) begin       // Hit the right wall?
               direction <= 1;             // Change to LEFT
               position <= position - 1;   // Move left one step
            end else begin
               position <= position + 1;   // Keep moving right
            end
         end else if (direction == 1) begin  // Moving LEFT
            if (position == 0) begin        // Hit the left wall?
               direction <= 0;             // Change to RIGHT
               position <= position + 1;   // Move right one step
            end else begin
               position <= position - 1;   // Keep moving left
            end
         end

        // FINALLY Set 3 LEDs from 'position'
        led_pattern[position +: 3] <= 3'b111;  // Turn on 3 LEDs starting at 'position'

    end
endmodule


