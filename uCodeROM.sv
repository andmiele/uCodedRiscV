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

// uCodeROM.sv
// uCodeROM 

`include "controlDefs.sv"

module uCodeROM
(
    input logic [$clog2(`MICRO_INST_ROM_SIZE) - 1 : 0] addr,
    output logic [`MICRO_INST_ROM_WIDTH - 1 : 0] out
);
always_comb
begin: iROM
    case (addr)
        // UNKNOWN INSTRUCTION
        // 0 - UNKNOWN INSTRUCTION, DO NOTHING 
        `MICRO_PC_UNKNOWN_INST_EX_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_ALU, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_RESET, `ALU_CTL_SEL_NOP,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_NOP};
        // 1 - MISALIGNED ADDRESS EXCEPTION , DO NOTHING 
        `MICRO_PC_MISALIGNED_ADDRESS_EX_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_ALU, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_RESET, `ALU_CTL_SEL_NOP,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_NOP};
        //RESET SEQUENCE:
        // 2 - RESET 0: load NPC with RESET PC address
        `MICRO_PC_RESET_0_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_ALU, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_RESET, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_INC};
        // 3 - RESET 1: load PC with NPC value (NO_BRANCH_SEL acts as NOP for npc)
        `MICRO_PC_RESET_1_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_RESET, `ALU_CTL_SEL_NOP,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_INC};

        // 4 - FETCH: read instruction memory, write IR
        `MICRO_PC_FETCH_ADDR: out = {`IR_WRITE, `PC_SEL_NOP, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_4, `ALU_CTL_SEL_NOP,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_READ, `MICRO_PC_SEL_INC};
        // 5 - DECODE: increment NPC by 4
        `MICRO_PC_DECODE_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_ALU, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_PC, `ALU_B_SEL_4, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_JUMP};

        // 6 - LUI (U type), immed, rd: uPC = Fetch address, write RF (select ALU), PC = NPC = NPC + 4
        // LUI
        `MICRO_PC_LUI_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_ALU, 
            `ALU_A_SEL_ZERO, `ALU_B_SEL_U_IMMED, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 7 - AUIPC (U type), immed, rd: uPC = Fetch address, write RF (select ALU), PC = NPC = NPC + 4
        // AUIPC
        `MICRO_PC_AUIPC_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_ALU, 
            `ALU_A_SEL_PC, `ALU_B_SEL_U_IMMED, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 8 - JAL (J type), immed, rd: uPC = Fetch address, write RF (select ALU), rd = NPC = PC + 4, PC = PC + I
        // JAL
        `MICRO_PC_JAL_ADDR: out = {`IR_NOP, `PC_SEL_ALU, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_NPC, 
            `ALU_A_SEL_PC, `ALU_B_SEL_J_IMMED, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH_OR_MISALIGNED_ADDRESS_EX};      

        // 9 - JALR (I-type), immed, rd: uPC = Fetch address, write RF (select ALU), rd = NPC = PC + 4, PC = (RS + I) & 0 
        // JALR
        `MICRO_PC_JALR_ADDR: out = {`IR_NOP, `PC_SEL_ALU, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_NPC, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_I_IMMED, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH_OR_MISALIGNED_ADDRESS_EX};    

        // 10 - BRANCH 0, 2 regs: uPC = uPC + 1, do not write RF (select ALU)
        // BRANCH compute condition
        `MICRO_PC_BRANCH_CONDITION_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_RS2, `ALU_CTL_SEL_ROM,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_INC};        

        // 11 - BRANCH 1, 2 regs: uPC = Fetch address, write RF (select ALU) if taken PC = PC + I else PC = NPC = PC + 4
        // BRANCH compute address and load PC
        `MICRO_PC_BRANCH_PC_SEL_ADDR: out = {`IR_NOP, `PC_SEL_BR, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_PC, `ALU_B_SEL_B_IMMED, `ALU_CTL_SEL_ADD,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 12 - LOAD, compute address, I-type, 1 reg: uPC = Fetch address, do not write RF, PC = NPC = PC + 4
        // LB, LH, LW, LBU, LHU compute address, initiate memory read
        `MICRO_PC_LOAD_COMP_ADDR_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_I_IMMED, `ALU_CTL_SEL_ADD, 
        `DMEM_NO_WRITE, `DMEM_READ, `IMEM_NO_READ, `MICRO_PC_SEL_INC_OR_MISALIGNED_ADDRESS_EX};

        // 13 - LOAD, write-back, I-type, 1 reg: uPC = Fetch address, write RF
        // LB, LH, LW, LBU, LHU write-back value from dMem
        `MICRO_PC_LOAD_WRITE_BACK_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_MEM, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_I_IMMED, `ALU_CTL_SEL_ADD, 
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 14 - STORE, compute address, S-type, 2 regs: uPC = Fetch address, do not write RF, PC = NPC = PC + 4
        // SB, SH, SW compute address, initiate memory read
        `MICRO_PC_STORE_COMP_ADDR_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_S_IMMED, `ALU_CTL_SEL_ADD, 
        `DMEM_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_INC_OR_MISALIGNED_ADDRESS_EX};

        // 15 - STORE, complete write to dMem, S-type, 2 regs: uPC = Fetch address, do not write RF
        // SB, LH, SW, LBU, complete write to dMem
        `MICRO_PC_STORE_WRITE_DMEM_ADDR: out = {`IR_NOP, `PC_SEL_NOP, `NPC_SEL_NOP, `RF_NOP, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_S_IMMED, `ALU_CTL_SEL_ADD, 
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 16 - I type, 1 reg: uPC = Fetch address, write RF (select ALU), PC = NPC = NPC + 4
        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        `MICRO_PC_I_TYPE_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_I_IMMED, `ALU_CTL_SEL_ROM,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};

        // 17 - R type, 2 regs: uPC = Fetch address, write RF (select ALU), PC = NPC = NPC + 4
        // ADD, SUB, SLL, SLT, SLTU, XOR
        `MICRO_PC_R_TYPE_ADDR: out = {`IR_NOP, `PC_SEL_NPC, `NPC_SEL_NOP, `RF_WRITE, `WB_SEL_ALU, 
            `ALU_A_SEL_RS1, `ALU_B_SEL_RS2, `ALU_CTL_SEL_ROM,
        `DMEM_NO_WRITE, `DMEM_NO_READ, `IMEM_NO_READ, `MICRO_PC_SEL_FETCH};
		  default: out = {`MICRO_INST_ROM_WIDTH{1'b0}};

    endcase
end

endmodule
