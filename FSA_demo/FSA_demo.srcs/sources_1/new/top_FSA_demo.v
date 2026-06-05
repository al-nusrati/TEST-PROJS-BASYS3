`timescale 1ns / 1ps

module FSM_demo (
    //------------- Outputs (LEDs) -------------
    output reg [4:0] led, // First 5 LEDs for state indication (0-4)
    //------------- Inputs -------------
    input clk,            // system clock (100MHz)
    input btnU,           // Button to move to next state (up)
    input btnD            // Button to move to previous state (down)
);

    //------------- Internal signals -------------
    wire oled_clk;           // 6.25 MHz clock pulse
    
    // debounced buttons
    wire btnU_debounced, btnD_debounced;
    
    // Button edge detection signals
    reg btnU_prev = 0, btnD_prev = 0;
    wire btnU_posedge, btnD_posedge;

    //==============================================================
    // Finite State Machine (FSM)
    //==============================================================

    //---------------------------
    //--- (1) State Definitions |
    //---------------------------

    // state definition - 5 states (StateA to StateE)
    localparam STATE_A = 0;
    localparam STATE_B = 1;
    localparam STATE_C = 2;
    localparam STATE_D = 3;
    localparam STATE_E = 4;
    
    // State registers - INDUSTRY STANDARD APPROACH (2 state registers)
    reg [2:0] current_state, next_state; // 3 bits for 5 states (0-4)

    // Initialize state machine
    initial begin
        current_state = STATE_A;    // Current state is State A
        next_state = STATE_A;       // Next state is also State A (no transition pending)
        led = 5'b00001;             // Initialize LED 0 on (StateA)
    end

    //--------------------------------------------
    //--- (2) Button Edge Detection (Sequential) |
    //--------------------------------------------
    always @(posedge clk) begin
        // Store previous button values for edge detection
        btnU_prev <= btnU_debounced;
        btnD_prev <= btnD_debounced;
    end

    // Edge detection assignments
    assign btnU_posedge = btnU_debounced && !btnU_prev;
    assign btnD_posedge = btnD_debounced && !btnD_prev;

    //------------------------------------------
    //--- (3) Next State Logic (Combinational) |
    //------------------------------------------
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;
        
        // State transitions based on button edges
        if (btnU_posedge) begin
            // Move to next state (forward cycle)
            case (current_state)
                STATE_A: next_state = STATE_B;
                STATE_B: next_state = STATE_C;
                STATE_C: next_state = STATE_D;
                STATE_D: next_state = STATE_E;
                STATE_E: next_state = STATE_A;
                default: next_state = STATE_A;
            endcase
        end
        else if (btnD_posedge) begin
            // Move to previous state (backward cycle)
            case (current_state)
                STATE_A: next_state = STATE_E;
                STATE_B: next_state = STATE_A;
                STATE_C: next_state = STATE_B;
                STATE_D: next_state = STATE_C;
                STATE_E: next_state = STATE_D;
                default: next_state = STATE_A;
            endcase
        end
    end

    //--------------------------------------------
    //--- (4) State Register Update (Sequential) |
    //--------------------------------------------
    always @(posedge clk) begin
        // Update current_state
        current_state <= next_state;
    end

    //-------------------------------------------------
    //--- (5) Output Logic (State-Dependent Behavior) |
    //-------------------------------------------------
    // LED control logic - One LED per state (LEDs 0-4)
    always @(*) begin
        case (current_state)
            STATE_A: led = 5'b00001; // LED 0 on
            STATE_B: led = 5'b00010; // LED 1 on
            STATE_C: led = 5'b00100; // LED 2 on
            STATE_D: led = 5'b01000; // LED 3 on
            STATE_E: led = 5'b10000; // LED 4 on
            default: led = 5'b00001; // Default to LED 0
        endcase
    end

    //============= Instantiate modules =============
    //------------- Instantiate Clock divider -------------
    clock_divider pulse_6p25m (.pulse_out(oled_clk), .basys_clock(clk), .frequency(6_250_000)); // 6.25 MHz
    
    //------------- Instantiate debouncers for buttons -------------
    debouncer debounce_up (.button_out(btnU_debounced), .button_in(btnU), .clk(clk));
    debouncer debounce_down (.button_out(btnD_debounced), .button_in(btnD), .clk(clk));
    //===============================================
   
endmodule