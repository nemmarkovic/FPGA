create_clock -period 10.000 -name virtual_clock

#set_input_delay -clock [get_clocks virtual_clock] -max -add_delay 3.000 [get_ports {i_vec[*]}]
#set_output_delay -clock [get_clocks virtual_clock] -max -add_delay 9.000 [get_ports {o_vec[*]}]
