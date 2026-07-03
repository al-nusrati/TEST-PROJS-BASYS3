// =============================================
// Minimal Button Debouncer
// - noisy_signal → clean_signal
// - 20ms debounce at 100MHz (for BASYS3)
// - Outputs 1-clock pulse on clean press
// =============================================
module Debouncer ( 
    output clean_signal, // Debounced pulse - Clean single pulse when button pressed
    input clk,           // System CLK, 100 MHz 
    input noisy_signal   // Raw, bouncy button input
);
    
    //-------------- Reg Declaration --------------
    reg [17:0] count = 0;   // 20ms counter (200_000 cycles @ 100MHz) 
    reg stable = 0;         // Stable state storage 
    reg last_stable = 0;    // Last stable state (for edge detection) 
    
    //-------------- Logic Implementation --------------
    // Debounce Process: When the button changes, reset the 20ms timer (counter)
    //                   Only accept the changes if it stays constant for 20ms
    // Main idea: Only trust the button state if it stays the same for 20ms
    always @(posedge clk) begin
        if (noisy_signal != stable) begin  // Detect ANY change 
            count = 0;                     // Reset counter (use blocking assignment)
            stable = noisy_signal;         // Remember new state
        end 
        else if (count < 199_999) begin    // Wait 20ms 
            count = count + 1;             // Increment counter 
        end
    end
    
    //-------------- Rising Edge Detection --------------
    // Create a single pulse when button goes from off to on
    always @(posedge clk) last_stable <= stable;
    assign clean_signal = stable & ~last_stable;  // Generate PULSE when stable goes high
endmodule