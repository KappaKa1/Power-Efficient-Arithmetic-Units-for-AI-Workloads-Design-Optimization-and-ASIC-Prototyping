# Power-Efficient-Arithmetic-Units-for-AI-Workloads-Design-Optimization-and-ASIC-Prototyping-

Important requirments to run the commands:
* The _technology_ folder must be populated with all the required files as shown in its requirements.txt
* The _ihp13_ folder must be populated with all the required files as shown in its requirements.txt
* The semantics of all folder names and location must not be changed

If you are running the commands through the ETH's account, please run the following command first:
```bash
$ oseda bash
```

## Using Verilator for Functional Analysis
<Image>
  
  The above image shows the verification architecture used in the project. The architecture produces new inputs every run using _input_generator.py_ and feeds it to both _golden_model.py_ and _main_tb.sv_. The results from both model are compared inside _main_tb.sv_ and produces an _output.txt_ which can be used to verify the outputs. You can either verify just the DUT without executing the full-flow, or you can run the full-flow multiple rounds by including the round number at the back. 

  To verify just the DUT using Verilator, please run the following command:
```bash
verilator> ./Scripts/run_dut.sh /scratch/Kai_Stuff/OpenROAD/rtl/tb/main_tb.sv main_tb
```
  To run the entire verification flow, please run the following command:
```bash
verilator> ./Scripts/full_flow.sh /scratch/Kai_Stuff/OpenROAD/rtl/tb/main_tb.sv main_tb 1
```
The testbench also includes verification of the synthesized netlist from Yosys and OpenROAD. To verify the netlists, add the argument ```bash VERILATOR_DEFINES="-DTARGET_NETLIST_YOSYS"``` or ```ash VERILATOR_DEFINES="-DTARGET_NETLIST_YOSYS"``` at the front.
