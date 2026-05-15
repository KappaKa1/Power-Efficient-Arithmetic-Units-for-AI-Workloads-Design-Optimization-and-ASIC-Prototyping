
###############################################################################
# Stage 03: CLOCK TREE SYNTHESIS
###############################################################################

set_dont_use $dont_use_cells

########################################################
# 03-01: Clock Tree Synthesis
########################################################

set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
unset_dont_touch $clock_nets

# Repaird any inverters with fanout > 1
repair_clock_inverters

# CTS buffer list (defined in init_tech.tcl)
# ctsBuf and ctsBufRoot are set based on PDK
clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot -sink_clustering_enable -repair_clock_nets

repair_clock_nets


########################################################
# 03-02: Fixing CTS
########################################################

estimate_parasitics -placement
set_propagated_clock [all_clocks]
repair_design -verbose

repair_timing -setup -skip_pin_swap -verbose

detailed_placement

check_placement -verbose

estimate_parasitics -placement
###############################################################################
# Stage 03 complete: Checkpoint saved to ${save_dir}/03_${proj_name}.cts.zip
###############################################################################

report_cts -out_file CTS_Final.cts.rpt
report_metrics "CTS_Final.cts"
