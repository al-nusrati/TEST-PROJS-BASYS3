//===================================================  
// Module: finite_state_machine  
// Description: 4-state finite state machine with LED output using BTNC as clock and BTNU as reset  
//===================================================  

module finite_state_machine (
    input wire clk,     // System clock for debouncing  
    input wire BTNC,    // Button acting as clock  
    input wire BTNU,    // Button acting as reset  
    output reg [3:0] LED  // FSM state output mapped to LEDs  
);

    //-------------- Debounce Logic for BTNC --------------  
    reg BTNC_d, BTNC_trig;

    always @(posedge clk) begin
        BTNC_d <= BTNC;                    // Store previous state  
        BTNC_trig <= BTNC & ~BTNC_d;        // Detect rising edge  
    end

    //-------------- State Encoding --------------  
    parameter S_00 = 2'b00,  
              S_01 = 2'b01,  
              S_10 = 2'b10,  
              S_11 = 2'b11;

    reg [1:0] state;

    //-------------- State Transition Logic --------------  
    always @(posedge clk) begin
        if (BTNU)
            state <= S_00; // Reset to initial state  
        else if (BTNC_trig)
            state <= state + 1; // Move to next state  
    end

    //-------------- LED Output Assignment --------------  
    always @(*) begin
        case (state)
            S_00: LED = 4'b0001;  // LED0 ON  
            S_01: LED = 4'b0010;  // LED1 ON  
            S_10: LED = 4'b0100;  // LED2 ON  
            S_11: LED = 4'b1000;  // LED3 ON  
            default: LED = 4'b0000;  // Default case  
        endcase
    end

endmodule

//===================================================  
// Explanation:  
// - Implements a **4-state finite state machine (FSM)**.  
// - Uses **BTNC (push button) as input** with **debouncing**.  
// - Uses **BTNU (push button) as reset** to return to **S_00**.  
// - Cycles through states: **S_00 → S_01 → S_10 → S_11 → back to S_00**.  
// - Each state is mapped to a different LED (LED0 - LED3).  
// - Transitions occur when **BTNC is pressed** after debouncing.  
// - The **LED output changes based on the current state**.  
//===================================================
