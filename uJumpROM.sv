//-----------------------------------------------------------------------------
// Copyright 2022 Andrea Miele
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------------------

// uJumpROM.sv
// uJumpROM

// The micro-jump ROM implements the "decoding" of the RISC-V instructions
// The micro-jump ROM is addressed using a combination of RISC_V instruction fields OPCODE, FUNCT3 and FUNCT7 fields
// so that each implemented RISC-V instruction has a unique micro-jump ROM address.
// It contains the micro-code ROM addresses of the micro-instruction  corresponding to the decoded RISC-V instruction 

`include "controlDefs.sv"

module uJumpROM
(
    input logic [$clog2(`MICRO_JUMP_ROM_SIZE) - 1 : 0] addr,
    output logic [$clog2(`MICRO_INST_ROM_SIZE) - 1 : 0] out
);
always_comb
begin: uJumpROM
    case (addr)
        `OPCODE_LUI: out = {`MICRO_PC_LUI_ADDR};
        `OPCODE_AUIPC: out = {`MICRO_PC_AUIPC_ADDR};
        `OPCODE_JAL: out = {`MICRO_PC_JAL_ADDR};
        `OPCODE_JALR: out = {`MICRO_PC_JALR_ADDR};
        `OPCODE_BRANCH: out = {`MICRO_PC_BRANCH_CONDITION_ADDR};
        `OPCODE_LOAD: out = {`MICRO_PC_LOAD_COMP_ADDR_ADDR};
        `OPCODE_STORE: out = {`MICRO_PC_STORE_COMP_ADDR_ADDR};
        `OPCODE_I_TYPE: out = {`MICRO_PC_I_TYPE_ADDR};
        `OPCODE_R_TYPE: out = {`MICRO_PC_R_TYPE_ADDR};
        default: out = {`MICRO_PC_UNKNOWN_INST_EX_ADDR};
    endcase
end
endmodule
