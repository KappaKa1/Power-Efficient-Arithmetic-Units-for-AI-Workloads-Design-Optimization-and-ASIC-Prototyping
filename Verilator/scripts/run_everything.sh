#!/bin/bash

TB_FILE=$1
TOP_MODULE=$2
FILELIST="filelist.f"

if [ -z "$TB_FILE" ] || [ -z "$TOP_MODULE" ]; then
    echo "Usage: $0 <testbench_file> <top_module>"
    exit 1
fi

echo "Testbench: $TB_FILE"
echo "Top module: $TOP_MODULE"

echo "Generating file list..."

find . \( -type f -o -type l \) \( -name "*.v" -o -name "*.sv" \) \
  ! -path "./tb/*" \
  | sort > "$FILELIST"

echo "File list:"
cat $FILELIST

echo ""
echo "Cleaning previous build..."
rm -rf obj_dir

echo ""
echo "Running Verilator..."

verilator -f "$FILELIST" "$TB_FILE" --top "$TOP_MODULE" --binary -Wno-fatal --trace --trace-structs

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
./"$SIM_EXE"

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
gtkwave "$WAVE_FILE"
