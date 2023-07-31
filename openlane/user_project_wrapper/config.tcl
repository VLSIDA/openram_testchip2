# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0


set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
#set ::env(STD_CELL_LIBRARY_OPT) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v \
    $script_dir/../../verilog/rtl/sky130_sram_2kbyte_32b_2bank.v \
	$script_dir/../../verilog/rtl/wishbone_wrapper.v \
	$script_dir/../../verilog/rtl/wishbone_wrapper_dp.v \
	$script_dir/../../verilog/rtl/wishbone_ram_mux.v \
	$script_dir/../../verilog/rtl/openram_testchip.v"

## Clock configurations
set ::env(CLOCK_PORT) {io_in\[17\]}
set ::env(CLOCK_NET) "CONTROL_LOGIC.clk"
set ::env(RESET_PORT) {io_in\[15\] wb_rst_i}

set ::env(CLOCK_PERIOD) "30"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

## Internal Macros
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg


### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/openram_defines.v \
	$script_dir/../../verilog/rtl/sky130_sram_1kbyte_1rw1r_32x256_8.v \
	$script_dir/../../verilog/rtl/sky130_sram_1kbyte_1rw1r_8x1024_8.v \
	$script_dir/../../verilog/rtl/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	$script_dir/../../verilog/rtl/sky130_sram_4kbyte_1rw1r_32x1024_8.v \
	$script_dir/../../verilog/rtl/sky130_sram_1kbyte_1rw_32x256_8.v \
	$script_dir/../../verilog/rtl/sky130_sram_2kbyte_1rw_32x512_8.v \
	$script_dir/../../verilog/rtl/rram_test.v"

set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef \
	$script_dir/../../lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef \
	$script_dir/../../lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	$script_dir/../../lef/sky130_sram_4kbyte_1rw1r_32x1024_8.lef \
	$script_dir/../../lef/sky130_sram_1kbyte_1rw_32x256_8.lef \
	$script_dir/../../lef/sky130_sram_2kbyte_1rw_32x512_8.lef \
	$script_dir/../../lef/rram_test.lef"


set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds \
	$script_dir/../../gds/sky130_sram_1kbyte_1rw1r_8x1024_8.gds \
	$script_dir/../../gds/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
	$script_dir/../../gds/sky130_sram_4kbyte_1rw1r_32x1024_8.gds \
	$script_dir/../../gds/sky130_sram_1kbyte_1rw_32x256_8.gds \
	$script_dir/../../gds/sky130_sram_2kbyte_1rw_32x512_8.gds \
	$script_dir/../../gds/rram_test.gds"

# set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}

set ::env(FP_PDN_CHECK_NODES) 0
# Power config

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

# Placement config
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(PL_DIAMOND_SEARCH_HEIGHT) 500
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(GLB_RT_ADJUSTMENT) 0.25
#set ::env(GRT_ADJUSTMENT) 0.25
set ::env(PL_TARGET_DENSITY) 0.25

#set ::env(MAGIC_DRC_USE_GDS) 0

set ::env(RUN_KLAYOUT_DRC) 0
set ::env(RUN_KLAYOUT_XOR) 0

set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(FILL_INSERTION) 1

#set ::env(DIODE_INSERTION_STRATEGY) 0
#set ::env(FILL_INSERTION) 0
# The following is because there are no std cells in the example wrapper project.
#set ::env(SYNTH_TOP_LEVEL) 1
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

#set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
#set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
#set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
#set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

#set ::env(DIODE_INSERTION_STRATEGY) 0
#set ::env(FILL_INSERTION) 0
#set ::env(TAP_DECAP_INSERTION) 0
# set ::env(CLOCK_TREE_SYNTH) 0
set ::env(RUN_CVC) 0
set ::env(RUN_MAGIC_DRC) 0

set ::env(MAGIC_DRC_USE_GDS) 0
set ::env(QUIT_ON_MAGIC_DRC) 0
set ::env(PRIMARY_SIGNOFF_TOOL) klayout
