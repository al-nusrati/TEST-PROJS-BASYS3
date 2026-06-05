//===================================================  
// Testbench for AND Module
//===================================================  
`timescale 1ns / 1ps

module tb_and();

   reg [1:0] SW;
   wire LED;

   AND DUT (.SW(SW), .LED(LED));

   initial begin
      SW = 2'b00; #10;
      SW = 2'b01; #10;
      SW = 2'b10; #10;
      //SW = 2'b11; #10;
      SW = 2'b01; #10;
      SW = 2'b11; #10;
      
      $finish;
   end

endmodule