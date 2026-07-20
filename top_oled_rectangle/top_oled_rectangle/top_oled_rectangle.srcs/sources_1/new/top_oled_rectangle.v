`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2025 08:13:12 PM
// Design Name: 
// Module Name: top_oled_rectangle
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




module top_oled_rectangle(
    //------------- Outputs (Pmod JC pins) -------------
    output wire [7:0] JC, // JC[0]=cs, JC[1]=sdin, JC[3]=sclk,
                          // JC[4]=d_cn, JC[5]=resn, JC[6]=vccen, JC[7]=pmoden
                          // JC[2] unused
    //------------- Inputs -------------
    input clk            // system clock (100MHz)
);

    //------------- Internal signals -------------
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    wire oled_clk;           // oled clk pulse

    // oled display interface signals
    wire [12:0] pixel_index; // 13 bits for 96*64=6144 pixels (addresses: 0-6143)
    reg  [15:0] pixel_data;  // RGB565 pixel data
    wire [7:0]  x, y;        // screen coordinates

    //------------- Signal Assignment -------------
    assign JC[0] = cs;    // CS
    assign JC[1] = sdin;  // MOSI (Serial Data In)
    assign JC[2] = 1'b0;  // Unused
    assign JC[3] = sclk;  // SCLK
    assign JC[4] = d_cn;  // D/C
    assign JC[5] = resn;  // RESET
    assign JC[6] = vccen; // VCC Enable
    assign JC[7] = pmoden;// PMOD Enable



    // Rectangle parameters
    parameter RECT_X1 = 20;
    parameter RECT_Y1 = 15;
    parameter RECT_X2 = 75;
    parameter RECT_Y2 = 50;
    parameter RECT_COLOR = 16'hF800; // Red in RGB565
    
    //-------------------------------------------------
    //--- Output Logic (Rectangle Drawing) ------------
    //-------------------------------------------------
    always @(posedge oled_clk) begin
        // Draw rectangle on black background
        if ((x >= RECT_X1 && x <= RECT_X2) && 
            (y >= RECT_Y1 && y <= RECT_Y2)) begin
            pixel_data <= RECT_COLOR;
        end else begin
            pixel_data <= 16'h0000; // Black background
        end
    end



    //============= Instantiate modules =============
    //------------- Instantiate Clock divider -------------
    clock_divider pulse_6p25m (.pulse_out(oled_clk), .basys_clock(clk), .frequency(6_250_000)); // 6.25 MHz

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





/*
// ***** Draw RECTANGLE *****
    // Rectangle parameters
    parameter RECT_X1 = 20;
    parameter RECT_Y1 = 15;
    parameter RECT_X2 = 75;
    parameter RECT_Y2 = 50;
    parameter RECT_COLOR = 16'hF800; // Red in RGB565
    
    //-------------------------------------------------
    //--- Output Logic (Rectangle Drawing) ------------
    //-------------------------------------------------
    always @(posedge oled_clk) begin
        // Draw rectangle on black background
        if ((x >= RECT_X1 && x <= RECT_X2) && 
            (y >= RECT_Y1 && y <= RECT_Y2)) begin
            pixel_data <= RECT_COLOR;
        end else begin
            pixel_data <= 16'h0000; // Black background
        end
    end
*/





/*
// ***** Draw CIRCLE *****
// Circle parameters
parameter CIRCLE_CX = 48;      // Center X (96/2)
parameter CIRCLE_CY = 32;      // Center Y (64/2) 
parameter CIRCLE_RADIUS = 20;  // Circle radius
parameter CIRCLE_COLOR = 16'h001F; // Blue in RGB565

//--- Distance calculation ------------------------
// Pre-calculate radius squared as a constant
localparam RADIUS_SQUARED = CIRCLE_RADIUS * CIRCLE_RADIUS;

// Calculate distance from center - declared as wires outside always block
wire signed [8:0] dx_signed = $signed({1'b0, x}) - CIRCLE_CX;
wire signed [8:0] dy_signed = $signed({1'b0, y}) - CIRCLE_CY;

// Calculate squared distance
wire [17:0] dx_squared = dx_signed * dx_signed;
wire [17:0] dy_squared = dy_signed * dy_signed;
wire [17:0] distance_squared = dx_squared + dy_squared;

//-------------------------------------------------
//--- Output Logic (Circle Drawing) ---------------
//-------------------------------------------------
always @(posedge oled_clk) begin
    // Draw circle on black background
    if (distance_squared <= RADIUS_SQUARED) begin
        pixel_data <= CIRCLE_COLOR;
    end else begin
        pixel_data <= 16'h0000; // Black background
    end
end
*/





/*
// ***** Animation VERTICAL LINE *****
// Animation parameters
parameter LINE_COLOR = 16'hF800; // Red line
parameter BACKGROUND_COLOR = 16'h0000; // Black background

// Line position and direction
reg [7:0] line_x = 0;  // Current x position of the vertical line
reg direction = 0;     // 0 = right, 1 = left

// Animation timing
reg [19:0] anim_counter = 0;
wire anim_tick = (anim_counter == 0);

//-------------------------------------------------
//--- Animation Logic (Line Movement) -------------
//-------------------------------------------------
always @(posedge clk) begin
    // Animation counter for slowing down movement
    anim_counter <= anim_counter + 1;
    
    if (anim_tick) begin
        // Move line based on direction
        if (direction == 0) begin
            line_x <= line_x + 1;
            if (line_x == 95) direction <= 1; // Switch to left at right edge
        end else begin
            line_x <= line_x - 1;
            if (line_x == 0) direction <= 0;  // Switch to right at left edge
        end
    end
end

//-------------------------------------------------
//--- Output Logic (Draw Vertical Line) -----------
//-------------------------------------------------
always @(posedge oled_clk) begin
    // Draw vertical line at current position
    if (x == line_x) begin
        pixel_data <= LINE_COLOR;
    end else begin
        pixel_data <= BACKGROUND_COLOR;
    end
*/