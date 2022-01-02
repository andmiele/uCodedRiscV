# A simple micro-coded 32-bit RISC-V CPU
## Description
A simple micro-coded (micro-programmed control unit) multi-cycle 32-bit RISC-V CPU written in System Verilog.
It implements the entire RV32I Base Integer instruction set except the FENCE, ECALL and EBREAK
instructions ([RISC-V specifications](https://riscv.org/technical/specifications/)).
J-TYPE and S-TYPE instructions can generate a misaligned address exception according to the RV32I specifications.
A simple system (CPU + instruction memory + data memory) for testing is provided including a slightly modified 
version suitable for testing on an actual FPGA
in which an FPGA board LED can be memory mapped (the instruction memory is initialized by default with a hex
file containing a short program that periodically flips the a bit in memory)
## Control Unit
The control unit is micro-coded and uses 3 ROMs: a ROM for the actual micro-code instructions addressed
by the micro program counter register (uPC), 
a ROM holding the "micro-jump" addresses for the micro-PC register (decode-stage: "micro-address"
corresponds to the decoded RISC-V RV32I instruction type)
and one ROM that holds the ALU control commands for the decoded instruction (execute-stage)
![Datapath](https://github.com/andmiele/uCodedRiscV/blob/main/controlunit.jpg?raw=true)
## Instruction Latency
* LUI: 3 clock cycles
* AUIPC: 3 clock cycles
* J-TYPE: 3 clock cycles
* R-TYPE: 3 clock cycles
* I-TYPE: 4 clock cycles
* B-TYPE: 4 clock cycles
* S-TYPE: 4 clock cycles
## Datapath
The Datapath is very simple: a single ALU is used for the instruction execute-stage (effective address, 
branch condition and arithmetic computations) 
as well as incrementing the program counter register (PC) and the micro program counter register (uPC).
An immediate operand unit computes all possible immediate operands for all instruction types that use an immediate value.
A next program counter register (NPC) is used to hold the value of PC + 4 until the PC is actually updated with that value
or a computed address.
Instruction memory (connected to the instruction register (IR)), data memory and dual-ported register file are assumed to be
readable and writable in one clock cycle
![Datapath](https://github.com/andmiele/uCodedRiscV/blob/main/datapath.jpg?raw=true)

