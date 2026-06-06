#===============================================================
# Basys 3 Constraints File
# Description:
#     - Each port is assigned both IOSTANDARD (LVCMOS33) and PACKAGE_PIN
#     - IOSTANDARD may come **before or after** PACKAGE_PIN
#     - This file places PACKAGE_PIN first, then IOSTANDARD, for better grouping
#===============================================================

#============== Switch Inputs (SW[7:0]) ==============  
set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
set_property PACKAGE_PIN W15 [get_ports {SW[4]}]
set_property PACKAGE_PIN V15 [get_ports {SW[5]}]
set_property PACKAGE_PIN W14 [get_ports {SW[6]}]
set_property PACKAGE_PIN W13 [get_ports {SW[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0] SW[1] SW[2] SW[3] SW[4] SW[5] SW[6] SW[7]}]


#============== LED Outputs (LED[3:0]) ==============  
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0] LED[1] LED[2] LED[3]}]


#============== Clock Input ==============  
set_property PACKAGE_PIN W5  [get_ports {CLK}]
set_property IOSTANDARD LVCMOS33 [get_ports {CLK}]