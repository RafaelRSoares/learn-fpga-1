set_property PACKAGE_PIN H16 [get_ports pclk]
set_property IOSTANDARD LVCMOS33 [get_ports pclk]
create_clock -period 8.000 [get_ports pclk]

set_property PACKAGE_PIN R14 [get_ports D1]
set_property PACKAGE_PIN P14 [get_ports D2]
set_property PACKAGE_PIN N16 [get_ports D3]
set_property PACKAGE_PIN M14 [get_ports D4]
set_property IOSTANDARD LVCMOS33 [get_ports {D1 D2 D3 D4}]

set_property PACKAGE_PIN L15 [get_ports D5]
set_property IOSTANDARD LVCMOS33 [get_ports D5]

set_property PACKAGE_PIN D19 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]