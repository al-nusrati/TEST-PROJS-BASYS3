`timescale 1ns / 1ps
// ******************************************************************
// File Name      : SevenSegmentChars.v
// Description    : This file contains the constants for the 7-segment
//                  display, including mappings for digits and
//                  characters (A–F) used in the display.
//                  The constants define the 7-segment encoding for
//                  each digit or character, where segments are
//                  represented in active-low format.
//                  The format for each segment is:
//                  - seg[7]  = DP (Decimal Point, active-low)
//                  - seg[6:0] = a b c d e f g (active-low)
//
// Usage          : This file can be included in other Verilog
//                  modules where the 7-segment display constants
//                  are required. Simply use `include "SevenSegmentConst.v"
//                  to import the character mappings and constants.
//
// Author         : [Your Name]
// Date           : [Date]
// ******************************************************************

// Character mappings for the 7-segment display (with DP)
// The binary values represent segments a through g for each character,
// with DP included. The bit pattern is active-low, meaning 0 turns on
// the segment and 1 turns it off.
// - seg[7] = DP (Decimal Point, active-low)
// - seg[6:0] = a b c d e f g (active-low)

`ifndef _SEVEN_SEGMENT_CHARS_
`define _SEVEN_SEGMENT_CHARS_

// Numbers 0–9
localparam CHAR_0 = 8'b11111100;   // Segments: a b c d e f        (g off, DP off)
localparam CHAR_1 = 8'b01100000;   // Segments:   b c              (a d e f g off, DP off)
localparam CHAR_2 = 8'b11011010;   // Segments: a b   d e   g      (c f off, DP off)
localparam CHAR_3 = 8'b11110010;   // Segments: a b c d     g      (e f off, DP off)
localparam CHAR_4 = 8'b01100110;   // Segments:   b c     f g      (a d e off, DP off)
localparam CHAR_5 = 8'b10110110;   // Segments: a   c d   f g      (b e off, DP off)
localparam CHAR_6 = 8'b10111110;   // Segments: a   c d e f g      (b off, DP off)
localparam CHAR_7 = 8'b11100000;   // Segments: a b c              (d e f g off, DP off)
localparam CHAR_8 = 8'b11111110;   // Segments: a b c d e f g      (DP off)
localparam CHAR_9 = 8'b11110110;   // Segments: a b c d   f g      (e off, DP off)

// Letters A–Z
localparam CHAR_A = 8'b11101110;   // Segments: a b c   e f g      (d off, DP off)
localparam CHAR_B = 8'b00111110;   // Segments:     c d e f g      (a b off, DP off)
localparam CHAR_C = 8'b10011100;   // Segments: a     d e f        (b c g off, DP off)
localparam CHAR_D = 8'b01111010;   // Segments:   b c d e   g      (a f off, DP off)
localparam CHAR_E = 8'b10011110;   // Segments: a     d e f g      (b c off, DP off)
localparam CHAR_F = 8'b10001110;   // Segments: a     e f g        (b c d off, DP off)
localparam CHAR_G = 8'b10111100;   // Segments: a   c d e f        (b g off, DP off)
localparam CHAR_H = 8'b01101110;   // Segments:   b c   e f g      (a d off, DP off)
localparam CHAR_I = 8'b01100000;   // Segments:   b c              (same as 1, DP off)
localparam CHAR_J = 8'b01111000;   // Segments:   b c d e          (a f g off, DP off)
localparam CHAR_K = 8'b01101110;   // Segments:   b c   e f g      (same as H, stylized, DP off)
localparam CHAR_L = 8'b00011100;   // Segments:       d e f        (a b c g off, DP off)
localparam CHAR_M = 8'b10101010;   // Stylized M: a c e g          (b d f off, DP off)
localparam CHAR_N = 8'b11101100;   // Stylized N: a b c   e f      (d g off, DP off)
localparam CHAR_O = 8'b11111100;   // Segments: a b c d e f        (g off, same as 0, DP off)
localparam CHAR_P = 8'b11001110;   // Segments: a b     e f g      (c d off, DP off)
localparam CHAR_Q = 8'b11100110;   // Segments: a b c   f g        (d e off, DP off)
localparam CHAR_R = 8'b11001100;   // Stylized R: a b     e f      (c d g off, DP off)
localparam CHAR_S = 8'b10110110;   // Same as 5: a   c d   f g     (b e off, DP off)
localparam CHAR_T = 8'b00011110;   // Segments:     d e f g        (a b c off, DP off)
localparam CHAR_U = 8'b01111100;   // Segments:   b c d e f        (a g off, DP off)
localparam CHAR_V = 8'b01111100;   // Same as U, stylized V        (DP off)
localparam CHAR_W = 8'b01010101;   // Stylized W: a b   d f        (c e g off, DP off)
localparam CHAR_X = 8'b01101110;   // Same as H/K, stylized X      (DP off)
localparam CHAR_Y = 8'b01110110;   // Segments:   b c d   f g      (a e off, DP off)
localparam CHAR_Z = 8'b11011010;   // Same as 2: a b   d e   g     (c f off, DP off)

// Lowercase letters a–z
localparam CHAR_a = 8'b11101110;   // Same as A, stylized a        (DP off)
localparam CHAR_b = 8'b00111110;   // Same as B, stylized b        (DP off)
localparam CHAR_c = 8'b10011100;   // Same as C                    (DP off)
localparam CHAR_d = 8'b01111010;   // Same as D                    (DP off)
localparam CHAR_e = 8'b10011110;   // Same as E                    (DP off)
localparam CHAR_f = 8'b10001110;   // Same as F                    (DP off)
localparam CHAR_g = 8'b11110110;   // Same as 9, stylized g        (DP off)
localparam CHAR_h = 8'b01101110;   // Same as H, stylized h        (DP off)
localparam CHAR_i = 8'b01100000;   // Same as 1                    (DP off)
localparam CHAR_j = 8'b01111000;   // Same as J                    (DP off)
localparam CHAR_k = 8'b01101110;   // Same as H/K, stylized k      (DP off)
localparam CHAR_l = 8'b00011100;   // Same as L                    (DP off)
localparam CHAR_m = 8'b10101010;   // Same as M                    (DP off)
localparam CHAR_n = 8'b11101100;   // Same as N                    (DP off)
localparam CHAR_o = 8'b11111100;   // Same as 0/O                  (DP off)
localparam CHAR_p = 8'b11001110;   // Same as P                    (DP off)
localparam CHAR_q = 8'b11100110;   // Same as Q                    (DP off)
localparam CHAR_r = 8'b11001100;   // Same as R                    (DP off)
localparam CHAR_s = 8'b10110110;   // Same as S/5                  (DP off)
localparam CHAR_t = 8'b00011110;   // Same as T                    (DP off)
localparam CHAR_u = 8'b01111100;   // Same as U/V                  (DP off)
localparam CHAR_v = 8'b01111100;   // Same as u                    (DP off)
localparam CHAR_w = 8'b01010101;   // Same as W                    (DP off)
localparam CHAR_x = 8'b01101110;   // Same as X/H/K                (DP off)
localparam CHAR_y = 8'b01110110;   // Same as Y                    (DP off)
localparam CHAR_z = 8'b11011010;   // Segments: a b   d e   g      (c f off, DP off)

// Colon :
localparam CHAR_COLON = 8'b00000010;   // Segments:           g      (a–f off, DP off)

`endif