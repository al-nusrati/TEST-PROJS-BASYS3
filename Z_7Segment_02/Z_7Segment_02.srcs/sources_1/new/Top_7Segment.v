`timescale 1ns / 1ps
module Top_7Segment(
    output [6:0] seg,    // Segments {g, f, e, d, c, b, a}
    output [3:0] an,     // Digit enable (0 = ON)
    output dp,           // Decimal point
    input clk            // 100 MHz clock input
    );


    // Clock Divider for 1 Hz and 200 Hz
    wire clk1, clk200;
    clock_divider pulse_1 (.pulse_out(clk1), .frequency(1), .clk_in(clk));
    clock_divider pulse_200 (.pulse_out(clk200), .frequency(200), .clk_in(clk));

    // State Machine (2-bit)
    reg [1:0] state = 2'd3;

    // State changing every 1 sec (1 Hz)
    always @(posedge clk1) begin
        state <= state + 1;
    end

    // Instantiate Display Module
    SevenSegmentDisplay display (
        .seg(seg),
        .an(an),
        .dp(dp),
        .clk200(clk200),
        .state(state)
    );
endmodule
