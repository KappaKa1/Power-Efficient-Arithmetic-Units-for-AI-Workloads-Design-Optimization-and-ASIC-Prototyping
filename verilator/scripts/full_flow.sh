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

    echo "1. Generating inputs (seed=$run)"
    python3 ./../Python/input_generator.py --seed $run

    echo "3. Running golden model for TC-to-TC"
    python3 ./../Python/golden_model.py --mode UNSIGNED

    echo "4. Running golden model for TC-to-TC"
    python3 ./../Python/golden_model.py --mode TC_TC

    echo "5. Running golden model for SM-to-TC"
    python3 ./../Python/golden_model.py --mode SM_TC

    echo "6. Running Verilator simulation"
    OPEN_WAVE=0 ./scripts/run_dut.sh "$TB_FILE" "$TOP_MODULE"

    echo "Run $run complete"
    echo ""
done

echo "All $NUM_RUNS runs complete."
