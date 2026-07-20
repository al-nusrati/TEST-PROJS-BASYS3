`timescale 1ns / 1ps


module SevenSegmentDisplay(
    output reg [6:0] seg,    // Segments {g, f, e, d, c, b, a}
    output reg [3:0] an,     // Digit enable (0 = ON)
    output dp,               // Decimal point
    input clk200,            // 200Hz clock input (renamed from clk)
    input [1:0] state        // 2-bit state input
    );

    // Keep dp OFF
    assign dp = 1'b1;

    // 7-Segment Patterns
    reg [6:0] display0, display1, display2, display3;

    always @(*) begin
        case (state)
            2'd0: begin // ADD-
                display3 = 7'b0001000; // A
                display2 = 7'b0100001; // d
                display1 = 7'b0100001; // d
                display0 = 7'b0111111; // -
            end
            2'd1: begin // SUB-
                display3 = 7'b0010010; // S
                display2 = 7'b1100011; // u
                display1 = 7'b0000011; // b
                display0 = 7'b0111111; // -
            end
            2'd2: begin // XOR-
                display3 = 7'b0001001; // X
                display2 = 7'b0100011; // o
                display1 = 7'b0101111; // r
                display0 = 7'b0111111; // -
            end
            2'd3: begin // ----
                display3 = 7'b0111111; // -
                display2 = 7'b0111111; // -
                display1 = 7'b0111111; // -
                display0 = 7'b0111111; // -
            end
        endcase
    end

    // Multiplex Display
    reg [1:0] scan_state = 2'd0;

    always @(posedge clk200) begin  // Changed from clk to clk200
        scan_state <= scan_state + 1;

        case (scan_state)
            2'd0: begin
                an <= 4'b1110;
                seg <= display0;
            end
            2'd1: begin
                an <= 4'b1101;
                seg <= display1;
            end
            2'd2: begin
                an <= 4'b1011;
                seg <= display2;
            end
            2'd3: begin
                an <= 4'b0111;
                seg <= display3;
            end
        endcase
    end
endmodule