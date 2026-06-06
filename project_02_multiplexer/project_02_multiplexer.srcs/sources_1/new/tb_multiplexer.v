`timescale 1ns / 1ps

module multiplexer_tb;
    reg A, B, X;
    wire out1;

    multiplexer uut (
        .out1(out1),
        .A(A),
        .B(B),
        .X(X)
    );

    initial begin
        $monitor("Time=%0t A=%b B=%b X=%b out1=%b", $time, A, B, X, out1);
        A = 0; B = 0; X = 0; #10;
        A = 0; B = 1; X = 0; #10;
        A = 1; B = 0; X = 1; #10;
        A = 1; B = 1; X = 1; #10;
        $finish;
    end
endmodule