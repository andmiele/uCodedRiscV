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

// controlDefs.sv
// instruction decoding and control unit defines

`ifndef _CONTROL_DEFS_
`define _CONTROL_DEFS_

`define GET_OPCODE(inst)  inst[6 : 0]
`define GET_FUNCT3(inst)  inst[14 : 12]
`define GET_FUNCT7(inst)  inst[31 : 25]

// RISC V 7-bit opcodes
`define OPCODE_LUI    7'b0110111
`define OPCODE_AUIPC  7'b0010111
`define OPCODE_JAL    7'b1101111
`define OPCODE_JALR   7'b1100111
`define OPCODE_BRANCH 7'b1100011
`define OPCODE_LOAD   7'b0000011
`define OPCODE_STORE  7'b0100011
`define OPCODE_R_TYPE 7'b0110011
`define OPCODE_I_TYPE 7'b0010011

`define OPCODE_MASK 32'h7f 
`define FUNCT3_OPCODE_MASK 32'h707f 
`define FUNCT7_FUNCT3_OPCODE_MASK 32'hfc00707f

`define IR_LUI         {25'b0, OPCODE_LUI}
`define IR_LUI_MASK    OPCODE_MASK  

`define IR_AUIPC       {25'b0, OPCODE_AUIPC}
`define IR_AUIPC_MASK  OPCODE_MASK  

`define IR_JAL         {25'b0, OPCODE_JAL}
`define IR_JAL_MASK    OPCODE_MASK  

`define FUNCT3_JALR     3'b000
`define IR_JALR        {17'b0, FUNCT3_JALR, OPCODE_JALR}
`define IR_JALR_MASK   FUNCT3_OPCODE_MASK  

`define FUNCT3_BEQ      3'b000
`define IR_BEQ         {17'b0, FUNCT3_BEQ, 5'b0, OPCODE_BRANCH}
`define IR_BEQ_MASK    FUNCT3_OPCODE_MASK  

`define FUNCT3_BNE      3'b001
`define IR_BNE         {17'b0, FUNCT3_BNE, 5'b0, OPCODE_BRANCH}
`define IR_BNE_MASK    FUNCT3_OPCODE_MASK 

`define FUNCT3_BLT      3'b100
`define IR_BLT         {17'b0, FUNCT3_BLT, 5'b0, OPCODE_BRANCH}
`define IR_BLT_MASK    FUNCT3_OPCODE_MASK 

`define FUNCT3_BGE      3'b101
`define IR_BGE         {17'b0, FUNCT3_BGE, 5'b0, OPCODE_BRANCH}
`define IR_BGE_MASK    FUNCT3_OPCODE_MASK 

`define FUNCT3_BLTU     3'b110
`define IR_BLTU        {17'b0, FUNCT3_BLTU, 5'b0, OPCODE_BRANCH}
`define IR_BLTU_MASK   FUNCT3_OPCODE_MASK 

`define FUNCT3_BGEU      3'b111
`define IR_BGEU        {17'b0, FUNCT3_BGEU, 5'b0, OPCODE_BRANCH}
`define IR_BGEU_MASK    FUNCT3_OPCODE_MASK

`define FUNCT3_LB       3'b000
`define IR_LB          {17'b0, FUNCT3_LB, 5'b0, OPCODE_LOAD}
`define IR_LB_MASK     FUNCT3_OPCODE_MASK

`define FUNCT3_LH       3'b001
`define IR_LH          {17'b0, FUNCT3_LH, 5'b0, OPCODE_LOAD}
`define IR_LH_MASK     FUNCT3_OPCODE_MASK 

`define FUNCT3_LW       3'b010
`define IR_LW          {17'b0, FUNCT3_LW, 5'b0, OPCODE_LOAD}
`define IR_LW_MASK     FUNCT3_OPCODE_MASK 

`define FUNCT3_LBU      3'b100
`define IR_LBU         {17'b0, FUNCT3_LBU, 5'b0, OPCODE_LOAD}
`define IR_LBU_MASK    FUNCT3_OPCODE_MASK 

`define FUNCT3_LHU      3'b101
`define IR_LHU         {17'b0, FUNCT3_LHU, 5'b0, OPCODE_LOAD}
`define IR_LHU_MASK    FUNCT3_OPCODE_MASK 

`define FUNCT3_SB       3'b000
`define IR_SB          {17'b0, FUNCT3_SB, 5'b0, OPCODE_STORE}
`define IR_SB_MASK     FUNCT3_OPCODE_MASK 

`define FUNCT3_SH       3'b001
`define IR_SH          {17'b0, FUNCT3_SH, 5'b0, OPCODE_STORE}
`define IR_SH_MASK     FUNCT3_OPCODE_MASK 

`define FUNCT3_SW      3'b010
`define IR_SW          {17'b0, FUNCT3_SW, 5'b0, OPCODE_STORE}
`define IR_SW_MASK     FUNCT3_OPCODE_MASK

`define FUNCT3_ADDI     3'b000
`define IR_ADDI        {17'b0, FUNCT3_ADDI, 5'b0, OPCODE_I_TYPE}
`define IR_ADDI_MASK   FUNCT3_OPCODE_MASK

`define FUNCT3_SLTI     3'b010
`define IR_SLTI        {17'b0, FUNCT3_SLTI, 5'b0, OPCODE_I_TYPE}
`define IR_SLTI_MASK   FUNCT3_OPCODE_MASK

`define FUNCT3_SLTIU    3'b011
`define IR_SLTIU       {17'b0, FUNCT3_SLTIU, 5'b0, OPCODE_I_TYPE}
`define IR_SLTIU_MASK  FUNCT3_OPCODE_MASK

`define FUNCT3_XORI     3'b100
`define IR_XORI        {17'b0, FUNCT3_XORI, 5'b0, OPCODE_I_TYPE}
`define IR_XORI_MASK   FUNCT3_OPCODE_MASK

`define FUNCT3_ORI      3'b110
`define IR_ORI         {17'b0, FUNCT3_ORI, 5'b0, OPCODE_I_TYPE}
`define IR_ORI_MASK    FUNCT3_OPCODE_MASK

`define FUNCT3_ANDI    3'b111
`define IR_ANDI        {17'b0, FUNCT3_ANDI, 5'b0, OPCODE_I_TYPE}
`define IR_ANDI_MASK   FUNCT3_OPCODE_MASK

`define FUNCT7_SLLI    7'b0000000
`define FUNCT3_SLLI    3'b001
`define IR_SLLI        {FUNCT7_SLLI, 10'b0, FUNCT3_SLLI, 5'b0, OPCODE_I_TYPE}
`define IR_SLLI_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SRLI    7'b0000000
`define FUNCT3_SRLI    3'b101
`define IR_SRLI        {FUNCT7_SRLI, 10'b0, FUNCT3_SRLI, 5'b0, OPCODE_I_TYPE}
`define IR_SRLI_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SRAI    7'b0100000
`define FUNCT3_SRAI    3'b101
`define IR_SRAI        {FUNCT7_SRAI, 10'b0, FUNCT3_SRAI, 5'b0, OPCODE_I_TYPE}
`define IR_SRAI_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_ADD     7'b0000000
`define FUNCT3_ADD     3'b000
`define IR_ADD        {FUNCT7_ADD, 10'b0, FUNCT3_ADD, 5'b0, OPCODE_R_TYPE}
`define IR_ADD_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SUB    7'b0100000
`define FUNCT3_SUB    3'b000
`define IR_SUB        {FUNCT7_SUB, 10'b0, FUNCT3_SUB, 5'b0, OPCODE_R_TYPE}
`define IR_SUB_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SLL    7'b0000000
`define FUNCT3_SLL    3'b001
`define IR_SLL        {FUNCT7_SLL, 10'b0, FUNCT3_SLL, 5'b0, OPCODE_R_TYPE}
`define IR_SLL_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SLT    7'b0000000
`define FUNCT3_SLT    3'b010
`define IR_SLT        {FUNCT7_SLT, 10'b0, FUNCT3_SLT, 5'b0, OPCODE_R_TYPE}
`define IR_SLT_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SLTU   7'b0000000
`define FUNCT3_SLTU   3'b011
`define IR_SLTU       {FUNCT7_SLTU, 10'b0, FUNCT3_SLTU, 5'b0, OPCODE_R_TYPE}
`define IR_SLTU_MASK  FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_XOR    7'b0000000
`define FUNCT3_XOR    3'b100
`define IR_XOR        {FUNCT7_XOR, 10'b0, FUNCT3_XOR, 5'b0, OPCODE_R_TYPE}
`define IR_XOR_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SRL    7'b0000000
`define FUNCT3_SRL    3'b101
`define IR_SRL        {FUNCT7_SRL, 10'b0, FUNCT3_SRL, 5'b0, OPCODE_R_TYPE}
`define IR_SRL_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_SRA    7'b0100000
`define FUNCT3_SRA    3'b101
`define IR_SRA        {FUNCT7_SRA, 10'b0, FUNCT3_SRA, 5'b0, OPCODE_R_TYPE}
`define IR_SRA_MASK   FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_OR     7'b0000000
`define FUNCT3_OR     3'b110
`define IR_OR         {FUNCT7_OR, 10'b0, FUNCT3_OR, 5'b0, OPCODE_R_TYPE}
`define IR_OR_MASK    FUNCT7_FUNCT3_OPCODE_MASK

`define FUNCT7_AND    7'b0000000
`define FUNCT3_AND    3'b111
`define IR_AND        {FUNCT7_AND, 10'b0, FUNCT3_AND, 5'b0, OPCODE_R_TYPE}
`define IR_AND_MASK   FUNCT7_FUNCT3_OPCODE_MASK

// EXCEPTION CODES

`define NO_EXCEPTION 2'b00
`define UNKNOWN_INSTRUCTION_EXCEPTION 2'b01
`define MISALIGNED_ADDRESS_EXCEPTION  2'b10

// ALU Ctl width
`define ALU_CTL_WIDTH                     4 

// ALU Ctl ops
`define ALU_OP_NOP                        4'b0000
`define ALU_OP_SLL                        4'b0001
`define ALU_OP_SRL                        4'b0010
`define ALU_OP_SRA                        4'b0011
`define ALU_OP_ADD                        4'b0100
`define ALU_OP_SUB                        4'b0101
`define ALU_OP_AND                        4'b0110
`define ALU_OP_OR                         4'b0111
`define ALU_OP_XOR                        4'b1000
`define ALU_OP_LT                         4'b1001
`define ALU_OP_LTU                        4'b1010
`define ALU_OP_EQ                         4'b1011
`define ALU_OP_NEQ                        4'b1100
`define ALU_OP_GE                         4'b1101
`define ALU_OP_GEU                        4'b1110

// MUX control signals
// PC select
`define PC_SEL_NOP 2'b00
`define PC_SEL_NPC 2'b01
`define PC_SEL_ALU 2'b10
`define PC_SEL_BR  2'b11

// NPC select
`define NPC_SEL_NOP 1'b0
`define NPC_SEL_ALU 1'b1

// regFile write back data select
`define WB_SEL_ALU  2'b00
`define WB_SEL_MEM  2'b01
`define WB_SEL_NPC  2'b10


// regFile enable
`define RF_NOP   1'b0
`define RF_WRITE 1'b1

// ir enable
`define IR_NOP   1'b0
`define IR_WRITE 1'b1

// ALU control select
`define ALU_CTL_SEL_NOP 2'b00
`define ALU_CTL_SEL_ADD 2'b01
`define ALU_CTL_SEL_ROM 2'b10

// ALU A INPUT select
`define ALU_A_SEL_RS1    2'b00
`define ALU_A_SEL_PC     2'b01
`define ALU_A_SEL_ZERO   2'b10

// ALU B INPUT select
`define ALU_B_SEL_RS2       3'b000
`define ALU_B_SEL_I_IMMED   3'b001
`define ALU_B_SEL_S_IMMED   3'b010
`define ALU_B_SEL_B_IMMED   3'b011
`define ALU_B_SEL_U_IMMED   3'b100
`define ALU_B_SEL_J_IMMED   3'b101
`define ALU_B_SEL_4         3'b110
`define ALU_B_SEL_RESET     3'b111

// Data memory operand size
`define DMEM_SIZE_BYTE 2'b00
`define DMEM_SIZE_HALF 2'b01
`define DMEM_SIZE_WORD 2'b10

// Data memory write enable
`define DMEM_NO_WRITE 1'b0
`define DMEM_WRITE 1'b1

// Data memory read enable
`define DMEM_NO_READ 1'b0
`define DMEM_READ 1'b1

// Instruction memory write enable
`define IMEM_NO_READ 1'b0
`define IMEM_READ 1'b1

// Data memory in sign extend
`define OPERAND_UNSIGNED 1'b1
`define OPERAND_SIGNED   1'b0

// uPC input selct
`define MICRO_PC_SEL_NOP                             3'b000
`define MICRO_PC_SEL_INC                             3'b001
`define MICRO_PC_SEL_FETCH                           3'b010
`define MICRO_PC_SEL_JUMP                            3'b011
`define MICRO_PC_SEL_FETCH_OR_MISALIGNED_ADDRESS_EX  3'b100
`define MICRO_PC_SEL_INC_OR_MISALIGNED_ADDRESS_EX    3'b101

// uCode defs

`define MICRO_INST_ROM_SIZE 32
`define MICRO_INST_ROM_WIDTH 20

// micro-instruction {irWE: 1, pcSel : 2, npcSel : 1, regFileWe : 1, regFileWBSel : 2, 
//                    aluASel : 2, aluBSel : 3, aluCtlSel : 2, dMemWE : 1, 
//                      dMemRE : 1, iMemRE : 1, uPCSel : 3}

// uInstROM address mnemonics
`define MICRO_PC_UNKNOWN_INST_EX_ADDR 5'd0 // unknown instruction exception
`define MICRO_PC_MISALIGNED_ADDRESS_EX_ADDR 5'd1 // misaligned address exception
`define MICRO_PC_RESET_0_ADDR 5'd2 // post reset
`define MICRO_PC_RESET_1_ADDR 5'd3
`define MICRO_PC_FETCH_ADDR 5'd4 // fetch
`define MICRO_PC_DECODE_ADDR 5'd5 // decode 
`define MICRO_PC_LUI_ADDR 5'd6 // LUI instruction
`define MICRO_PC_AUIPC_ADDR 5'd7 // AUIPC instruction
`define MICRO_PC_JAL_ADDR 5'd8 // JAL instruction
`define MICRO_PC_JALR_ADDR 5'd9 // JALR instruction
`define MICRO_PC_BRANCH_CONDITION_ADDR 5'd10 // BRANCH instructions, branch condition
`define MICRO_PC_BRANCH_PC_SEL_ADDR 5'd11 // BRANCH write branch address to PC
`define MICRO_PC_LOAD_COMP_ADDR_ADDR 5'd12 // compute address and initiate dMem read
`define MICRO_PC_LOAD_WRITE_BACK_ADDR 5'd13 // write back dMem value
`define MICRO_PC_STORE_COMP_ADDR_ADDR 5'd14 // compute address and initiate dMem write
`define MICRO_PC_STORE_WRITE_DMEM_ADDR 5'd15 // completed write to dMem
`define MICRO_PC_I_TYPE_ADDR 5'd16 // I-TYPE instructions
`define MICRO_PC_R_TYPE_ADDR 5'd17 // R-TYPE instructions

// uJump defs
`define MICRO_JUMP_ROM_SIZE 128

// aluOpROM defs
`define ALU_OP_ROM_SIZE 128

// used for ALU ROM address generation
// set last two bits of opcode to zero
`define OPCODE_R_TYPE_MOD 7'b0110000
`define OPCODE_I_TYPE_MOD 7'b0010000
`define OPCODE_BRANCH_MOD 7'b1100000
// shift left by 1
`define FUNCT7_SUB_MOD    7'b1000000
`define FUNCT7_SRA_MOD    7'b1000000
`define FUNCT7_SRAI_MOD   7'b1000000

// R format instructions, 2 regs
// ADD
`define ALU_OP_ADD_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_ADD)
// SUB
`define ALU_OP_SUB_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SUB | `FUNCT7_SUB_MOD)
// SLL
`define ALU_OP_SLL_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SLL)
// SLT
`define ALU_OP_SLT_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SLT)
// SLTU
`define ALU_OP_SLTU_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SLTU)
// XOR
`define ALU_OP_XOR_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_XOR)
// SRL
`define ALU_OP_SRL_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SRL)
// SRA
`define ALU_OP_SRA_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_SRA | `FUNCT7_SRA_MOD)
// OR
`define ALU_OP_OR_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_OR)
// AND
`define ALU_OP_AND_ADDR (`OPCODE_R_TYPE_MOD | `FUNCT3_AND)

// BRANCH INSTRUCTIONS
// BEQ
`define ALU_OP_BEQ_ADDR (`OPCODE_BRANCH_MOD | `FUNCT3_BEQ)
// BNE
`define ALU_OP_BNE_ADDR (`OPCODE_BRANCH_MOD | `FUNCT3_BNE)
// BLT
`define ALU_OP_BLT_ADDR (`OPCODE_BRANCH_MOD |`FUNCT3_BLT)
// BGE
`define ALU_OP_BGE_ADDR (`OPCODE_BRANCH_MOD |`FUNCT3_BGE)
// BLTU
`define ALU_OP_BLTU_ADDR (`OPCODE_BRANCH_MOD |`FUNCT3_BLTU)
// BGEU
`define ALU_OP_BGEU_ADDR (`OPCODE_BRANCH_MOD |`FUNCT3_BGEU)

// I-TYPE INSTRUCTIONS
// ADDI
`define ALU_OP_ADDI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_ADDI)
// SLTI
`define ALU_OP_SLTI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_SLTI)
// SLTIU
`define ALU_OP_SLTIU_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_SLTIU)
// XORI
`define ALU_OP_XORI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_XORI)
// ORI
`define ALU_OP_ORI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_ORI)
// ANDI
`define ALU_OP_ANDI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_ANDI)
// SLLI
`define ALU_OP_SLLI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_SLLI)
// SRLI
`define ALU_OP_SRLI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_SRLI)
// SRAII
`define ALU_OP_SRAI_ADDR (`OPCODE_I_TYPE_MOD | `FUNCT3_SRAI | `FUNCT7_SRAI_MOD)

`endif
