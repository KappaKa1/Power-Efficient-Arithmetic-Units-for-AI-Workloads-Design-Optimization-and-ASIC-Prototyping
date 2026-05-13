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

source scripts/power_connect.tcl
########################################################
# 01-01: Setting Core and Die Area
########################################################

set chipH    1916; # OR die height (top to bottom)
set chipW    2416; # OR die width (left to right)
set padD      180; # pad depth (edge to core)
set padW       80; # pad width (beachfront)
set padBond    70; # bonding pad size
set powerRing  80; # reserved space for power ring

# starting from the outside and working towards the core area on each side
set coreMargin [expr {$padD + $padBond + $powerRing}];

utl::report "Initialize Chip"
# coordinates are lower-left x and y, upper-right x and y
initialize_floorplan -die_area "0 0 $chipW $chipH" \
                     -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" \
                     -site "CoreSite"

########################################################
# 01-02: Padring
########################################################

# Modify the padring settings inside the paring.tcl file
source src/padring.tcl

########################################################
# 01-03: Macros 
########################################################

make_tracks

# Macro names
set bank0_sram0 "u_main/out_sram"
set bank1_sram0 "u_main/inp_sram_1"
set bank2_sram0 "u_main/inp_sram_2"

# SRAM Size
set RamMaster256x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_256x64_c2_bm_bist"]
set RamSize256x64_H   [ord::dbu_to_microns [$RamMaster256x64 getHeight]]
set RamSize256x64_W   [ord::dbu_to_microns [$RamMaster256x64 getWidth]]
set RamMaster64x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_64x64_c2_bm_bist"]
set RamSize64x64_H   [ord::dbu_to_microns [$RamMaster64x64 getHeight]]
set RamSize64x64_W   [ord::dbu_to_microns [$RamMaster64x64 getWidth]]

# Core size and coordinate
set coreArea      [ord::get_core_area]
set core_leftX    [lindex $coreArea 0]
set core_bottomY  [lindex $coreArea 1]
set core_rightX   [lindex $coreArea 2]
set core_topY     [lindex $coreArea 3]

# Placing macros
# use these for macro placement
set floorPaddingBottomY 60.0
set floorPaddingTopY    80.0
set floor_leftX         [expr $core_leftX]
set floor_bottomY       [expr $core_bottomY + $floorPaddingBottomY]
set floor_rightX        [expr $core_rightX]
set floor_topY          [expr $core_topY - $floorPaddingTopY]
set floor_midpointX     [expr $floor_leftX + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY     [expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]

set BOTTOM_RAM_0_OFFSET    31.46
# BANK0
set X [expr $floor_midpointX - $RamSize256x64_W/2]
set Y [expr $floor_topY - $RamSize256x64_H + $BOTTOM_RAM_0_OFFSET]
placeInstance $bank0_sram0 $X $Y MY

set BOTTOM_SRAM_SEPERATION 20
set BOTTOM_RAM_1_OFFSET    21.2
# Bank1
set X [expr $floor_leftX + $BOTTOM_SRAM_SEPERATION]
set Y [expr $floor_bottomY + $BOTTOM_RAM_1_OFFSET]
placeInstance $bank1_sram0 $X $Y MX

set BOTTOM_RAM_2_OFFSET    8.0
# BANK2 (center)
set X [expr $floor_rightX - $RamSize64x64_W - $BOTTOM_SRAM_SEPERATION]
set Y [expr $floor_bottomY + $BOTTOM_RAM_1_OFFSET]
placeInstance $bank2_sram0 $X $Y MX

# defined in init_tech.tcl
insertTapCells

cut_rows -halo_width_x 1 -halo_width_y 1
global_connect

########################################################
# 01-05: Power Grid
########################################################
source scripts/power_grid.tcl

save_checkpoint Floorplan_Final.floorplan
report_image "Floorplan_Final.floorplan" true
