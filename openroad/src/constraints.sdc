# Copyright 2024 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# Backend constraints

############
## Global ##
############

#source src/instances.tcl

# Not set in the liberty file of the EZ cells; limiting fanout often reduced routing stress
set_max_fanout 16 [current_design]

# Backend constraints for main_chip


#############################
## Driving Cells and Loads ##
#############################

# Default output load estimate in pF
set_load 15.0 [all_outputs]

# Drive all chip inputs as if coming from an output pad
set_driving_cell [all_inputs] -lib_cell sg13cmos5l_IOPadOut16mA -pin pad


##################
## Input Clocks ##
##################
puts "Clocks..."

# Target 100 MHz
set TCK_SYS 10.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]


##################################
## Clock Uncertainty/Transition ##
##################################

set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


#############
## SoC Ins ##
#############
puts "Input/Outputs..."

# Reset should propagate within one system clock cycle
set_input_delay -max [expr $TCK_SYS * 0.10] [get_ports rst_ni]
set_false_path -hold -from [get_ports rst_ni]
set_max_delay $TCK_SYS -from [get_ports rst_ni]


#####################
## Functional Inputs ##
#####################
puts "Functional inputs..."

set_input_delay  -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] \
  [get_ports {req_i we_i streamed_wdata_*_i}]
set_input_delay  -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] \
  [get_ports {req_i we_i streamed_wdata_*_i}]


######################
## Functional Outputs ##
######################
puts "Functional outputs..."

set_output_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] \
  [get_ports {ready_o finish_o ack_o streamed_rdata_*_o}]
set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] \
  [get_ports {ready_o finish_o ack_o streamed_rdata_*_o}]

# Optional: keep unused outputs in-cycle if they exist on the chip top
# set_output_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {unused*_o}]
# set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {unused*_o}]




