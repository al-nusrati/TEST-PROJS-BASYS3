`timescale 1ns / 1ps
//=========================================================
// Top Module: Top_CipherX8
// Description: 
//  - Takes two 8-bit inputs (A and B) from 16 switches
//  - XORs A and B to check against a predefined 8-bit password
//  - If password matches, all LEDs are turned ON
//  - If password doesn't match or button is not pressed, LEDs are turned OFF
//  - LEDs are updated based on XOR result when the btnC is pressed
//  - 7-segment display anodes are turned off
//
// Inputs:
//  - sw[15:0] : Switches (lower 8 bits for A, upper 8 bits for B)
//  - btnC     : Button to trigger password checking (U18)
//  - clk      : Clock input
//
// Outputs:
//  - led[15:0]: LEDs displaying status based on XOR result
//  - an[3:0]  : 7-segment anodes (all turned off)
//=========================================================

module Top_CipherX8(
    // ---------- Inputs ----------
    input [15:0] sw,        // 8 switches for input
    input btnC,             // Button for checking password
    input clk,               // Clock input
    // ---------- Outputs ----------
    output reg [15:0] led,  // LEDs to show output (must be reg for procedural assignment)
    output wire [3:0] an   // Anodes of 7-segment display
);

    // ---------- Internal Declarations ----------
    wire [7:0] A = sw[7:0];             // 8-bit input A (lower 8 switches)
    wire [7:0] B = sw[15:8];            // 8-bit input B (upper 8 switches)
    wire [7:0] password = 8'b00001111;  // Predefined password for XOR check

    // ---------- Logic Implementation ----------
    // XOR PasswordCheck Logic (on btnC press)
    always @(posedge clk) begin
        if (btnC) begin     // Detect btnC pressed (high)

            if ((A ^ B) == password) begin
                led <= 16'b1111111111111111;  // Turn on all LEDs if correct
            end else begin
                led <= 16'b0000000000000000;  // Turn off all LEDs if incorrect
            end
        
        end else begin
            led <= 16'b0000000000000000;      // Turn off all LEDs when btnC is not pressed
        end
    end


    // ---------- Turn off all 7-segment ----------
    assign an = 4'b1111;

endmodule // Top_CipherX8