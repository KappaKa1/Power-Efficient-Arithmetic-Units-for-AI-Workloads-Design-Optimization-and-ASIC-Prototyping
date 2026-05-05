#!/bin/bash
set -e

TOP_MODULE=${1:-main_tb}
NUM_RUNS=${2:-1}

: > output.txt

for ((run=0; run<NUM_RUNS; run++)); do
    echo "========================================"
    echo "FULL VSIM FLOW RUN $run / $((NUM_RUNS-1))"
    echo "MODE=OPENROAD (forced)"
    echo "TOP_MODULE=$TOP_MODULE"
    echo "========================================"

    echo ""
    echo "1. Generating inputs"
    python3 ../Python/input_generator.py

    echo ""
    echo "2. Running golden model (MODE=openroad)"
    python3 ../Python/golden_model.py

    echo ""
    echo "3. Compiling OpenROAD netlist"
    vsim -c -do "source compile_netlist.tcl; exit" | tee -a output.txt

    echo ""
    echo "4. Running VSIM (GUI)"
    vsim -gui "$TOP_MODULE" \
        -t 1ns \
        -voptargs=+acc \
        -suppress vsim-3009 \
        -suppress vsim-8683 \
        -suppress vsim-8386 \
        -do "run -all"

    echo ""
    echo "Run $run complete"
done

echo ""
echo "All $NUM_RUNS runs complete."
