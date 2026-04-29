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
<p align="center"> <img src="images/verification_arch.png" width="600"> </p>
  
  In this project, we used **Verilator** and **GTKWave** to verify the functionality of the Device-Under-Test (DUT). The project deploys the verification architecture shown in the image above.
  
  Users can:
  * Verify only the DUT
  * Execute the full verification flow
  * Run multiple iterations by appending a number to the back of the command

  The table below details the files involved in the verification.
| File-name | Description |
|----------|----------|
| ```input_generator.py```  | Generates Test-Vectors (of size 16 x 4-bits) used in verification |
| ```golden_model.py```  | Produces the expected outputs of the DUT |
| ```main_tb.sv```  | Produces the actual outputs of the DUT, and compares it with the expected outputs  |
| ```output.txt```  | Details the result of the comparison |

  Run DUT-only Verification
```
</> Bash
./Scripts/run_dut.sh /scratch/Kai_Stuff/OpenROAD/rtl/tb/main_tb.sv main_tb
```
  Run Full Verification flow
```
</> Bash
verilator> ./Scripts/full_flow.sh /scratch/Kai_Stuff/OpenROAD/rtl/tb/main_tb.sv main_tb 1
```
The testbench also includes verification of the synthesized netlist from Yosys and OpenROAD. To verify synthesized results, prepend ```VERILATOR_DEFINES="-DTARGET_NETLIST_YOSYS"``` or ```VERILATOR_DEFINES="-DTARGET_NETLIST_YOSYS (not done)"```.

## Synthesis using Yosys
  This project uses 
