module alu_tb;
    parameter WIDTH = 16;  // Matching your ALU_WIDTH parameter
    
    logic [WIDTH-1:0] A, B;
    logic [1:0] op;
    logic [WIDTH-1:0] result;
    
    // Instantiate the ALU
    alu #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .op(op),
        .result(result)
    );
    
    initial begin
        // Test ADD operation
        A = 16'h000A;
        B = 16'h0003;
        op = 2'b00;
        #10;
        
        // Test SUB operation
        A = 16'h000F;
        B = 16'h0004;
        op = 2'b01;
        #10;
        
        // Test AND operation
        A = 16'h00FF;
        B = 16'h000F;
        op = 2'b10;
        #10;
        
        // Test OR operation
        A = 16'h00F0;
        B = 16'h000F;
        op = 2'b11;
        #10;
        
        // Test edge cases
        A = 16'hFFFF;
        B = 16'h0001;
        op = 2'b00;  // ADD: FFFF + 1 = 0000 (with carry out)
        #10;
        
        A = 16'h0000;
        B = 16'h0000;
        op = 2'b01;  // SUB: 0 - 0 = 0
        #10;
        
        // Test default case (undefined opcode)
        A = 16'h00AA;
        B = 16'h0055;
        op = 2'bxx;
        #10;
        
        $finish;
    end
endmodule