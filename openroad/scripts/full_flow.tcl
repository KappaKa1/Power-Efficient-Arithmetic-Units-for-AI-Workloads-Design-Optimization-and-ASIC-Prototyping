###############################################################################
# Just Change the value of the variables
###############################################################################
set PROJECT_NAME ""
set TOP_MODULE ""
# !!! Importantly the Yosys file must be named properly, "{PROJECT_NAME}_yosys.v"

###############################################################################
# Setup (Gotten from Croc's "startup.tcl"
###############################################################################
source scripts/startup.tcl 
#-project ${PROJ_NAME} -top_module ${TOP_MODULE}

###############################################################################
# Stage 01: FLOORPLAN, Similar to Lab
###############################################################################

# Read Netlist
read_verilog $netlist
link_design $top_design

# Read Constraint
read_sdc src/constraints.sdc

# Check Constraints
check_setup -verbose                                     >> ${report_dir}/01-01_${proj_name}_checks.rpt
report_checks -unconstrained -format end -no_line_splits >> ${report_dir}/01-01_${proj_name}_checks.rpt
report_checks -format end -no_line_splits                >> ${report_dir}/01-01_${proj_name}_checks.rpt
report_checks -format end -no_line_splits                >> ${report_dir}/01-01_${proj_name}_checks.rpt

########################################################
# 01-01: Setting Core and Die Area
########################################################

set SealRingSize 42;
set BondPadSize 70;
set PadDriverHeight 180;
set PadWidth 80; #dont know where got it
set PowerRingSpacing 80;
set ActualDieWidth 2500;
set ActualDieHeight 2500;

set ORDieWidth [expr {$ActualDieWidth - 2*$SealRingSize}];
set ORDieHeight [expr {$ActualDieHeight - 2*$SealRingSize}];

set ORCoreWidth [expr {$ORDieWidth - 2*$BondPadSize - 2*$PadDriverHeight - 2*$PowerRingSpacing}];
set ORCoreHeight [expr {$ORDieHeight - 2*$BondPadSize - 2*$PadDriverHeight - 2*$PowerRingSpacing}];

set chipH    $ORDieWidth
set chipW    $ORDieWidth

set coreMargin [expr {$PadDriverHeight + $BondPadSize + $PowerRingSpacing}];

initialize_floorplan -die_area "0 0 $chipW $chipH" -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" -site "CoreSite"

########################################################
# 01-02: Padring
########################################################

# Modify the padring settings inside the paring.tcl file
source src/padring.tcl

########################################################
# 01-03: Macros 
########################################################

# Macro names
set bank0_sram0 u_main.out_sram
set bank1_sram0 u_main.inp_sram_1
set bank2_sram0 u_main.inp_sram_2

# SRAM Size
set RamMaster256x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_256x64_c2_bm_bist"]
set RamSize256x64_W   [ord::dbu_to_microns [$RamMaster256x64 getWidth]]
set RamSize256x64_H   [ord::dbu_to_microns [$RamMaster256x64 getHeight]]

# Core size and coordinate
set coreArea      [ord::get_core_area]
set core_leftX    [lindex $coreArea 0]
set core_bottomY  [lindex $coreArea 1]
set core_rightX   [lindex $coreArea 2]
set core_topY     [lindex $coreArea 3]

# Reference Location
set floorPaddingX      12.0
set floorPaddingY      12.0
set floor_leftX       [expr $core_leftX + $floorPaddingX]
set floor_bottomY     [expr $core_bottomY + $floorPaddingY]
set floor_rightX      [expr $core_rightX - $floorPaddingX]
set floor_topY        [expr $core_topY - $floorPaddingY]
set floor_midpointX   [expr $floor_leftX + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY   [expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]

# BANK0
set X [expr $floor_midpointX - $RamSize256x64_W/2]
set Y [expr $floor_topY - $RamSize256x64_H]
placeInstance $bank0_sram0 $X $Y R0

# Bank1
set X [expr $floor_leftX]
set Y [expr $floor_bottomY]
placeInstance $bank1_sram0 $X $Y MX

# BANK2 (center)
set X [expr $floor_rightX - $RamSize256x64_W]
set Y [expr $floor_bottomY]
placeInstance $bank2_sram0 $X $Y MX

cut_rows -halo_width_x 1 -halo_width_y 1

########################################################
# 01-04: Global Connection (CHECK)
########################################################

# Defining Global Connection
source scripts/power_connect.tcl

make_tracks

insertTapCells

########################################################
# 01-05: Power Grid
########################################################
source scripts/power_grid.tcl

save_checkpoint Floorplan_Final.floorplan
report_image "Floorplan_Final.floorplan" true

pdngen -failed_via_report ${report_dir}/01_${proj_name}_pdngen.rpt

###############################################################################
# Stage 02 PLACING AND TIMING 
###############################################################################

# load_checkpoint Floorplan_Final.floorplan
set_dont_use $dont_use_cells
set_thread_count 8

########################################################
# 02-01: Initial Repair Netlist
########################################################

# (CHECK THE REST HERE)
# Don't touch clock-tree related nets during repair_timing
 set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
 set_dont_touch $clock_nets

# Repair Tie Fanouts
repair_tie_fanout $tieHiPin 
repair_tie_fanout $tieLoPin 

# Remove Buffers
remove_buffers

# Repair the design
repair_design -verbose

# To estimate delay with parasitics, use this command and press update 
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal4

########################################################
# 02-02: Global Placement
########################################################

# global_placement parameters:
# density:            In every part of the chip, about N% of the area is occupied by standard cells
# routability_driven: Reduce density target when there are a lot of wires in an area
# check_overflow:     Higher means routability starts being considered earlier in placement
#                     too early -> very dense regions, too late -> little to no effect
# timing_driven:      Prioritize near-critical timing paths (reduce their length)

# First global_placement 
#global_placement
global_placement -density 0.60 -routability_driven -routability_check_overflow 0.30 -timing_driven

# Only includes all cell placement (like SRAM)
report_cell_usage

# Only include Active std cells, but does not include macros (SRAM)
# report_metrics "Placement_First_Glob.gpl1"
# report_image "Placement_First_Glob.gpl1" true true
# save_checkpoint Placement_First_Glob.gpl1

# To print report violations, can use these commands
# puts "Vio: max_slew:[sta::max_slew_violation_count]  max_fanout:[sta::max_fanout_violation_count]  max_cap:[sta::max_capacitance_violation_count]"
# report_check_types

# To estimate delay with parasitics, use this command and press update 
estimate_parasitics -placement

# Repair Design
repair_design -verbose
# save_checkpoint Placement_First_Glob_with_Rep.gpl1_fix

# Repair Setup, done later
repair_timing -setup -verbose
# save_checkpoint Placement_First_Glob_with_Rep_Time.gpl1_repaired


# Actual Placement used in Croc's chip
# global_placement -density 0.60 -routability_driven -routability_check_overflow 0.30 -timing_driven
# report_metrics "Placement_Glob_Actual.gpl2"
# report_image "Placement_Glob_Actual.gpl2" true true
# save_checkpoint Placement_Glob_Actual.gpl2

###############################################################################
# 02-03: Detailed Placement
###############################################################################

# Detailed Placement to remove overlapped cells
detailed_placement

# (CHECK) Optimize Mirroring 
optimize_mirroring

report_metrics "Placement_Final.placed"
report_image "Placement_Final.placed" true true
save_checkpoint Placement_Final.placed

###############################################################################
# Stage 03: CLOCK TREE SYNTHESIS
###############################################################################

# load_checkpoint Placement_Final.placed

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

# To check quality of CTS, run this
# report_cts
# report_clock_latency -clock clk_sys
# report_design_area
# report_power -corner tt
# or use report_metrics

# report_cts -out_file CTS_Initial.cts.rpt
# report_metrics "CTS_Initial.grt"
# report_image "CTS_Initial.grt" true false false true
# save_checkpoint ROUTING_After_Global_Route.grt

########################################################
# 03-02: Fixing CTS
########################################################

estimate_parasitics -placement
set_propagated_clock [all_clocks]
# report_checks -path_group clk_sys
repair_design -verbose

repair_timing -setup -skip_pin_swap -verbose

detailed_placement

check_placement -verbose

###############################################################################
# Stage 03 complete: Checkpoint saved to ${save_dir}/03_${proj_name}.cts.zip
###############################################################################

report_cts -out_file CTS_Final.cts.rpt
report_metrics "CTS_Final.cts"
report_image "CTS_Final.cts" true false true
save_checkpoint CTS_Final.cts

###############################################################################
# Stage 04: ROUTING
###############################################################################

# load_checkpoint CTS_Final.cts

###############################################################################
# 04-01: Global Route
###############################################################################

# Sets which layer to do signal and clock routing
set_routing_layers -signal Metal2-Metal4 -clock Metal2-Metal4

# Peform global routing. If routing is too congested, does not mean detailed routing will fail. But if detailed routing produces many violation, we may need to revisit global routing and adjust layer usage.
# global_route -guide_file ${report_dir}/04_${proj_name}_route.guide -congestion_report_file ${report_dir}/04_${proj_name}_route_congestionrpt -allow_congestion, from croc
global_route -congestion_report_file reports/congestion.rpt -allow_congestion

# Use this to estimate parasitics after global routing
estimate_parasitics -global_routing

# Fix the Design
repair_design -verbose

# Fix the Timing Violations
repair_timing -setup -verbose -repair_tns 100
repair_timing -hold -hold_margin 0.1 -verbose -repair_tns 100

# Identify issue
global_route -start_incremental
detailed_placement
global_route -end_incremental

# Should run parasitics again as new routing
estimate_parasitics -global_routing

report_metrics "ROUTING_Initial_Fixed.grt_repaired"
report_image "ROUTING_Initial_Fixed.grt_repaired" true true false true
save_checkpoint ROUTING_Initial_Fixed.grt_repaired

###############################################################################
# 04-01: Fixing Antenna
###############################################################################

# Check for any Antenna Violation
# check_antennas

# Repaird the Antenna Violation
repair_antennas

# To view the diodes inserted for the antenna, execute the code
# select -type Inst -name ANTENNA_1

###############################################################################
# 04-02: Detailed Routing & Filler Placement
###############################################################################

set_thread_count 8

detailed_route -output_drc reports/croc_route_drc.rpt -droute_end_iter 15 -clean_patches -verbose 1

filler_placement $stdfill

global_connect

save_checkpoint Routing_Final.routed
report_metrics "Routing_Final.routed"
report_image "Routing_Final.routed" true false false true

###############################################################################
# 04-03: Outputing the design
###############################################################################

# Contains information regarding the physical layout of the design
write_def out/croc.def

# Normal netlist file containing additional cells we inserted (like buffers)
write_verilog out/croc.v

# The LVS netlist that includes power and ground
write_verilog -include_pwr_gnd out/croc_lvs.v

# The SDC file which contains the timing constraints specified during the design process
write_sdc out/croc.sdc

# The ODB Database that stores the complete state of the design
write_db out/croc.odb



