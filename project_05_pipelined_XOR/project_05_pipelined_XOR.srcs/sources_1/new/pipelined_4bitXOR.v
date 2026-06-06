//===================================================  
// Module: pipelined_4bitXOR  
// Description: 3-Stage Pipelined XOR using 8 Switches and 4 LEDs  
//              - Stage 1: Input Registering (Capturing Inputs)  
//              - Stage 2: XOR Computation  
//              - Stage 3: Output Registering (Driving LEDs)  
//===================================================  

module pipelined_4bitXOR (
    input wire CLK,          // 100MHz system clock (Basys 3)
    input wire [7:0] SW,     // 8-bit Input Switches (SW[7:0])
    output reg [3:0] LED     // 4-bit Output LEDs (LED[3:0])
);

    //-------------- Pipeline Registers --------------  
    reg [3:0] stage1_a;  // Stage 1 Register: Lower 4 Bits of Input
    reg [3:0] stage1_b;  // Stage 1 Register: Upper 4 Bits of Input
    reg [3:0] stage2_out; // Stage 2 Register: XOR Computation Output

    //===================================================  
    // Stage 1: Input Registering (Capturing Inputs)  
    // - Stores switch values into registers at each clock cycle  
    // - Ensures stable data for further processing  
    //===================================================  
    always @(posedge CLK) begin
        stage1_a <= SW[3:0];  // Capture Lower 4 Bits from Switches
        stage1_b <= SW[7:4];  // Capture Upper 4 Bits from Switches
    end

    //===================================================  
    // Stage 2: XOR Computation  
    // - Performs bitwise XOR operation on registered inputs  
    // - Output is stored in a pipeline register to maintain timing  
    //===================================================  
    always @(posedge CLK) begin
        stage2_out <= stage1_a ^ stage1_b;  // Compute XOR of Captured Inputs
    end

    //===================================================  
    // Stage 3: Output Registering (Driving LEDs)  
    // - Registers XOR result before driving LEDs  
    // - Ensures stable and synchronized output  
    //===================================================  
    always @(posedge CLK) begin
        LED <= stage2_out;  // Drive LEDs with XOR Result
    end

endmodule // pipelined_4bitXOR

//===================================================  
// Explanation:  
// - 3-Stage Pipelining Implementation:  
//   - Stage 1 (Input Registering): Captures input switches into registers  
//   - Stage 2 (XOR Computation): Computes XOR of stored values  
//   - Stage 3 (Output Registering): Registers computed XOR before driving LEDs  
// - Pipeline Effect:  
//   - Data flows sequentially through each stage at every clock cycle  
//   - Reduces combinational delay, improving timing and performance  
//===================================================



/*
    //***************************************************  
    // Debouncing Registers and Parameters  
    //***************************************************  
    reg [3:0] debounced_a;    // Debounced lower 4 bits of switches  
    reg [3:0] debounced_b;    // Debounced upper 4 bits of switches  
    reg [15:0] debounce_cnt_a; // Debounce counter for lower 4 bits  
    reg [15:0] debounce_cnt_b; // Debounce counter for upper 4 bits  
    reg stable_a;             // Stable signal for lower 4 bits  
    reg stable_b;             // Stable signal for upper 4 bits  
    
    // Debounce Counter Parameters  
    parameter DEBOUNCE_THRESHOLD = 16'hFFFF; // Max value for debounce counter
    
    //***************************************************  
    // Stage 1: Debouncing and Input Registering  
    //***************************************************  
    always @(posedge CLK) begin
        // Debounce Lower 4 Bits (SW[3:0])  
        if (SW[3:0] != debounced_a) begin
            debounce_cnt_a <= debounce_cnt_a + 1;  // Increment counter  
            if (debounce_cnt_a == DEBOUNCE_THRESHOLD) begin
                debounced_a <= SW[3:0];  // Update debounced value  
                stable_a <= 1;           // Mark as stable  
            end
        end else begin
            debounce_cnt_a <= 0; // Reset counter if no change  
        end
    
        // Debounce Upper 4 Bits (SW[7:4])  
        if (SW[7:4] != debounced_b) begin
            debounce_cnt_b <= debounce_cnt_b + 1;  // Increment counter  
            if (debounce_cnt_b == DEBOUNCE_THRESHOLD) begin
                debounced_b <= SW[7:4];  // Update debounced value  
                stable_b <= 1;           // Mark as stable  
            end
        end else begin
            debounce_cnt_b <= 0; // Reset counter if no change  
        end
    end
    
    //***************************************************  
    // Stage 2: Input Registering (After Debouncing)  
    //***************************************************  
    always @(posedge CLK) begin
        if (stable_a) begin
            stage1_a <= debounced_a;  // Capture debounced lower 4 bits
        end
        if (stable_b) begin
            stage1_b <= debounced_b;  // Capture debounced upper 4 bits
        end
    end
*/
