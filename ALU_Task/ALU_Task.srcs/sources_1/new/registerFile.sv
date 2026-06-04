module register_file #(
    parameter WIDTH = 8,
    parameter DEPTH = 4
)(
    input logic                 clk,
    input logic                 regwrite,   
    input logic [1:0]           rs1_in,     
    input logic [1:0]           rs2_in,     
    input logic [1:0]           rd_in,      
    input logic [WIDTH-1:0]     data_dest,  
    output logic [WIDTH-1:0]    rs1_out,    
    output logic [WIDTH-1:0]    rs2_out     
);

    logic [WIDTH-1:0] regs [0:DEPTH-1];

    // Initialize register file (x0 is hardwired to 0)
    initial begin
        regs[0] = {WIDTH{1'b0}};  // x0 is always 0 (read-only)
        // Optionally initialize other registers here or use $readmem
    end

    // Write operation - occurs on positive clock edge
    always_ff @(posedge clk) begin
        if (regwrite) begin
            // Only write to registers x1, x2, x3 (rd_in != 2'b00)
            if (rd_in != 2'b00) begin
                regs[rd_in] <= data_dest;
            end
        end
    end

    // Read operations - combinational
    always_comb begin
        // x0 is always 0 (read-only)
        rs1_out = (rs1_in == 2'b00) ? {WIDTH{1'b0}} : regs[rs1_in];
        rs2_out = (rs2_in == 2'b00) ? {WIDTH{1'b0}} : regs[rs2_in];
    end

endmodule