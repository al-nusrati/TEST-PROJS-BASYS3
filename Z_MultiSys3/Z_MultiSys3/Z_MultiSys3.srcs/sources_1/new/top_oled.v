`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2025 11:24:32 PM
// Design Name: 
// Module Name: top_oled
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

//=======================================================
// Top module for Basys3 + Pmod OLED RGB (SSD1331)
// Corrected to properly reset OLED and align JC pin mapping
//=======================================================


module top_oled (
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC, // JC[0]=cs, JC[1]=sdin, JC[3]=sclk,
                          // JC[4]=d_cn, JC[5]=resn, JC[6]=vccen, JC[7]=pmoden
                          // JC[2] unused
    //------------- Additional Outputs (LEDs) -------------
    output reg [7:0] led, // First 8 LEDs for brightness indication
    //------------- Inputs -------------
    input clk,            // system clock (100MHz)
    input btnU,           // Button to move to next state (up)
    input btnD,           // Button to move to previous state (down)
    input btnC,           // Button to toggle color channels of STATE_JAWAD (centre)
    input btnL,           // Button to increase brightness
    input btnR            // Button to decrease brightness
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire oled_clk;           // oled clk pulse
    wire clk_1; // redundant

    // oled display interface signals
    wire [12:0] pixel_index; // 13 bits for 96*64=6144 pixels (addresses: 0-6143)
    reg  [15:0] pixel_data;  // RGB565 pixel data
    wire [7:0]  x, y;        // screen coordinates

    // debounced buttons
    wire btnU_debounced, btnD_debounced, btnC_debounced, btnL_debounced, btnR_debounced;
    
    // Button edge detection signals
    reg btnU_prev = 0, btnD_prev = 0, btnC_prev = 0, btnL_prev = 0, btnR_prev = 0;
    wire btnU_posedge, btnD_posedge, btnC_posedge, btnL_posedge, btnR_posedge;

   // Rectangle parameters
    parameter RECT_X1 = 20;
    parameter RECT_Y1 = 15;
    parameter RECT_X2 = 75;
    parameter RECT_Y2 = 50;
    parameter RECT_COLOR = 16'hF800; // Red in RGB565

    // Channel mode for STATE_JAWAD (2 bits for 4 modes)
    reg [1:0] channel_mode = 2'b00; // 00=all, 01=red, 10=green, 11=blue

    // Brightness control for STATE_JAWAD2
    reg [3:0] brightness_level = 4; // 0-8: 4=center/default (4 LEDs on)
    parameter MAX_BRIGHTNESS = 8;
    parameter MIN_BRIGHTNESS = 0;
    parameter CENTER_BRIGHTNESS = 4;

    //------------- Signal Assignment -------------
    assign JC[0] = cs;    // CS
    assign JC[1] = sdin;  // MOSI (Serial Data In)
    assign JC[2] = 1'b0;  // Unused
    assign JC[3] = sclk;  // SCLK
    assign JC[4] = d_cn;  // D/C
    assign JC[5] = resn;  // RESET
    assign JC[6] = vccen; // VCC Enable
    assign JC[7] = pmoden;// PMOD Enable

    // Edge detection assignments
    assign btnU_posedge = btnU_debounced && !btnU_prev;
    assign btnD_posedge = btnD_debounced && !btnD_prev;
    assign btnC_posedge = btnC_debounced && !btnC_prev;
    assign btnL_posedge = btnL_debounced && !btnL_prev;
    assign btnR_posedge = btnR_debounced && !btnR_prev;

    //==============================================================
    // Image and Frame Buffers for 3 Images (96x64 OLED, RGB565)
    //==============================================================
    reg [15:0] img_NUST_logo [0:6143]; // NUST logo
    // reg [15:0] img_gardens   [0:6143]; // gardens
    // reg [15:0] img_zoo       [0:6143]; // zoo
    reg [15:0] img_Jawad     [0:6143]; // Jawad
    reg [15:0] img_Jawad2    [0:6143]; // Jawad2
    reg [15:0] img_Aashir    [0:6143]; // Aashir
    reg [15:0] frame_buffer  [0:6143]; // Current pixel data source
    // Load images from memory files
    initial begin
        $readmemh("imgs/NUSTlogo.mem", img_NUST_logo);
        // $readmemh("imgs/gardens.mem", img_gardens);
        // $readmemh("imgs/zoo.mem", img_zoo);
        $readmemh("imgs/Jawad.mem", img_Jawad);
        $readmemh("imgs/Jawad2.mem", img_Jawad2);
        // $readmemh("imgs/Aashir.mem", img_Aashir);
        $readmemh("imgs/zoo.mem", img_Aashir);
    end


    //==============================================================
    // Brightness Adjustment Functions
    //==============================================================
    function [15:0] brighten_pixel;
        input [15:0] pixel;
        input [2:0] level; // level 1-4 (multiplier: 1.25x to 2.0x)
        reg [4:0] r, b;
        reg [5:0] g;
        reg [8:0] r_scaled; // Need extra bits for multiplication
        reg [9:0] g_scaled;
        reg [8:0] b_scaled;
        begin
            // Extract RGB components
            r = pixel[15:11];
            g = pixel[10:5];
            b = pixel[4:0];
            
            // Scale by brightness factor: 1.0 + (level * 0.25)
            // level=1: 1.25x, level=2: 1.5x, level=3: 1.75x, level=4: 2.0x
            r_scaled = (r * (4 + level)) >> 2; // r * (4+level)/4
            g_scaled = (g * (4 + level)) >> 2; // g * (4+level)/4  
            b_scaled = (b * (4 + level)) >> 2; // b * (4+level)/4
            
            // Clamp to maximum values
            r = (r_scaled > 5'd31) ? 5'd31 : r_scaled[4:0];
            g = (g_scaled > 6'd63) ? 6'd63 : g_scaled[5:0];
            b = (b_scaled > 5'd31) ? 5'd31 : b_scaled[4:0];
            
            brighten_pixel = {r, g, b};
        end
    endfunction

    function [15:0] darken_pixel;
        input [15:0] pixel;
        input [2:0] level; // level 1-4 (multiplier: 0.75x to 0.0x)
        reg [4:0] r, b;
        reg [5:0] g;
        reg [8:0] r_scaled;
        reg [9:0] g_scaled;
        reg [8:0] b_scaled;
        begin
            // Extract RGB components
            r = pixel[15:11];
            g = pixel[10:5];
            b = pixel[4:0];
            
            // Scale by brightness factor: 1.0 - (level * 0.25)
            // level=1: 0.75x, level=2: 0.5x, level=3: 0.25x, level=4: 0.0x
            r_scaled = (r * (4 - level)) >> 2; // r * (4-level)/4
            g_scaled = (g * (4 - level)) >> 2; // g * (4-level)/4
            b_scaled = (b * (4 - level)) >> 2; // b * (4-level)/4
            
            // Clamp to minimum values
            r = (r_scaled < 5'd0) ? 5'd0 : r_scaled[4:0];
            g = (g_scaled < 6'd0) ? 6'd0 : g_scaled[5:0];
            b = (b_scaled < 5'd0) ? 5'd0 : b_scaled[4:0];
            
            darken_pixel = {r, g, b};
        end
    endfunction


    //==============================================================
    // Finite State Machine (FSM)
    //==============================================================

    //---------------------------
    //--- (1) State Definitions |
    //---------------------------

    // state definition
    localparam STATE_LOGO = 0;
    // localparam STATE_GARDENS = 1;
    // localparam STATE_ZOO = 2;
    localparam STATE_JAWAD = 1;
    localparam STATE_JAWAD2 = 2;
    localparam STATE_AASHIR = 3;
    localparam STATE_RECTANGLE = 4;
    
    // State registers - INDUSTRY STANDARD APPROACH (2 state registers)
    reg [2:0] current_state, next_state; // ← 3 bits for 7 states

    // Transition detection register
    reg prev_in_JAWAD2; // Register to detect transition out of JAWAD2 -> turn off LEDs once

    // Initialize state machine
    initial begin
        current_state = STATE_LOGO;
        next_state = STATE_LOGO;
        led = 8'b00000000;      // Initialize LEDs to off
        prev_in_JAWAD2 = 1'b0;  // Initialize transition detector
    end

    //--------------------------------------------
    //--- (2) Button Edge Detection (Sequential) |
    //--------------------------------------------
    always @(posedge clk) begin
        // Store previous button values for edge detection
        btnU_prev <= btnU_debounced;
        btnD_prev <= btnD_debounced;
        btnC_prev <= btnC_debounced;
        btnL_prev <= btnL_debounced;
        btnR_prev <= btnR_debounced;

        // Update transition detector
        prev_in_JAWAD2 <= (current_state == STATE_JAWAD2);
    end

    //------------------------------------------
    //--- (3) Next State Logic (Combinational) |
    //------------------------------------------
    always @(*) begin  // ← CORRECTED: Combinational, not sequential
        // Default: stay in current state
        next_state = current_state;
        
        // State transitions based on button edges
        if (btnU_posedge) begin
            // Move to next state (forward cycle)
            case (current_state)
                // STATE_LOGO:      next_state = STATE_GARDENS;
                // STATE_GARDENS:   next_state = STATE_ZOO;
                // STATE_ZOO:       next_state = STATE_JAWAD;
                STATE_LOGO:      next_state = STATE_JAWAD;
                STATE_JAWAD:     next_state = STATE_JAWAD2;
                STATE_JAWAD2:    next_state = STATE_AASHIR;
                STATE_AASHIR:    next_state = STATE_RECTANGLE;
                STATE_RECTANGLE: next_state = STATE_LOGO;
                default:         next_state = STATE_LOGO;
            endcase
        end
        else if (btnD_posedge) begin
            // Move to previous state (backward cycle)
            case (current_state)
                // STATE_LOGO:      next_state = STATE_RECTANGLE;
                // STATE_GARDENS:   next_state = STATE_LOGO;
                // STATE_ZOO:       next_state = STATE_GARDENS;
                STATE_LOGO:      next_state = STATE_RECTANGLE;
                STATE_JAWAD:     next_state = STATE_LOGO;
                STATE_JAWAD2:    next_state = STATE_JAWAD;
                STATE_AASHIR:    next_state = STATE_JAWAD2;
                STATE_RECTANGLE: next_state = STATE_AASHIR;
                default:         next_state = STATE_LOGO;
            endcase
        end
    end

    //--------------------------------------------
    //--- (4) State Register Update (Sequential) |
    //--------------------------------------------
    always @(posedge clk) begin

        // Update current_state
        current_state <= next_state;

        // ----- JAWAD -----
        // Reset channel mode to all channels when entering STATE_JAWAD
        if (current_state != STATE_JAWAD && next_state == STATE_JAWAD) begin
            channel_mode <= 2'b00;
        end
        // Toggle channel mode when centre button is pressed in STATE_JAWAD
        else if (btnC_posedge && current_state == STATE_JAWAD) begin
            channel_mode <= channel_mode + 1; // Cycle through 00, 01, 10, 11
        end


        // ----- JAWAD2 -----
        // Brightness control for STATE_JAWAD2
        if (current_state != STATE_JAWAD2 && next_state == STATE_JAWAD2) begin
            // Reset to center brightness when entering STATE_JAWAD2
            brightness_level <= CENTER_BRIGHTNESS;
        end
        else if (current_state == STATE_JAWAD2) begin
            // Increase brightness with btnL
            if (btnL_posedge && brightness_level < MAX_BRIGHTNESS) begin
                brightness_level <= brightness_level + 1;
            end
            // Decrease brightness with btnR
            else if (btnR_posedge && brightness_level > MIN_BRIGHTNESS) begin
                brightness_level <= brightness_level - 1;
            end
        end
    end

    //-------------------------------------------------
    //--- (5) Output Logic (State-Dependent Behavior) |
    //-------------------------------------------------
    // Pixel data selection - Directly select from appropriate image based on state
    // Its light weight compared to copying bytes in frame_buffer using for loop (sample at bottom)
    always @(posedge oled_clk) begin
        case (current_state)
            STATE_LOGO:
                pixel_data <= img_NUST_logo[pixel_index];
            // STATE_GARDENS: 
            //     pixel_data <= img_gardens[pixel_index];
            // STATE_ZOO:
            //     pixel_data <= img_zoo[pixel_index];
            STATE_JAWAD:
                case (channel_mode)
                    2'b00: // All channels (original image)
                        pixel_data <= img_Jawad[pixel_index];
                    2'b01: // Red channel only
                        pixel_data <= {img_Jawad[pixel_index][15:11], 11'b0}; // R + zeros
                    2'b10: // Green channel only
                        pixel_data <= {5'b0, img_Jawad[pixel_index][10:5], 5'b0}; // zeros + G + zeros
                    2'b11: // Blue channel only
                        pixel_data <= {11'b0, img_Jawad[pixel_index][4:0]}; // zeros + B
                endcase
            STATE_JAWAD2:
                // Apply brightness adjustment to pixel data
                if (brightness_level == CENTER_BRIGHTNESS) begin
                    pixel_data <= img_Jawad2[pixel_index];
                end else if (brightness_level > CENTER_BRIGHTNESS) begin
                    // Brighten: levels 5-8 → multipliers 1.25x to 2.0x
                    pixel_data <= brighten_pixel(img_Jawad2[pixel_index], 
                                                brightness_level - CENTER_BRIGHTNESS);
                end else begin
                    // Darken: levels 0-3 → multipliers 0.75x to 0.0x
                    pixel_data <= darken_pixel(img_Jawad2[pixel_index], 
                                            CENTER_BRIGHTNESS - brightness_level);
                end
            STATE_AASHIR:
                pixel_data <= img_Aashir[pixel_index];
            STATE_RECTANGLE: begin
                // Draw rectangle on black background
                if ((x >= RECT_X1 && x <= RECT_X2) && 
                    (y >= RECT_Y1 && y <= RECT_Y2) &&
                    (x == RECT_X1 || x == RECT_X2 || 
                    y == RECT_Y1 || y == RECT_Y2)) begin
                    pixel_data <= RECT_COLOR;
                end else begin
                    pixel_data <= 16'h0000; // Black background
                end
            end
            default:
                pixel_data <= 16'h0000; // Black
        endcase
    end

    // LED display logic in Output Logic section (combinational)
    always @(*) begin
        if (current_state == STATE_JAWAD2) begin
            case(brightness_level)
                0: led = 8'b00000000; // 0 LEDs
                1: led = 8'b00000001; // 1 LED
                2: led = 8'b00000011; // 2 LEDs
                3: led = 8'b00000111; // 3 LEDs
                4: led = 8'b00001111; // 4 LEDs (center)
                5: led = 8'b00011111; // 5 LEDs
                6: led = 8'b00111111; // 6 LEDs
                7: led = 8'b01111111; // 7 LEDs
                8: led = 8'b11111111; // 8 LEDs
                default: led = 8'b00001111; // default to center
            endcase
        end
        // Turn off LEDs only when transitioning out of JAWAD2
        else if (prev_in_JAWAD2 && (current_state != STATE_JAWAD2)) begin
            led = 8'b00000000;
        end
    end


    //============= Instantiate modules =============
        //------------- Instantiate Clock divider -------------
        clock_divider pulse_6p25m (.pulse_out(oled_clk), .basys_clock(clk), .frequency(6_250_000)); // 6.25 MHz
        clock_divider pulse_1     (.pulse_out(clk_1), .basys_clock(clk), .frequency(1));            // 1 Hz

        //------------- Instantiate debouncers for buttons -------------
        debouncer debounce_up (.button_out(btnU_debounced), .button_in(btnU), .clk(clk));
        debouncer debounce_down (.button_out(btnD_debounced), .button_in(btnD), .clk(clk));
        debouncer debounce_centre (.button_out(btnC_debounced), .button_in(btnC), .clk(clk));
        debouncer debounce_left (.button_out(btnL_debounced), .button_in(btnL), .clk(clk));
        debouncer debounce_right (.button_out(btnR_debounced), .button_in(btnR), .clk(clk));

        //------------- Instantiate Coordinate System (X,Y) for OLED -------------
        coordinate_system row_col (x, y, pixel_index);

        //------------- Instantiate OLED controller -------------
        Oled_Display oled_controller(
            .clk(oled_clk),           // Clock: 6.25MHz SPI clock for display communication
            .reset(1'b0),             // Reset: Permanently disabled (0 = no reset)
            .frame_begin(),           // Output: Unused - Pulses at start of each frame
            .sending_pixels(),        // Output: Unused - High during pixel data transmission
            .sample_pixel(),          // Output: Unused - Pulses when pixel data should be read
            .pixel_index(pixel_index),// Output: [12:0] Current pixel address (0-6143 for 96x64)
            .pixel_data(pixel_data),  // Input:  [15:0] RGB565 color data for current pixel
            .cs(cs),                  // Output: OLED PIN - Chip Select (Active low)
            .sdin(sdin),              // Output: OLED PIN - Serial Data (MOSI)
            .sclk(sclk),              // Output: OLED PIN - Serial Clock (SCLK)
            .d_cn(d_cn),              // Output: OLED PIN - Data/Command# (0=Command, 1=Data)
            .resn(resn),              // Output: OLED PIN - Reset# (Active low)
            .vccen(vccen),            // Output: OLED PIN - VCC Enable (Power control)
            .pmoden(pmoden),          // Output: OLED PIN - PMOD Enable
            .teststate()              // Output: Unused - Internal state machine debug
        );
    //===============================================
   
endmodule

// Combinational (always @(*)):
// Sequential    (always @(posedge clk)):

/*
    // Copying img into frame_buffer
    // note: using for loop is resource heavy / costly when hardware gets implemented at gate lvl. Thus we are injecting values directly into pixel_data
    for (i = 0; i < 6144; i = i + 1) begin
        frame_buffer[i] = img_gardens[i];
    end
*/


/*
    // FUNCTION's Basic structure:
    //----------------------------
    function [return_type] function_name;
        input [bits] input1;
        input [bits] input2;
        // ... more inputs
        begin
            // Calculations here
            function_name = result; // Return the result
        end
    endfunction
*/











    //==============================================================
    // Pixel Sampling for OLED
    //==============================================================
    // always @(posedge oled_clk) begin
    //     pixel_data <= frame_buffer[pixel_index];
    // end



    //------------- SOLID PATTERNS -------------
    // // RGB565 White
    // assign pixel_data = 16'b11111_111111_11111;

    // // Color pattern: Red, Green, Blue horizontal bands
    // assign pixel_data = (pixel_index < 2048)  ? 16'b11111_000000_00000 : // RGB565 Red
    //                     (pixel_index < 4096)  ? 16'b00000_111111_00000 : // RGB565 Green
    //                                             16'b00000_000000_11111;  // RGB565 Blue





    // //------------------------------------------------
    // //--- (3) State Transition Logic (Combinational) |
    // //------------------------------------------------
    // always @(*) begin
    //     case (state)
    //         STATE_GARDENS:   next_state = STATE_ZOO;
    //         STATE_ZOO:       next_state = STATE_LOGO;
    //         STATE_LOGO:      next_state = STATE_RECTANGLE;
    //         STATE_RECTANGLE: next_state = STATE_RECTANGLE; // Stay on rectangle
    //         default:         next_state = STATE_GARDENS;
    //     endcase
    // end

    // //--------------------------------------------
    // //--- (3) State Register Update (Sequential) |
    // //--------------------------------------------

    // // 3-second timer (using 1Hz clock)
    // always @(posedge clk_1) begin
    //     if (counter >= 24'd2) begin // 0,1,2 = 3 seconds
    //         counter <= 0;
    //         state <= next_state;
    //     end else begin
    //         counter <= counter + 1;
    //     end
    // end

    // //-------------------------------------------------
    // //--- (4) Output Logic (State-Dependent Behavior) |
    // //-------------------------------------------------
    // // Pixel data selection - Directly select from appropriate image based on state
    // always @(posedge oled_clk) begin
    //     case (state)
    //         STATE_GARDENS: 
    //             pixel_data <= img_gardens[pixel_index];
    //         STATE_ZOO:
    //             pixel_data <= img_zoo[pixel_index];
    //         STATE_LOGO:
    //             pixel_data <= img_NUST_logo[pixel_index];
    //         STATE_RECTANGLE: begin
    //             // Draw rectangle on black background
    //             if ((x >= RECT_X1 && x <= RECT_X2) && 
    //                 (y >= RECT_Y1 && y <= RECT_Y2) &&
    //                 (x == RECT_X1 || x == RECT_X2 || 
    //                  y == RECT_Y1 || y == RECT_Y2)) begin
    //                 pixel_data <= RECT_COLOR;
    //             end else begin
    //                 pixel_data <= 16'h0000; // Black background
    //             end
    //         end
    //         default:
    //             pixel_data <= 16'h0000; // Black
    //     endcase
    // end






        // clock_divider pulse_6p25MHz (.new_clock_en(oled_clk), .basys_clock(clk), .divisor(16));         // 6.25 MHz
        // clock_divider pulse_1Hz     (.new_clock_en(clk_1Hz), .basys_clock(clk), .divisor(100_000_000)); // 1 Hz

    // //------------- Clock divider -------------
    // // 100MHz / 16 = 6.25MHz
    // reg [3:0] clk_divider = 0;
    // wire oled_clk = clk_divider[3];

    
    // always @(posedge clk) begin
    //     clk_divider <= clk_divider + 1;
    // end


/*
module top_oled (
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC,       // JC[0]=cs, JC[1]=sdin, JC[3]=sclk,
                                // JC[4]=d_cn, JC[5]=resn, JC[6]=vccen, JC[7]=pmoden
                                // JC[2] unused
    
    //------------- Debug LEDs -------------
    output wire [15:0] led,     // LEDs for debugging

    //------------- Inputs (matches .xdc) -------------
    input clk,                   // system clock (100MHz)
    input btnC                   // reset button (center button - BTNC)
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire reset;  // Internal reset signal
    
    //------------- Display parameters -------------
    localparam Width = 96;
    localparam Height = 64;
    localparam PixelCount = Width * Height;
    localparam PixelCountWidth = $clog2(PixelCount);
    
    //------------- Signal Assignment -------------
    // FIX 1: Invert button (Basys3 buttons are active-low)
    assign reset = ~btnC;
    
    // FIX 2: Match JC mapping from working design
    assign JC[0] = cs;          // CS
    assign JC[1] = sdin;        // MOSI (Serial Data In)
    assign JC[2] = 1'b0;        // Unused
    assign JC[3] = sclk;        // SCLK
    assign JC[4] = d_cn;        // D/C
    assign JC[5] = resn;        // RESET
    assign JC[6] = vccen;       // VCC Enable
    assign JC[7] = pmoden;      // PMOD Enable

    //------------- Clock divider -------------
    // 100MHz / 16 = 6.25MHz
    reg [3:0] clk_divider = 0;
    wire oled_clk = clk_divider[3];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
        end else begin
            clk_divider <= clk_divider + 1;
        end
    end

    //------------- OLED display interface signals -------------
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [PixelCountWidth-1:0] pixel_index;
    wire [15:0] pixel_data;
    wire [4:0] teststate;
    
    //------------- Instantiate OLED controller -------------
    Oled_Display oled_controller(
        .clk(oled_clk),
        .reset(reset),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(cs),
        .sdin(sdin),
        .sclk(sclk),
        .d_cn(d_cn),
        .resn(resn),
        .vccen(vccen),
        .pmoden(pmoden),
        .teststate(teststate)
    );
    
    //------------- Debugging System -------------
    reg [4:0] last_state = 0;
    reg state_changed = 0;
    always @(posedge oled_clk) begin
        if (teststate != last_state) begin
            last_state <= teststate;
            state_changed <= 1;
        end else begin
            state_changed <= 0;
        end
    end
    
    reg spi_active = 0;
    reg [23:0] spi_timeout = 0;
    always @(posedge clk) begin
        if (reset) begin
            spi_active <= 0;
            spi_timeout <= 0;
        end else begin
            if (~sclk && !spi_active) begin
                spi_active <= 1;
                spi_timeout <= 0;
            end else if (spi_active) begin
                if (spi_timeout > 100000) begin
                    spi_active <= 0;
                end else begin
                    spi_timeout <= spi_timeout + 1;
                end
            end
        end
    end
    
    reg [31:0] frame_counter = 0;
    always @(posedge oled_clk) begin
        if (frame_begin) begin
            frame_counter <= frame_counter + 1;
        end
    end
    
    reg pixel_activity = 0;
    always @(posedge oled_clk) begin
        if (sample_pixel) begin
            pixel_activity <= 1;
        end else if (frame_begin) begin
            pixel_activity <= 0;
        end
    end
    
    //------------- LED Debug Outputs -------------
    assign led[0] = reset;              // LED0 = Reset active
    assign led[1] = frame_begin;        // LED1 = Frame begin
    assign led[2] = sending_pixels;     // LED2 = Sending pixels
    assign led[3] = sample_pixel;       // LED3 = Sample pixel
    assign led[4] = spi_active;         // LED4 = SPI activity
    assign led[5] = state_changed;      // LED5 = State changed
    assign led[6] = pixel_activity;     // LED6 = Pixel activity
    assign led[7] = |teststate;         // LED7 = State machine active
    
    // Show current state on LEDs 8-12
    assign led[12:8] = teststate;
    
    // Blink LED15 at 1Hz to show system alive
    reg [25:0] heartbeat = 0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 1;
    end
    assign led[15] = heartbeat[25];
    
    //------------- SIMPLE TEST PATTERN -------------
    // Solid white: R=31, G=63, B=31
    assign pixel_data = 16'b11111_111111_11111;
    
endmodule
*/


/*
    DeepSeeks code: fixed pin assignments but maybe reset problem is still there
module top_oled (
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC,       // JC[0]=JC1=cs, JC[1]=JC2=sdin, JC[2]=JC3=d_cn, JC[3]=JC4=sclk, 
                                // JC[4]=JC7=resn, JC[5]=JC8=vccen, JC[6]=JC9=pmoden
                                // JC[7]=JC10 is unused
    
    //------------- Debug LEDs -------------
    output wire [15:0] led,     // LEDs for debugging

    //------------- Inputs (matches .xdc) -------------
    input clk,                   // system clock (100MHz)
    input btnC                   // reset button (center button - BTNC)
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire reset;  // Internal reset signal
    
    //------------- Display parameters -------------
    localparam Width = 96;
    localparam Height = 64;
    localparam PixelCount = Width * Height;
    localparam PixelCountWidth = $clog2(PixelCount);
    
    //------------- CORRECT Pin Assignment for YOUR .xdc -------------
    // This now matches the standard PMOD OLED pinout AND your specific board's JC header.
    assign JC[0] = cs;          // JC[0] -> K17 -> JC1 on board -> CS on OLED
    assign JC[1] = sdin;        // JC[1] -> M18 -> JC2 on board -> SDIN on OLED
    assign JC[2] = d_cn;        // JC[2] -> N17 -> JC3 on board -> D/C on OLED
    assign JC[3] = sclk;        // JC[3] -> P18 -> JC4 on board -> SCLK on OLED
    assign JC[4] = resn;        // JC[4] -> L17 -> JC7 on board -> RES on OLED
    assign JC[5] = vccen;       // JC[5] -> M19 -> JC8 on board -> VCCEN on OLED
    assign JC[6] = pmoden;      // JC[6] -> P17 -> JC9 on board -> PMODEN on OLED
    assign JC[7] = 1'b0;        // JC[7] -> R18 -> JC10 on board -> NC (set to 0)

    assign reset = btnC;        // Map center button (BTNC) to internal reset

    //------------- Clock divider -------------
    // 100MHz / 16 = 6.25MHz
    reg [3:0] clk_divider = 0;
    wire oled_clk = clk_divider[3]; // This is a 6.25 MHz clock
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
        end else begin
            clk_divider <= clk_divider + 1;
        end
    end

    //------------- OLED display interface signals -------------
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [PixelCountWidth-1:0] pixel_index;
    wire [15:0] pixel_data;
    wire [4:0] teststate;
    
    //------------- Instantiate OLED controller -------------
    Oled_Display oled_controller(
        .clk(oled_clk),        // Providing a proper 6.25MHz clock
        .reset(reset),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(cs),
        .sdin(sdin),
        .sclk(sclk),
        .d_cn(d_cn),
        .resn(resn),
        .vccen(vccen),
        .pmoden(pmoden),
        .teststate(teststate)
    );
    
    //------------- Debugging System -------------
    // ... (Keep your existing debugging code exactly as it was) ...
    // 1. State machine monitor
    reg [4:0] last_state = 0;
    reg state_changed = 0;    
    always @(posedge oled_clk) begin
        if (teststate != last_state) begin
            last_state <= teststate;
            state_changed <= 1;
        end else begin
            state_changed <= 0;
        end
    end    
    // 2. SPI activity detector
    reg spi_active = 0;
    reg [23:0] spi_timeout = 0;    
    always @(posedge clk) begin
        if (reset) begin
            spi_active <= 0;
            spi_timeout <= 0;
        end else begin
            if (~sclk && !spi_active) begin
                spi_active <= 1;
                spi_timeout <= 0;
            end else if (spi_active) begin
                if (spi_timeout > 100000) begin
                    spi_active <= 0;
                end else begin
                    spi_timeout <= spi_timeout + 1;
                end
            end
        end
    end    
    // 3. Frame counter for diagnostics
    reg [31:0] frame_counter = 0;
    always @(posedge oled_clk) begin
        if (frame_begin) begin
            frame_counter <= frame_counter + 1;
        end
    end    
    // 4. Pixel transmission monitor
    reg pixel_activity = 0;
    always @(posedge oled_clk) begin
        if (sample_pixel) begin
            pixel_activity <= 1;
        end else if (frame_begin) begin
            pixel_activity <= 0;
        end
    end
    
    //------------- LED Debug Outputs -------------
    assign led[0] = reset;              
    assign led[1] = frame_begin;        
    assign led[2] = sending_pixels;     
    assign led[3] = sample_pixel;       
    assign led[4] = spi_active;         
    assign led[5] = state_changed;      
    assign led[6] = pixel_activity;     
    assign led[7] = |teststate;         
    assign led[12:8] = teststate;       
    // Blink LED15 at 1Hz to show system alive
    reg [25:0] heartbeat = 0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 1;
    end
    assign led[15] = heartbeat[25];
    
    //------------- SIMPLE TEST PATTERN -------------
    assign pixel_data = 16'b11111_111111_11111; // RGB565 White
    
endmodule
*/

/*
module top_oled (
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC,       // JC[0]=sdin, JC[1]=sclk, JC[2]=cs, JC[3]=d_cn, 
                                // JC[4]=resn, JC[5]=vccen, JC[6]=pmoden
                                // JC[7] is unused
    
    //------------- Debug LEDs -------------
    output wire [15:0] led,     // LEDs for debugging

    //------------- Inputs (matches .xdc) -------------
    input clk,                   // system clock (100MHz)
    input btnC                   // reset button (center button - BTNC)
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire reset;  // Internal reset signal
    
    //------------- Display parameters -------------
    localparam Width = 96;
    localparam Height = 64;
    localparam PixelCount = Width * Height;
    localparam PixelCountWidth = $clog2(PixelCount);
    
    //------------- Signal Assignment -------------
    assign reset = btnC;        // Map center button (BTNC) to internal reset
    
    assign JC[0] = sdin;        // MOSI (Serial Data In)
    assign JC[1] = sclk;        // SCLK (Serial Clock)
    assign JC[2] = cs;          // CS (Chip Select)
    assign JC[3] = d_cn;        // D/C (Data/Command)
    assign JC[4] = resn;        // RESET (Active low reset)
    assign JC[5] = vccen;       // VCC Enable
    assign JC[6] = pmoden;      // PMOD Enable
    assign JC[7] = 1'b0;        // Unused - set to 0

    //------------- Clock divider -------------
    // 100MHz / 16 = 6.25MHz
    reg [3:0] clk_divider = 0;
    wire oled_clk = clk_divider[3];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
        end else begin
            clk_divider <= clk_divider + 1;
        end
    end

    //------------- OLED display interface signals -------------
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [PixelCountWidth-1:0] pixel_index;
    wire [15:0] pixel_data;
    wire [4:0] teststate;
    
    //------------- Instantiate OLED controller -------------
    Oled_Display oled_controller(
        .clk(oled_clk),
        .reset(reset),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(cs),
        .sdin(sdin),
        .sclk(sclk),
        .d_cn(d_cn),
        .resn(resn),
        .vccen(vccen),
        .pmoden(pmoden),
        .teststate(teststate)
    );
    
    //------------- Debugging System -------------
    
    // 1. State machine monitor
    reg [4:0] last_state = 0;
    reg state_changed = 0;
    
    always @(posedge oled_clk) begin
        if (teststate != last_state) begin
            last_state <= teststate;
            state_changed <= 1;
        end else begin
            state_changed <= 0;
        end
    end
    
    // 2. SPI activity detector - FIXED: Only one driver
    reg spi_active = 0;
    reg [23:0] spi_timeout = 0;
    
    always @(posedge clk) begin
        if (reset) begin
            spi_active <= 0;
            spi_timeout <= 0;
        end else begin
            // Detect SPI activity on negative edge of sclk
            if (~sclk && !spi_active) begin
                spi_active <= 1;
                spi_timeout <= 0;
            end else if (spi_active) begin
                if (spi_timeout > 100000) begin
                    spi_active <= 0;
                end else begin
                    spi_timeout <= spi_timeout + 1;
                end
            end
        end
    end
    
    // 3. Frame counter for diagnostics
    reg [31:0] frame_counter = 0;
    always @(posedge oled_clk) begin
        if (frame_begin) begin
            frame_counter <= frame_counter + 1;
        end
    end
    
    // 4. Pixel transmission monitor
    reg pixel_activity = 0;
    always @(posedge oled_clk) begin
        if (sample_pixel) begin
            pixel_activity <= 1;
        end else if (frame_begin) begin
            pixel_activity <= 0;
        end
    end
    
    //------------- LED Debug Outputs -------------
    assign led[0] = reset;              // LED0 = Reset active
    assign led[1] = frame_begin;        // LED1 = Frame begin
    assign led[2] = sending_pixels;     // LED2 = Sending pixels
    assign led[3] = sample_pixel;       // LED3 = Sample pixel
    assign led[4] = spi_active;         // LED4 = SPI activity
    assign led[5] = state_changed;      // LED5 = State changed
    assign led[6] = pixel_activity;     // LED6 = Pixel activity
    assign led[7] = |teststate;         // LED7 = State machine active
    
    // Show current state on LEDs 8-12
    assign led[12:8] = teststate;
    
    // Blink LED15 at 1Hz to show system alive
    reg [25:0] heartbeat = 0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 1;
    end
    assign led[15] = heartbeat[25];
    
    //------------- SIMPLE TEST PATTERN -------------
    // Start with solid white to verify basic communication
    assign pixel_data = 16'b11111_111111_11111;
    
endmodule
*/

/*
module top_oled (
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC,       // JC[0]=sdin, JC[1]=sclk, JC[2]=cs, JC[3]=d_cn, 
                                // JC[4]=resn, JC[5]=vccen, JC[6]=pmoden
                                // JC[7] is unused

    //------------- Inputs (matches .xdc) -------------
    input clk,                   // system clock (100MHz)
    input btnC                   // reset button (center button - BTNC)
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire reset;  // Internal reset signal
    
    //------------- Signal Assignment -------------
    assign reset = btnC;        // Map center button (BTNC) to internal reset
    
    assign JC[0] = sdin;        // MOSI (Serial Data In)
    assign JC[1] = sclk;        // SCLK (Serial Clock)
    assign JC[2] = cs;          // CS (Chip Select)
    assign JC[3] = d_cn;        // D/C (Data/Command)
    assign JC[4] = resn;        // RESET (Active low reset)
    assign JC[5] = vccen;       // VCC Enable
    assign JC[6] = pmoden;      // PMOD Enable
    assign JC[7] = 1'b0;        // Unused - set to 0

    // Clock divider to get 6.25MHz clock for the OLED display
    // 100MHz / 16 = 6.25MHz
    reg [3:0] clk_divider = 0;
    wire oled_clk = clk_divider[3]; // 6.25MHz clock
    
    always @(posedge clk) begin
        clk_divider <= clk_divider + 1;
    end

    // OLED display interface signals
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    
    // FIXED: Define parameters HERE in the top module
    localparam Width = 96;
    localparam Height = 64;
    localparam PixelCount = Width * Height;
    localparam PixelCountWidth = $clog2(PixelCount);
    
    wire [PixelCountWidth-1:0] pixel_index;  // Now this will work!
    wire [15:0] pixel_data;
    wire [4:0] teststate;
    
    // Instantiate the OLED display controller
    Oled_Display oled_controller(
        .clk(oled_clk),
        .reset(reset),          // Use internal reset signal
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(cs),
        .sdin(sdin),
        .sclk(sclk),
        .d_cn(d_cn),
        .resn(resn),
        .vccen(vccen),
        .pmoden(pmoden),
        .teststate(teststate)
    );
    
    // Pixel data generator - always output white (all 1's)
    assign pixel_data = 16'b11111_111111_11111;  // White in RGB565
    
endmodule
*/



