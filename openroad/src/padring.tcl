# Copyright (c) 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

#
# - The "#pin no.: nn" comment shows the corresponding pin number for the package.

# [QFN48]
#                   package die
#   pins               48    56
#   I/O                40    40
#   Core power          4     4
#   Core ground         -     4
#   Pad  power          4     4
#   Pad  ground         -     4
#
# pad pitch (min)    90.0  90.0
#
# Chip geometry comes from floorplan.tcl
# Keep only the pad positioning/spacing here

set numPadsNorth 18
set numPadsSouth 18
set numPadsWest  14
set numPadsEast  14

set padD      180 ;# pad depth (edge to core)
set padW       80 ;# pad width (beachfront)
set padBond    70 ;# bonding pad size

set cornerToPad [expr {$padBond + $padD}]

make_io_sites \
  -horizontal_site sg13cmos5l_ioSite \
  -vertical_site   sg13cmos5l_ioSite \
  -corner_site     sg13cmos5l_ioSite \
  -offset $padBond \
  -rotation_horizontal R0 \
  -rotation_vertical   R0 \
  -rotation_corner     R0

# For chipW = 2416, chipH = 1916:
# cornerToPad = 250
# horizontal span = 2416 - 2*250 - 80 = 1836
# vertical span   = 1916 - 2*250 - 80 = 1336
# north/south pitch = 1836 / 17 = 108.0
# east/west pitch   = 1336 / 13 = 102.769230769

set southSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set northSpan  $southSpan
set westSpan   [expr {$chipH - 2*$cornerToPad - $padW}]
set eastSpan   $westSpan

set southPitch [expr {$southSpan / double($numPadsSouth - 1)}]
set northPitch [expr {$northSpan / double($numPadsNorth - 1)}]
set westPitch  102
set eastPitch  102

# SOUTH: left to right
set southStart $cornerToPad

# NORTH: right to left
set northStart [expr {$chipW - $cornerToPad - $padW}]

# WEST: top to bottom
set westStart [expr {$chipH - $cornerToPad - $padW}]

# EAST: bottom to top
set eastStart $cornerToPad

############################
# Edge: LEFT top to bottom #
############################

place_pad -row IO_WEST -location [expr {$westStart -  0*$westPitch}] "pad_vddio3"       ; # pin no:  1
place_pad -row IO_WEST -location [expr {$westStart -  1*$westPitch}] "pad_rdata_15_o"       ; # pin no:  2
place_pad -row IO_WEST -location [expr {$westStart -  2*$westPitch}] "pad_unused1_o"   ; # pin no:  3
place_pad -row IO_WEST -location [expr {$westStart -  3*$westPitch}] "pad_ack_o"    ; # pin no:  4
place_pad -row IO_WEST -location [expr {$westStart -  4*$westPitch}] "pad_ready_o"    ; # pin no:  5
place_pad -row IO_WEST -location [expr {$westStart -  5*$westPitch}] "pad_unused0_o"    ; # pin no:  6
place_pad -row IO_WEST -location [expr {$westStart -  6*$westPitch}] "pad_clk_i"        ; # pin no:  7
place_pad -row IO_WEST -location [expr {$westStart -  7*$westPitch}] "pad_rst_ni"       ; # pin no:  8
place_pad -row IO_WEST -location [expr {$westStart -  8*$westPitch}] "pad_finish_o"    ; # pin no:  9
place_pad -row IO_WEST -location [expr {$westStart -  9*$westPitch}] "pad_we_i"    ; # pin no: 10
place_pad -row IO_WEST -location [expr {$westStart - 10*$westPitch}] "pad_req_i"    ; # pin no: 11
place_pad -row IO_WEST -location [expr {$westStart - 11*$westPitch}] "pad_stop_compute_i"    ; # pin no: 12
place_pad -row IO_WEST -location [expr {$westStart - 12*$westPitch}] "pad_unused2_o"         ; # pin no: 13
place_pad -row IO_WEST -location [expr {$westStart - 13*$westPitch}] "pad_vdd0"         ; # pin no: 14
 
################################
# Edge: BOTTOM left to right   #
################################

place_pad -row IO_SOUTH -location [expr {$southStart +  0*$southPitch}] "pad_vss0"        ; # pin no:  1
place_pad -row IO_SOUTH -location [expr {$southStart +  1*$southPitch}] "pad_vssio0"        ; # pin no:  2
place_pad -row IO_SOUTH -location [expr {$southStart +  2*$southPitch}] "pad_vddio0"     ; # pin no:  3
place_pad -row IO_SOUTH -location [expr {$southStart +  3*$southPitch}] "pad_wdata_0_i"     ; # pin no:  4
place_pad -row IO_SOUTH -location [expr {$southStart +  4*$southPitch}] "pad_wdata_1_i"     ; # pin no:  5
place_pad -row IO_SOUTH -location [expr {$southStart +  5*$southPitch}] "pad_wdata_2_i"     ; # pin no:  6
place_pad -row IO_SOUTH -location [expr {$southStart +  6*$southPitch}] "pad_wdata_3_i"     ; # pin no:  7
place_pad -row IO_SOUTH -location [expr {$southStart +  7*$southPitch}] "pad_wdata_4_i"     ; # pin no:  8
place_pad -row IO_SOUTH -location [expr {$southStart +  8*$southPitch}] "pad_wdata_5_i"     ; # pin no:  9
place_pad -row IO_SOUTH -location [expr {$southStart +  9*$southPitch}] "pad_wdata_6_i"     ; # pin no: 10
place_pad -row IO_SOUTH -location [expr {$southStart + 10*$southPitch}] "pad_wdata_7_i"     ; # pin no: 11
place_pad -row IO_SOUTH -location [expr {$southStart + 11*$southPitch}] "pad_wdata_8_i"    ; # pin no: 12
place_pad -row IO_SOUTH -location [expr {$southStart + 12*$southPitch}] "pad_wdata_9_i"    ; # pin no: 13
place_pad -row IO_SOUTH -location [expr {$southStart + 13*$southPitch}] "pad_wdata_10_i"    ; # pin no: 14
place_pad -row IO_SOUTH -location [expr {$southStart + 14*$southPitch}] "pad_wdata_11_i"    ; # pin no: 15
place_pad -row IO_SOUTH -location [expr {$southStart + 15*$southPitch}] "pad_vdd1"    ; # pin no: 16
place_pad -row IO_SOUTH -location [expr {$southStart + 16*$southPitch}] "pad_vss1"          ; # pin no: 17
place_pad -row IO_SOUTH -location [expr {$southStart + 17*$southPitch}] "pad_vssio1"          ; # pin no: 18

################################
# Edge: RIGHT bottom to top    #
################################

place_pad -row IO_EAST -location [expr {$eastStart +  0*$eastPitch}] "pad_vddio1"       ; # pin no:  1
place_pad -row IO_EAST -location [expr {$eastStart +  1*$eastPitch}] "pad_wdata_12_i"       ; # pin no:  2
place_pad -row IO_EAST -location [expr {$eastStart +  2*$eastPitch}] "pad_wdata_13_i"   ; # pin no:  3
place_pad -row IO_EAST -location [expr {$eastStart +  3*$eastPitch}] "pad_wdata_14_i"        ; # pin no:  4
place_pad -row IO_EAST -location [expr {$eastStart +  4*$eastPitch}] "pad_wdata_15_i"         ; # pin no:  5
place_pad -row IO_EAST -location [expr {$eastStart +  5*$eastPitch}] "pad_rdata_0_o"    ; # pin no:  6
place_pad -row IO_EAST -location [expr {$eastStart +  6*$eastPitch}] "pad_rdata_1_o"    ; # pin no:  7
place_pad -row IO_EAST -location [expr {$eastStart +  7*$eastPitch}] "pad_rdata_2_o"    ; # pin no:  8
place_pad -row IO_EAST -location [expr {$eastStart +  8*$eastPitch}] "pad_rdata_3_o"      ; # pin no:  9
place_pad -row IO_EAST -location [expr {$eastStart +  9*$eastPitch}] "pad_rdata_4_o"        ; # pin no: 10
place_pad -row IO_EAST -location [expr {$eastStart + 10*$eastPitch}] "pad_rdata_5_o"     ; # pin no: 11
place_pad -row IO_EAST -location [expr {$eastStart + 11*$eastPitch}] "pad_rdata_6_o"    ; # pin no: 12
place_pad -row IO_EAST -location [expr {$eastStart + 12*$eastPitch}] "pad_unused3_o"         ; # pin no: 13
place_pad -row IO_EAST -location [expr {$eastStart + 13*$eastPitch}] "pad_vdd2"         ; # pin no: 14

###############################
# Edge: TOP right to left     #
###############################

place_pad -row IO_NORTH -location [expr {$northStart -  0*$northPitch}] "pad_vss2"        ; # pin no:  1
place_pad -row IO_NORTH -location [expr {$northStart -  1*$northPitch}] "pad_vssio2"        ; # pin no:  2
place_pad -row IO_NORTH -location [expr {$northStart -  2*$northPitch}] "pad_vddio2"     ; # pin no:  3
place_pad -row IO_NORTH -location [expr {$northStart -  3*$northPitch}] "pad_unused4_o"     ; # pin no:  4
place_pad -row IO_NORTH -location [expr {$northStart -  4*$northPitch}] "pad_unused5_o"     ; # pin no:  5
place_pad -row IO_NORTH -location [expr {$northStart -  5*$northPitch}] "pad_unused6_o"     ; # pin no:  6
place_pad -row IO_NORTH -location [expr {$northStart -  6*$northPitch}] "pad_unused7_o"     ; # pin no:  7
place_pad -row IO_NORTH -location [expr {$northStart -  7*$northPitch}] "pad_rdata_7_o"     ; # pin no:  8
place_pad -row IO_NORTH -location [expr {$northStart -  8*$northPitch}] "pad_rdata_8_o"     ; # pin no:  9
place_pad -row IO_NORTH -location [expr {$northStart -  9*$northPitch}] "pad_rdata_9_o"     ; # pin no: 10
place_pad -row IO_NORTH -location [expr {$northStart - 10*$northPitch}] "pad_rdata_10_o"     ; # pin no: 11
place_pad -row IO_NORTH -location [expr {$northStart - 11*$northPitch}] "pad_rdata_11_o"    ; # pin no: 12
place_pad -row IO_NORTH -location [expr {$northStart - 12*$northPitch}] "pad_rdata_12_o"    ; # pin no: 13
place_pad -row IO_NORTH -location [expr {$northStart - 13*$northPitch}] "pad_rdata_13_o"    ; # pin no: 14
place_pad -row IO_NORTH -location [expr {$northStart - 14*$northPitch}] "pad_rdata_14_o"    ; # pin no: 15
place_pad -row IO_NORTH -location [expr {$northStart - 15*$northPitch}] "pad_vdd3"    ; # pin no: 16
place_pad -row IO_NORTH -location [expr {$northStart - 16*$northPitch}] "pad_vss3"          ; # pin no: 17
place_pad -row IO_NORTH -location [expr {$northStart - 17*$northPitch}] "pad_vssio3"          ; # pin no: 18

#################
# Corner Cells  #
#################

place_corners $iocorner

#################
# Filler Cells  #
#################

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST  {*}$iofill
place_io_fill -row IO_EAST  {*}$iofill

#################
# Ring Signals  #
#################

connect_by_abutment

##################
# Bonding Pads   #
##################

place_bondpad -bond $bondPadCell -offset {5.0 -70.0} pad_*

##################
# Remove IO rows #
##################

remove_io_rows
