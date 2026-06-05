`timescale 1ns / 1ps
//===================================================  
// Testbench: tb_SWLED  
// Description: Simple testbench to verify the behavior of  
//              the mySWLED module by toggling the switch (SW)  
//===================================================

module tb_SWLED();
   
    //-------------- Testbench Signals --------------
    // Outputs are always declared as wire in testbench
    wire LED;   // **Output**: Observed LED behavior
    // Inputs are always declared as reg in testbench
    reg SW;     // **Input**: Simulated switch (stimulus)
    
    //-------------- Instantiate Modules (CUT : Circuit Under Test) --------------
    SWLED CUT (LED, SW);                  // **Positional Port Mapping**
    //mySWLED CUT ( .LED(LED), .SW(SW) ); // Alternative Style (Named Port Mapping)  
    
    //-------------- Stimulus Generation --------------  
    /*
    initial begin
        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        SW = 1; #100;  // Set SW = 1 and hold for 100 ns  
        SW = 0;        // Set SW = 0 (end of simulation stimulus)  
    end
    */
    
    initial begin  
        $display("=== Starting Simulation ===");  

        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        SW = 1; #100;  // Set SW = 1 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        $display("=== Simulation Complete ===");  
        $finish;  // **End Simulation**
    end
     
endmodule // tb_SWLED

/*
`timescale 1ns / 1ps
    Time Precision in Verilog (timescale <unit> / <precision>)
    Time Precision defines the smallest resolution that the simulator will recognize for time calculations.
    It does not affect synthesis but controls how accurately delays are handled in simulation.
    The timescale directive at the top of your Verilog file is only for simulation purposes
    and does not affect actual hardware timing.
Breaking it Down:
    1ns (Time Unit) → This means each simulation time step is 1 nanosecond.
    1ps (Time Precision) → The smallest measurable time difference is 1 picosecond.
Why is it Needed?
    It tells the simulator how to interpret delay statements like #100.
    It ensures that all modules in the simulation use a consistent time scale.
    It does NOT affect the FPGA clock (100 MHz on Basys 3)
Notes:
    It does not affect FPGA hardware at all-it's ignored during synthesis.
    100 MHz clock has a time period of 10 ns.
    #5 clk=~clk would simulate a 100 MHz because. because total clock cycle = 5ns+5ns = 10ns
*/


    //-------------- Stimulus Generation --------------
    /*
    initial begin
        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        SW = 1; #100;  // Set SW = 1 and hold for 100 ns  
        SW = 0;        // Set SW = 0 (end of simulation stimulus)  
    end
    
    initial begin  
        $display("=== Starting Simulation ===");  

        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        SW = 1; #100;  // Set SW = 1 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        SW = 0; #100;  // Set SW = 0 and hold for 100 ns  
        $display("Time=%0t | SW=%b -> LED=%b", $time, SW, LED);

        $display("=== Simulation Complete ===");  
        $finish;  // **End Simulation**
    end
    */

