# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# This flows assumes it is beign executed in the yosys/ directory
# but just to be sure, we go there
if {[info script] ne ""} {
    cd "[file dirname [info script]]/../"
}

# Configuration variables are in yosys_common
source scripts/yosys_common.tcl

# ABC logic optimization script
set abc_script [processAbcScript scripts/abc-opt.script]

# read liberty files and prepare some variables
source scripts/init_tech.tcl

# read in all the matmuls
yosys read_verilog ./Synthesized_MATMULS/DC_Default/baseline_gemm_4x4x4_4b_tc_netlist.v
yosys read_verilog ./Synthesized_MATMULS/SM_Best_Power/matmul_4x4x4_int4_cw13_accum_hc_sm_no_enc_350mhz_netlist.v
yosys read_verilog ./Synthesized_MATMULS/SM_Best_Area/matmul_4x4x4_int4_cw13_cst_rca_sm_no_enc_350mhz_netlist.v
yosys read_verilog ./Synthesized_MATMULS/TC_Best_Area/matmul_4x4x4_int4_tc_cw13_dadda_han_carlson_fused_speed_netlist.v
yosys read_verilog ./Synthesized_MATMULS/TC_Best_FMax/matmul_4x4x4_int4_tc_cw13_wallace_kogge_stone_fused_speed_netlist.v
yosys read_verilog ./Synthesized_MATMULS/TC_Best_Power/matmul_4x4x4_int4_tc_cw13_dadda_prefix_rca_fused_area_netlist.v
#yosys read_verilog ./Synthesized_MATMULS/Yosys_Baseline/.v

yosys plugin -i slang.so
# default from yosys_common.tcl: top_design=croc_chip; sv_flist=./croc.flist
yosys read_slang --top $top_design -f $sv_flist \
        --compat-mode --keep-hierarchy \
        --allow-use-before-declare --ignore-unknown-modules

# preserve hierarchy of selected modules/instances
# 't' means type as in select all instances of this type/module
# yosys-slang uniquifies all modules with the naming scheme:
# <module-name>$<instance-name> -> match for t:<module-name>$$
yosys setattr -set keep_hierarchy 1 "t:main$*"
yosys setattr -set keep_hierarchy 1 "t:matmul*"
yosys setattr -set keep_hierarchy 1 "t:baseline_gemm_4x4x4_4b*"

yosys setattr -set dont_touch 1 "t:matmul*"
yosys setattr -set dont_touch 1 "t:baseline_gemm_4x4x4_4b*"

# blackbox modules (applies the *blackbox* attribute)
yosys blackbox "t:tc_sram_blackbox$*"
yosys blackbox "t:RM_IHPSG13_$*"

# map dont_touch attribute commonly applied to output-nets of async regs to keep
yosys attrmap -rename dont_touch keep
yosys attrmap -tocase keep -imap keep="true" keep=1
# copy the keep attribute to their driving cells (retain on net for debugging)
yosys attrmvcp -copy -attr keep


# -----------------------------------------------------------------------------
# this section heavily borrows from the yosys synth command:
# synth - check
yosys hierarchy -top $top_design
yosys check
yosys proc
yosys tee -q -o "${rep_dir}/${proj_name}_elaborated.rpt" stat
yosys write_verilog -norename -noexpr -attr2comment ${tmp_dir}/${proj_name}_yosys_elaborated.v

# synth - coarse:
# similar to yosys synth -run coarse -noalumacc
yosys opt_expr
yosys opt -noff
yosys fsm
yosys wreduce 
yosys peepopt
yosys opt_clean
yosys opt -full
yosys booth
yosys share
yosys opt
yosys memory -nomap
yosys memory_map
yosys opt -fast

yosys opt_dff -sat -nodffe -nosdff
yosys share
yosys opt -full
yosys clean -purge

yosys clean -purge
yosys write_verilog -norename -noexpr ${tmp_dir}/${proj_name}_yosys_abstract.v
yosys tee -q -o "${rep_dir}/${proj_name}_abstract.rpt" stat -width -tech cmos

yosys techmap
yosys opt -fast
yosys clean -purge


# -----------------------------------------------------------------------------
yosys tee -q -o "${rep_dir}/${proj_name}_generic.rpt" stat -tech cmos

# flatten all hierarchy except marked modules
yosys flatten
yosys write_verilog -norename ${tmp_dir}/${proj_name}_flatten.v
# yosys opt_hier

yosys clean -purge


# -----------------------------------------------------------------------------
# Preserve flip-flop names as far as possible
# split internal nets
yosys splitnets -format __v
# rename DFFs from the driven signal
yosys rename -wire -suffix _reg t:*DFF*
yosys write_verilog -norename ${tmp_dir}/${proj_name}_yosys_rename.v
yosys select -write ${rep_dir}/${proj_name}_registers.rpt t:*DFF*
# rename all other cells
yosys autoname t:*DFF* %n
yosys clean -purge

# print paths to important instances (hierarchy and naming is final here)
yosys select -write ${rep_dir}/${proj_name}_registers.rpt t:*DFF*
yosys tee -q -o ${rep_dir}/${proj_name}_instances.rpt  select -list "t:RM_IHPSG13_*"
yosys tee -q -a ${rep_dir}/${proj_name}_instances.rpt  select -list "t:tc_sram_blackbox$*"


# -----------------------------------------------------------------------------
# mapping to technology

# first map flip-flops
yosys dfflibmap {*}$tech_cells_args

# then perform bit-level optimization and mapping on all combinational clouds in ABC
# target period (per optimized block/module) in picoseconds
set period_ps 6670
# pre-process abc file (written to tmp directory)
set abc_comb_script   [processAbcScript scripts/abc-opt.script]
# call ABC
yosys abc {*}$tech_cells_args -D $period_ps -script $abc_comb_script -constr src/abc.constr {*}$dont_use_args -showtmp

yosys clean -purge


# -----------------------------------------------------------------------------
# prep for openROAD
yosys write_verilog -norename -noexpr -attr2comment ${out_dir}/netlist_debug.v

yosys splitnets -ports -format __v
yosys setundef -zero
yosys clean -purge
# map constants to tie cells
yosys hilomap -singleton -hicell {*}$tech_cell_tiehi -locell {*}$tech_cell_tielo

# final reports
yosys tee -q -o "${rep_dir}/${proj_name}_synth.rpt" check
yosys tee -q -o "${rep_dir}/${proj_name}_area.rpt" stat -top $top_design {*}$liberty_args
yosys tee -q -o "${rep_dir}/${proj_name}_area_logic.rpt" stat -top $top_design {*}$tech_cells_args

# final netlist
yosys write_verilog -noattr -noexpr -nohex -nodec ${out_dir}/${proj_name}_yosys.v

