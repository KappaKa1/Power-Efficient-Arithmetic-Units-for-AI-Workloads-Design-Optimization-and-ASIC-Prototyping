#!/bin/bash

TB_FILE=$1
TOP_MODULE=$2
FILELIST="filelist.f"
OPEN_WAVE=${OPEN_WAVE:-1}

if [ -z "$TB_FILE" ] || [ -z "$TOP_MODULE" ]; then
    echo "Usage: $0 <testbench_file> <top_module>"
    exit 1
fi

echo "Testbench: $TB_FILE"
echo "Top module: $TOP_MODULE"

echo "Generating file list..."

: > "$FILELIST"

if [[ "${VERILATOR_DEFINES:-}" == *"TARGET_NETLIST_YOSYS"* ]]; then
    echo "Mode: Yosys netlist matmul simulation"

    # Include RTL/top/control/technology files, but exclude RTL GEMM/matmul implementations
'''    find ../rtl ../technology ../ihp13 ../yosys/out/main_chip_yosys.v\
      \( -type f -o -type l \) \
      \( -name "*.v" -o -name "*.sv" \) \
      ! -path "*/tb/*" \
      ! -name "*main*.sv" \
      ! -name "*matmul*.v" \
      ! -name "*matmul*.sv" \
      ! -name "*gemm*.v" \
      ! -name "*gemm*.sv" \
      | sort >> "$FILELIST"

    # Explicitly include only the synthesised GEMM/matmul netlists
    cat >> "$FILELIST" <<EOF
../yosys/out/DC_Default/baseline_gemm_4x4x4_4b_tc_netlist.v
../yosys/out/SM_Best_Power/matmul_4x4x4_int4_cw13_cst_rca_sm_no_enc_350mhz_netlist.v
../yosys/out/TC_Best_Area/matmul_4x4x4_int4_tc_cw13_dadda_han_carlson_fused_speed_netlist.v
../yosys/out/TC_Best_FMax/matmul_4x4x4_int4_tc_cw13_wallace_kogge_stone_fused_speed_netlist.v
../yosys/out/TC_Best_Power/matmul_4x4x4_int4_tc_cw13_dadda_prefix_rca_fused_area_netlist.v
../yosys/out/main_chip_yosys.v
EOF
'''
      find ../technology ../ihp13 ../yosys/out/main_chip_yosys.v\
      \( -type f -o -type l \) \
      \( -name "*.v" -o -name "*.sv" \) \
      ! -path "*/tb/*" \
      ! -name "*main*.sv" \
      | sort >> "$FILELIST"

else
    echo "Mode: RTL matmul simulation"

    # Include RTL/technology files only, not yosys/out
    find ../rtl ../technology ../ihp13 \
      \( -type f -o -type l \) \
      \( -name "*.v" -o -name "*.sv" \) \
      ! -path "*/tb/*" \
      | sort >> "$FILELIST"
fi

echo "File list:"
cat $FILELIST

echo ""
echo "Cleaning previous build..."
rm -rf obj_dir

echo ""
echo "Running Verilator..."

verilator $VERILATOR_DEFINES \
  -I./../rtl/common_cells/include \
  -f "$FILELIST" "$TB_FILE" \
  --top "$TOP_MODULE" \
  --binary \
  -Wno-fatal \
  --trace \
  --trace-structs \
  -j 8 

echo ""
echo "Build complete."

# ========================================
# Run the simulation executable
# ========================================

SIM_EXE="obj_dir/V$TOP_MODULE"

if [ ! -f "$SIM_EXE" ]; then
    echo "Simulation executable not found: $SIM_EXE"
    exit 1
fi

echo "Running simulation..."

LOG_FILE="output.txt"

./"$SIM_EXE" | tee -a "$LOG_FILE"

echo ""
echo "========================================"
echo "RESULT SUMMARY"
echo "========================================"

if grep -q "FAIL" "$LOG_FILE"; then
    echo "❌ TEST FAILED" | tee -a "$LOG_FILE"
elif grep -q "PASS" "$LOG_FILE"; then
    echo "✅ TEST PASSED" | tee -a "$LOG_FILE"
else
    echo "⚠️  UNKNOWN RESULT" | tee -a "$LOG_FILE"
fi

# ========================================
# Open waveform in GTKWave
# ========================================

# Detect waveform file (VCD or FST)
if [ -f "waveform.vcd" ]; then
    WAVE_FILE="waveform.vcd"
elif [ -f "waveform.fst" ]; then
    WAVE_FILE="waveform.fst"
else
    echo "Waveform file not found. Make sure your testbench has \$dumpfile and \$dumpvars."
    exit 1
fi

echo "Opening waveform in GTKWave..."
if [ "$OPEN_WAVE" -eq 1 ]; then
    echo "Opening waveform in GTKWave..."
    gtkwave "$WAVE_FILE"
else
    echo "Skipping waveform viewer"
fi
