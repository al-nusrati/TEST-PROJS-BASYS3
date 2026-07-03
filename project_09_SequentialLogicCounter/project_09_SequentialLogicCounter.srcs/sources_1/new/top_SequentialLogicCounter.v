//===================================================  
// Module: top_SequentialLogicCounter  
// Description:  
//   - Implements a simple 4-bit counter with debounced input buttons for counting and reset functionality.  
//   - The counter is incremented by pressing the count button (BTNC) and reset by pressing the reset button (BTNU).  
//   - The counter state is displayed on the 4 LEDs.  
//   - Debouncers are used to ensure stable and noise-free inputs from the buttons.  
//   - A pulse is generated for each button press, ensuring the counter increments only once per press.  
//   - The reset button resets the counter to zero on press.  
//  
// Inputs:  
//   - clk: System clock (100 MHz on BASYS3).  
//   - BTNC: Noisy count button input.  
//   - BTNU: Noisy reset button input.  
//  
// Outputs:  
//   - LEDs: 4-bit counter state displayed on LEDs.  
//  
// Usage:  
//   - Press the count button to increment the counter.  
//   - Press the reset button to reset the counter to zero.  
//===================================================
module top_SequentialLogicCounter(
    output [3:0] LEDs,      // 4 LEDs to show the count (0-15)
    input clk,              // Clock signal (like a heartbeat)
    input BTNC,             // Center button (noisy/bouncy)
    input BTNU             // Up button for reset (noisy/bouncy)
);
    //-------------- Debouncers --------------
    wire count_clean, reset_clean;  // Clean button signals (no bounce)
    Debouncer db_cnt(count_clean, clk, BTNC);  // Makes count button stable
    Debouncer db_rst(reset_clean, clk, BTNU);  // Makes reset button stable
    
    //-------------- Logic Implementation --------------
    // My counter - This holds our count value (0 to 15)
    reg [3:0] counter = 0;

    always @(posedge clk) begin
        if (reset_clean)                    // If reset button pressed
            counter <= 0;                   // Go back to 0
        else if (count_clean)               // If count button pressed
            counter <= counter + 1;         // Add 1 to count
    end

    assign LEDs = counter;
endmodule // top_SequentialLogicCounter