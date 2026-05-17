
###############################################################################
# Stage 04: ROUTING
###############################################################################

###############################################################################
# 04-01: Global Route
###############################################################################

# Sets which layer to do signal and clock routing
set_global_routing_layer_adjustment TopMetal1 0.20
set_routing_layers -signal Metal2-Metal4 -clock Metal2-Metal4

# Peform global routing. If routing is too congested, does not mean detailed routing will fail. But if detailed routing produces many violation, we may need to revisit global routing and adjust layer usage.
utl::report "Global route"
global_route -congestion_report_file reports/congestion.rpt -allow_congestion

# Use this to estimate parasitics after global routing
estimate_parasitics -global_routing

# Fix the Design
repair_design -verbose


# Fix the Timing Violations
repair_timing -setup -verbose -repair_tns 100
repair_timing -hold -hold_margin 0.4 -verbose -repair_tns 100
# change it back to 0.4 later

# Identify issue
global_route -start_incremental
detailed_placement

# Route only the modified net by DPL
global_route -end_incremental \
            -guide_file ${report_dir}/04_${proj_name}_route.guide \
            -congestion_report_file ${report_dir}/04_${proj_name}_route_congestion.rpt \
            -verbose

# Should run parasitics again as new routing
estimate_parasitics -global_routing

report_metrics "ROUTING_Initial_Fixed.grt_repaired"

###############################################################################
# 04-01: Fixing Antenna
###############################################################################

# Repaird the Antenna Violation
repair_antennas -ratio_margin 30 -iterations 5

###############################################################################
# 04-02: Detailed Routing & Filler Placement
###############################################################################

set_thread_count 8

detailed_route -output_drc reports/main_chip_route_drc.rpt -droute_end_iter 15 -clean_patches -verbose 1

filler_placement $stdfill

global_connect

report_metrics "Routing_Final.routed"

###############################################################################
# 04-03: Outputing the design
###############################################################################

# Contains information regarding the physical layout of the design
write_def out/main_chip.def

# Normal netlist file containing additional cells we inserted (like buffers)
write_verilog out/main_chip.v

# The LVS netlist that includes power and ground
write_verilog -include_pwr_gnd -remove_cells "$stdfill bondpad*" out/main_chip_lvs.v

# The SDC file which contains the timing constraints specified during the design process
write_sdc out/main_chip.sdc

# The ODB Database that stores the complete state of the design
write_db out/main_chip.odb

write_sdf -corner tt out/main_chip.sdf

