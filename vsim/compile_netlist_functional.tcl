set ROOT ".."

vlog -incr -sv \
    +define+FUNCTIONAL \
    +define+TARGET_NETLIST_OPENROAD \
    $ROOT/technology/verilog/ez130_8t.v \
    $ROOT/technology/verilog/sg13cmos5l_io.v \
    $ROOT/technology/verilog/sg13cmos5l_stdcell.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_64x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_256x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_core_behavioral.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_2P_core_behavioral_bm_bist_ideal.v \
    $ROOT/technology/verilog/RM_IHPSG13_2P_core_behavioral_ideal.v \
    $ROOT/ihp13/tc_sram_impl.sv \
    $ROOT/ihp13/empty_cells.v \
    $ROOT/ihp13/tc_clk.sv
    
# Compile Croc netlist
vlog -incr +acc $ROOT/openroad/out/main_chip.v 

# Compile Croc's testbench
vlog -incr -sv -svinputport=compat +define+TARGET_NETLIST_OPENROAD \
    $ROOT/rtl/tb/main_tb.sv
