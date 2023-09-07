## Clock configurations
set ::env(CLOCK_PORT) "io_in\[6\]"
set ::env(CLOCK_NET) "CONTROL_LOGIC.clk"
set ::env(RESET_PORT) "io_in\[5\]"

set ::env(CLOCK_PERIOD) "60"

set ::env(IO_PCT) 0.2
set ::env(SYNTH_DRIVING_CELL) "sky130_fd_sc_hd__inv_1"
set ::env(SYNTH_DRIVING_CELL_PIN) "Y"
set ::env(SYNTH_CAP_LOAD) "33.5"
set ::env(SYNTH_MAX_FANOUT) "4"

create_clock [get_ports $::env(CLOCK_PORT)]  -name $::env(CLOCK_PORT)  -period $::env(CLOCK_PERIOD)
set_propagated_clock [get_ports $::env(CLOCK_PORT)]

set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

set clk_indx [lsearch [all_inputs] [get_port $::env(CLOCK_PORT)]]
set rst_indx [lsearch [all_inputs] [get_port $::env(RESET_PORT)]]
set all_inputs_wo_clk [lreplace [all_inputs] $clk_indx $clk_indx]
set all_inputs_wo_clk_rst [lreplace $all_inputs_wo_clk $rst_indx $rst_indx]
#set all_inputs_wo_clk_rst $all_inputs_wo_clk

#set_dont_touch [get_ports "analog_io*"] 

# correct resetn
#set_input_delay $input_delay_value  -clock [get_clocks $::env(CLOCK_PORT)] $all_inputs_wo_clk_rst
#set_input_delay 0.0 -clock [get_clocks $::env(CLOCK_PORT)] [get_port $::env(RESET_PORT)]
set_output_delay $output_delay_value  -clock [get_clocks $::env(CLOCK_PORT)] [all_outputs]

# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

report_clock_skew
