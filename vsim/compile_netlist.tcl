set ROOT ".."

# Compile testbench's dependencies RTL files
vlog -incr -sv -svinputport=compat \
    +define+SIMULATION \
    +define+TARGET_NETLIST_OPENROAD \
    +incdir+$ROOT/rtl/common_cells/include \
    +incdir+$ROOT/rtl/apb/include \
    +incdir+$ROOT/rtl/idma/include \
    +incdir+$ROOT/rtl/obi/include \
    +incdir+$ROOT/rtl/cve2/include \
    $ROOT/rtl/common_cells/binary_to_gray.sv \
    $ROOT/rtl/common_cells/cb_filter_pkg.sv \
    $ROOT/rtl/common_cells/cc_onehot.sv \
    $ROOT/rtl/common_cells/cdc_reset_ctrlr_pkg.sv \
    $ROOT/rtl/common_cells/cf_math_pkg.sv \
    $ROOT/rtl/common_cells/clk_int_div.sv \
    $ROOT/rtl/common_cells/credit_counter.sv \
    $ROOT/rtl/common_cells/delta_counter.sv \
    $ROOT/rtl/common_cells/ecc_pkg.sv \
    $ROOT/rtl/common_cells/edge_propagator_tx.sv \
    $ROOT/rtl/common_cells/exp_backoff.sv \
    $ROOT/rtl/common_cells/fifo_v3.sv \
    $ROOT/rtl/common_cells/gray_to_binary.sv \
    $ROOT/rtl/common_cells/heaviside.sv \
    $ROOT/rtl/common_cells/isochronous_4phase_handshake.sv \
    $ROOT/rtl/common_cells/isochronous_spill_register.sv \
    $ROOT/rtl/common_cells/lfsr.sv \
    $ROOT/rtl/common_cells/lfsr_16bit.sv \
    $ROOT/rtl/common_cells/lfsr_8bit.sv \
    $ROOT/rtl/common_cells/lossy_valid_to_stream.sv \
    $ROOT/rtl/common_cells/mv_filter.sv \
    $ROOT/rtl/common_cells/onehot_to_bin.sv \
    $ROOT/rtl/common_cells/plru_tree.sv \
    $ROOT/rtl/common_cells/passthrough_stream_fifo.sv \
    $ROOT/rtl/common_cells/popcount.sv \
    $ROOT/rtl/common_cells/ring_buffer.sv \
    $ROOT/rtl/common_cells/rr_arb_tree.sv \
    $ROOT/rtl/common_cells/rstgen_bypass.sv \
    $ROOT/rtl/common_cells/serial_deglitch.sv \
    $ROOT/rtl/common_cells/shift_reg.sv \
    $ROOT/rtl/common_cells/shift_reg_gated.sv \
    $ROOT/rtl/common_cells/spill_register_flushable.sv \
    $ROOT/rtl/common_cells/stream_demux.sv \
    $ROOT/rtl/common_cells/stream_filter.sv \
    $ROOT/rtl/common_cells/stream_fork.sv \
    $ROOT/rtl/common_cells/stream_intf.sv \
    $ROOT/rtl/common_cells/stream_join_dynamic.sv \
    $ROOT/rtl/common_cells/stream_mux.sv \
    $ROOT/rtl/common_cells/stream_throttle.sv \
    $ROOT/rtl/common_cells/sub_per_hash.sv \
    $ROOT/rtl/common_cells/sync.sv \
    $ROOT/rtl/common_cells/sync_wedge.sv \
    $ROOT/rtl/common_cells/unread.sv \
    $ROOT/rtl/common_cells/read.sv \
    $ROOT/rtl/common_cells/addr_decode_dync.sv \
    $ROOT/rtl/common_cells/boxcar.sv \
    $ROOT/rtl/common_cells/cdc_2phase.sv \
    $ROOT/rtl/common_cells/cdc_4phase.sv \
    $ROOT/rtl/common_cells/clk_int_div_static.sv \
    $ROOT/rtl/common_cells/trip_counter.sv \
    $ROOT/rtl/common_cells/addr_decode.sv \
    $ROOT/rtl/common_cells/addr_decode_napot.sv \
    $ROOT/rtl/common_cells/multiaddr_decode.sv \
    $ROOT/rtl/common_cells/cb_filter.sv \
    $ROOT/rtl/common_cells/cdc_fifo_2phase.sv \
    $ROOT/rtl/common_cells/clk_mux_glitch_free.sv \
    $ROOT/rtl/common_cells/counter.sv \
    $ROOT/rtl/common_cells/ecc_decode.sv \
    $ROOT/rtl/common_cells/ecc_encode.sv \
    $ROOT/rtl/common_cells/edge_detect.sv \
    $ROOT/rtl/common_cells/lzc.sv \
    $ROOT/rtl/common_cells/max_counter.sv \
    $ROOT/rtl/common_cells/rstgen.sv \
    $ROOT/rtl/common_cells/spill_register.sv \
    $ROOT/rtl/common_cells/stream_delay.sv \
    $ROOT/rtl/common_cells/stream_fifo.sv \
    $ROOT/rtl/common_cells/stream_fork_dynamic.sv \
    $ROOT/rtl/common_cells/stream_join.sv \
    $ROOT/rtl/common_cells/cdc_reset_ctrlr.sv \
    $ROOT/rtl/common_cells/cdc_fifo_gray.sv \
    $ROOT/rtl/common_cells/fall_through_register.sv \
    $ROOT/rtl/common_cells/id_queue.sv \
    $ROOT/rtl/common_cells/stream_to_mem.sv \
    $ROOT/rtl/common_cells/stream_arbiter_flushable.sv \
    $ROOT/rtl/common_cells/stream_fifo_optimal_wrap.sv \
    $ROOT/rtl/common_cells/stream_register.sv \
    $ROOT/rtl/common_cells/stream_xbar.sv \
    $ROOT/rtl/common_cells/cdc_fifo_gray_clearable.sv \
    $ROOT/rtl/common_cells/cdc_2phase_clearable.sv \
    $ROOT/rtl/common_cells/mem_to_banks_detailed.sv \
    $ROOT/rtl/common_cells/stream_arbiter.sv \
    $ROOT/rtl/common_cells/stream_omega_net.sv \
    $ROOT/rtl/common_cells/mem_to_banks.sv \
    $ROOT/rtl/MATMULS/matmul_4x4x4_int4_tc_cw13_4to2_sklansky_fused_area.v \
    $ROOT/rtl/MATMULS/matmul_4x4x4_int4_tc_cw13_4to2_sklansky_fused_speed.v \
    $ROOT/rtl/my_file/clock_gate.sv \
    $ROOT/rtl/my_file/encoder.sv \
    $ROOT/rtl/my_file/GEMM_control.sv  \
    $ROOT/rtl/my_file/GEMM_CORE.sv \
    $ROOT/rtl/my_file/main.sv \
    $ROOT/rtl/my_file/mux2to1.sv \
    $ROOT/rtl/my_file/mux5to1.sv \
    $ROOT/rtl/my_file/pack14to16_signext.sv \
    $ROOT/rtl/my_file/shift_register_out.sv \
    $ROOT/rtl/my_file/shift_registers_in.sv \
    $ROOT/rtl/my_file/SRAM_controller.sv \
    $ROOT/rtl/my_file/tc_to_sm.sv 

vlog -incr -sv \
    +define+FUNCTIONAL \
    +define+TARGET_NETLIST_OPENROAD \
    $ROOT/technology/verilog/ez130_8t.v \
    $ROOT/technology/verilog/sg13cmos5l_io.v \
    $ROOT/ihp13/empty_cells.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_64x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_256x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_512x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_1024x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_2048x64_c2_bm_bist.v \
    $ROOT/technology/verilog/RM_IHPSG13_1P_256x48_c2_bm_bist.v \
    $ROOT/ihp13/tc_sram_impl.sv \
    $ROOT/ihp13/tc_clk.sv

# Compile Croc netlist
vlog -incr $ROOT/openroad/out/main_chip.v 

# Compile Croc's testbench
vlog -incr -sv -svinputport=compat +define+TARGET_NETLIST_OPENROAD \
    $ROOT/rtl/tb/main_tb.sv
