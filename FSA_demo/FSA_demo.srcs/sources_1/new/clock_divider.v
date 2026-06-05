//==============================================================
// Clock Divider with Enable Pulse (Compact Style)
//--------------------------------------------------------------
// Generates a 1-cycle pulse at desired frequency from clk_in
// Example: 100 MHz → 6.25 MHz (pulse every 16 cycles)
//==============================================================

module clock_divider#(
    parameter CLK_IN_FREQ = 100_000_000 // Default: 100 MHz
)(
    output reg pulse_out = 0,           // Single-cycle pulse output
    input basys_clock,                  // Reference clock input
    input [31:0] frequency              // Desired output frequency (Hz)
);

    wire [31:0] count_max = CLK_IN_FREQ / frequency;
    reg [31:0] counter = 0;             // Main counter (32-bit unsigned)

//-------------- Pulse Generation Logic --------------
    always @(posedge basys_clock) begin
        pulse_out <= (counter == count_max - 1);    // Generate pulse when counter reaches max-1
        counter <= pulse_out ? 0 : counter + 1;     // Counter control logic (Reset to 0 when we just pulsed (pulse_out == 1) otherwise keep incrementing)
    end
endmodule