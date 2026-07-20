`timescale 1ns / 1ps
//===================================================
// Module: clock_divider
// Description: Generates a single-cycle synchronous pulse 
//              every (CLK_IN_FREQ/frequency) clock cycles.
//              Pure hardware implementation with:
//              - Continuous frequency division
//              - Cycle-accurate pulse generation
//              - Automatic counter reset
//
// Key Properties:
//  - Output: 1-clock-wide pulse at target frequency
//  - Timing: Perfectly synchronous to clk_in
//  - Resources: 32-bit counter + division circuit
//
// Example:
//  @100MHz input, frequency=1_000_000: 
//  - count_max = 100_000_000 / 1_000_000 = 100
//  - Pulses when counter=99 (every 100 cycles)
//  - Result: 1MHz pulse train (1 pulse every 100ns)
//===================================================

module clock_divider#(
    parameter CLK_IN_FREQ = 100_000_000  // Default: 100 MHz
)(
    output reg pulse_out = 0,            // Single-cycle pulse output
    input [31:0] frequency,              // Desired output frequency (Hz)
    input wire clk_in                    // Reference clock input
);

//-------------- Internal Registers -------------- 
    // Calculate how many clock cycles to count between pulses
    // Note: Division happens continuously but synthesis tools will optimize it
    wire [31:0] count_max = CLK_IN_FREQ / frequency;

    // Main counter (32-bit unsigned)
    reg [31:0] counter = 0;

//-------------- Pulse Generation Logic --------------
    always @(posedge clk_in) begin
        // Generate pulse when counter reaches max-1
        // This creates a clean 1-clock-cycle-wide pulse exactly when needed
        pulse_out <= (counter == count_max - 1);
        
        // Counter control logic:
        // - Reset to 0 when we just pulsed (pulse_out == 1)
        // - Otherwise keep counting up
        // The ternary operator implements this decision efficiently
        counter <= pulse_out ? 0 : counter + 1;
    end

endmodule
