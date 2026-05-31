	#!/bin/bash
set -e
 
TOP_MODULE=${1:-main_tb}
NUM_RUNS=${2:-1}
GUI=${3:-0}  # pass 1 as third argument to open GUI: ./full_flow.sh main_tb 1 1
SIM_MODE=${4:-functional}
 
: > output.txt
 
for ((run=0; run<NUM_RUNS; run++)); do
    echo "========================================"
    echo "FULL VSIM FLOW RUN $run / $((NUM_RUNS-1))"
    echo "TOP_MODULE=$TOP_MODULE"
    echo "SIM_MODE=$SIM_MODE"
    echo "========================================"
 
    echo "1. Generating inputs (seed=$run)"
    python3 ./../Python/input_generator.py --seed $run
 
    echo ""
    echo "2. Running golden model"
    python3 ./../Python/golden_model.py
 
    echo ""
    echo "3. Compiling OpenROAD netlist"
    if [ "$SIM_MODE" = "functional" ]; then
        echo "Compiling FUNCTIONAL netlist"
        vsim -c -do "source compile_netlist_functional.tcl; exit" \
            | tee -a output.txt

        VSIM_EXTRA_ARGS=""

    else
        echo "Compiling TIMING netlist"
        vsim -c -do "source compile_netlist_timing.tcl; exit" \
            | tee -a output.txt

        VSIM_EXTRA_ARGS="-sdfmax /main_tb/i_dut=./../openroad/out/main_chip.sdf \
                         -sdfnoerror"
    fi
 
    echo ""
    
    
# we can do +notimingchecks to see more errors, we get "Failed to find matching specify module path for IOPATH.". But they all come from the SRAM.
    if [ "$GUI" = "1" ]; then
        echo "4. Running VSIM (GUI)"

        vsim -gui "$TOP_MODULE" \
            -t 1ns \
            -voptargs=+acc \
            $VSIM_EXTRA_ARGS \
            -suppress vsim-3009 \
            -suppress vsim-8683 \
            -suppress vsim-8386 \
            -l vsim_run_${run}.log

    else
        echo "4. Running VSIM (CLI)"

        vsim -c "$TOP_MODULE" \
            -t 1ns \
            -voptargs=+acc \
            $VSIM_EXTRA_ARGS \
            -suppress vsim-3009 \
            -suppress vsim-8683 \
            -suppress vsim-8386 \
            -l vsim_run_${run}.log \
            -do "run -all; quit" \
            | tee -a output.txt
    fi
 
    echo ""
    echo "Run $run complete"
done
 
echo ""
echo "All $NUM_RUNS runs complete."
