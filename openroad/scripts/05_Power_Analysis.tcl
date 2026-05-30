

#set extRules ../ihp13/IHP_rcx_patterns.rules
#define_process_corner -ext_model_index 0 tt
#extract_parasitics -ext_model_file $extRules
#write_spef ./out/main_chip.spef
source scripts/init_tech.tcl
read_verilog out/main_chip.v
link_design main_chip
read_sdc out/main_chip.sdc
read_spef out/main_chip.spef

set_power_activity -input -activity 0.1
set_power_activity -input_port rst_ni -activity 0
# Can vary different corner (like ff)
report_power -corner tt
report_power -corner ff

set_power_activity -input_port rst_ni -activity 0
read_vcd -scope main_tb/i_dut ../vsim/main_chip.vcd

report_power -corner tt
report_power -corner ff

