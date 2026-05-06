#!/bin/bash
set -e

TB_FILE=$1
TOP_MODULE=$2
NUM_RUNS=${3:-1}

if [ -z "$TB_FILE" ] || [ -z "$TOP_MODULE" ]; then
    echo "Usage: $0 <testbench_file> <top_module> [num_runs]"
    exit 1
fi
: > output.txt

for ((run=0; run<NUM_RUNS; run++)); do
    echo "========================================"
    echo "FULL FLOW RUN $run / $((NUM_RUNS-1))"
    echo "========================================"

    echo ""
    echo "1. Generating inputs"
    python3 ../Python/input_generator.py

    echo ""
    echo "2. Running golden model"
    python3 ../Python/golden_model.py

    echo ""
    echo "3. Running Verilator simulation"
    OPEN_WAVE=0 ./Scripts/run_dut.sh "$TB_FILE" "$TOP_MODULE"

    echo ""
    echo "Run $run complete"
done

echo ""
echo "All $NUM_RUNS runs complete."
