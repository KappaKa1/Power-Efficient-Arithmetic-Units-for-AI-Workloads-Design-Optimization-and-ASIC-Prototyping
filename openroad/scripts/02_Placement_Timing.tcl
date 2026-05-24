###############################################################################
# Stage 02 PLACING AND TIMING 
###############################################################################
# To estimate delay with parasitics, use this command and press update 
set_wire_rc -clock -layer Metal3
set_wire_rc -signal -layer Metal3
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
global_placement -density 0.50

# Only includes all cell placement (like SRAM)
report_cell_usage

# To estimate delay with parasitics, use this command and press update 
estimate_parasitics -placement

# Repair Design
repair_design -verbose

# Repair Setup, done later
repair_timing -setup -verbose

global_placement -density 0.50 \
                 -routability_driven \
                 -routability_check_overflow 0.30 \
                 -timing_driven

###############################################################################
# 02-03: Detailed Placement
###############################################################################

# Detailed Placement to remove overlapped cells
detailed_placement

# (CHECK) Optimize Mirroring 
optimize_mirroring
estimate_parasitics -placement

report_metrics "Placement_Final.placed"
