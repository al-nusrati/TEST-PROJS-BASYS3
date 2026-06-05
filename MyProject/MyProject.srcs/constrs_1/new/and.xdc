##===================================================
## Basys-3 XDC Constraints File for AND Gate Project
## Description: Maps 2 switches to AND gate inputs and 1 LED to output
##===================================================

## Clock signal (100MHz)
set_property PACKAGE_PIN W5 [get_ports CLK]							
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]

## Switches
set_property PACKAGE_PIN V17 [get_ports {SW[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
set_property PACKAGE_PIN V16 [get_ports {SW[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]

## LEDs
set_property PACKAGE_PIN U16 [get_ports LED]					
set_property IOSTANDARD LVCMOS33 [get_ports LED]

##===================================================
## Additional Switches (if needed for future expansion)
##===================================================
#set_property PACKAGE_PIN W16 [get_ports {SW[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
#set_property PACKAGE_PIN W17 [get_ports {SW[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
#set_property PACKAGE_PIN W15 [get_ports {SW[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[4]}]
#set_property PACKAGE_PIN V15 [get_ports {SW[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[5]}]
#set_property PACKAGE_PIN W14 [get_ports {SW[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[6]}]
#set_property PACKAGE_PIN W13 [get_ports {SW[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SW[7]}]

##===================================================
## Additional LEDs (if needed for future expansion)
##===================================================
#set_property PACKAGE_PIN E19 [get_ports {LED[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
#set_property PACKAGE_PIN U19 [get_ports {LED[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
#set_property PACKAGE_PIN V19 [get_ports {LED[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
#set_property PACKAGE_PIN W18 [get_ports {LED[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
#set_property PACKAGE_PIN U15 [get_ports {LED[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
#set_property PACKAGE_PIN U14 [get_ports {LED[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
#set_property PACKAGE_PIN V14 [get_ports {LED[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]