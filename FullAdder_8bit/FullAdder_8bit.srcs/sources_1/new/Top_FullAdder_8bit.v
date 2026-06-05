`timescale 1ns / 1ps

/*
    Outputs are either wire / reg
    Inputs are always treated as wire
*/
module Top_FullAdder_8bit(
    // ---------- Outputs ----------
    output wire [7:0] led,        // 8-bit sum output (connected to leds 0-7)
    output wire led_Cout,         // Carry out (connected to led 9)
    output wire led_Zero,         // Zero flag (connected to led 11)
    output wire led_Parity,       // Parity flag (connected to led 13)
    
    output [6:0] seg,  // Segments of 7-segment display
    output [3:0] an,   // Anodes of 7-segment display
    
    // ---------- Inputs ----------
    input wire [15:0] sw,         // 16-bit input from switches (8 bits for A, 8 bits for B)
    input wire btnC               // Carry input (from BTNC)
);

    // Internal wires
    wire [7:0] A;      // 8-bit input A (from SW[7:0])
    wire [7:0] B;      // 8-bit input B (from SW[15:8])
    wire Cin;          // Carry in from btnC

    // Connect sw[7:0] to A and sw[15:8] to B
    assign A = sw[7:0];
    assign B = sw[15:8];
    assign Cin = btnC; // Connect the carry-in to btnC (BTNC)

    // Segment and Anode Assignments (one-liner)
    assign seg = 7'b1111111;  // Turn off all segments
    assign an = 4'b1111;      // Turn off all anodes (no display active)


    // Instantiate the 8-bit full adder
    FullAdder_8bit full_adder (
        // ---------- Outputs ----------
        .sum(led),           // 8-bit sum output (connected to leds 0-7)
        .Cout(led_Cout),     // Carry out (connected to led 9)
        .Zero(led_Zero),     // Zero flag (connected to led 11)
        .Parity(led_Parity), // Parity flag (connected to led 13)
        
        // ---------- Inputs ----------
        .A(A),
        .B(B),
        .Cin(Cin)
    );
endmodule // Top_FullAdder_8bit



module FullAdder_8bit(
    // ---------- Outputs ----------
    output wire [7:0] sum,        // 8-bit sum output (connected to leds 0-7)
    output wire Cout,             // Carry out (connected to led 9)
    output wire Zero,             // Zero flag (connected to led 11)
    output wire Parity,           // Parity flag (connected to led 13)
    
    // ---------- Inputs ----------
    input wire [7:0] A,           // 8-bit input A (from SW[7:0])
    input wire [7:0] B,           // 8-bit input B (from SW[15:8])
    input wire Cin                // Carry in from btnC (BTNC)
);

    // Internal wires to hold carry and sum values
    wire [7:0] sum_internal;      // Internal sum of the full adder
    wire [7:0] carry;             // Internal carries for each bit
    wire zero_flag;               // Internal zero flag
    wire parity_flag;             // Internal parity flag

    // Full Adder Logic for each bit
    FullAdder_1bit adder0 (
        .sum(sum_internal[0]),
        .carry_out(carry[0]),  // Corrected to use carry_out instead of Cout
        .A(A[0]),
        .B(B[0]),
        .Cin(Cin)
    );

    FullAdder_1bit adder1 (
        .sum(sum_internal[1]),
        .carry_out(carry[1]),  // Corrected to use carry_out instead of Cout
        .A(A[1]),
        .B(B[1]),
        .Cin(carry[0])
    );

    FullAdder_1bit adder2 (
        .sum(sum_internal[2]),
        .carry_out(carry[2]),  // Corrected to use carry_out instead of Cout
        .A(A[2]),
        .B(B[2]),
        .Cin(carry[1])
    );

    FullAdder_1bit adder3 (
        .sum(sum_internal[3]),
        .carry_out(carry[3]),  // Corrected to use carry_out instead of Cout
        .A(A[3]),
        .B(B[3]),
        .Cin(carry[2])
    );

    FullAdder_1bit adder4 (
        .sum(sum_internal[4]),
        .carry_out(carry[4]),  // Corrected to use carry_out instead of Cout
        .A(A[4]),
        .B(B[4]),
        .Cin(carry[3])
    );

    FullAdder_1bit adder5 (
        .sum(sum_internal[5]),
        .carry_out(carry[5]),  // Corrected to use carry_out instead of Cout
        .A(A[5]),
        .B(B[5]),
        .Cin(carry[4])
    );

    FullAdder_1bit adder6 (
        .sum(sum_internal[6]),
        .carry_out(carry[6]),  // Corrected to use carry_out instead of Cout
        .A(A[6]),
        .B(B[6]),
        .Cin(carry[5])
    );

    FullAdder_1bit adder7 (
        .sum(sum_internal[7]),
        .carry_out(carry[7]),  // Corrected to use carry_out instead of Cout
        .A(A[7]),
        .B(B[7]),
        .Cin(carry[6])
    );

    // Final sum output (connected to LEDs 0-7)
    assign sum = sum_internal;

    // Final Carry out (connected to led 9)
    assign Cout = carry[7];

    // Zero flag (connected to led 11)
    assign zero_flag = (sum == 8'b00000000);

    // Parity flag (connected to led 13)
    assign parity_flag = ^sum_internal;  // XOR all sum bits for parity

    // Connect the flags to their respective LEDs
    assign Zero = zero_flag;
    assign Parity = parity_flag;

endmodule




module FullAdder_1bit(
    // ---------- Outputs ----------
    output sum,           // Sum output (1-bit)
    output carry_out,     // Carry out (Cout)
    
    // ---------- Inputs ----------
    input A,              // Input A (1 bit)
    input B,              // Input B (1 bit)
    input Cin             // Carry in
);

    // Sum logic: A XOR B XOR Cin
    assign sum = A ^ B ^ Cin;

    // Carry out logic: (A & B) | (Cin & (A ^ B))
    //                  OR of (A AND B) and (Cin AND (A XOR B))
    assign carry_out = (A & B) | (B & Cin) | (A & Cin);
    // assign carry_out = (A & B) | (Cin & (A ^ B));
endmodule


