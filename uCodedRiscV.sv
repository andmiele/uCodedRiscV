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

`include "controlDefs.sv"

module uCodedRiscV
#(parameter DATA_WIDTH = 32, parameter DATA_ADDR_WIDTH = 32, parameter RESET_PC_VALUE = 32'h40000000, parameter INST_ADDR_WIDTH = 7, parameter INST_WIDTH = 32)
(
    input logic clk,
    input logic rst,
    input logic clearExceptionCode,
    input logic [INST_WIDTH - 1 : 0] iMemDataIn,
    input logic [DATA_WIDTH - 1 : 0] dMemDataIn,
    output logic [INST_ADDR_WIDTH - 1 : 0] iMemAddr,
    output logic iMemRE,
    output logic dMemRE,
    output logic dMemWE,
    output logic [(DATA_WIDTH / 8) - 1 : 0] dMemByteEn,
    output logic [DATA_ADDR_WIDTH - 1 : 0] dMemAddr, 
    output logic [DATA_WIDTH - 1 : 0] dMemDataOut,
    output logic [1 : 0] exceptionCode
);

// Program Counter (PC) and Instruction Register (IR)
logic [INST_ADDR_WIDTH - 1 : 0] pc;
logic [INST_ADDR_WIDTH - 1 : 0] npc; // next PC register
logic [INST_WIDTH - 1 : 0] ir;

logic irWE;

// pc and npc mux sel
logic [1 : 0] pcSel;
logic [1 : 0] npcSel;

// instruction register fields
logic [6 : 0] opcode;
logic [2 : 0] funct3;
logic [4 : 0] rd;
logic [4 : 0] rs1;
logic [4 : 0] rs2;
logic [6 : 0] funct7;

// branch non taken/taken
logic branchTaken;

// Misaligned address signal
logic misalignedAddr;

// ALU wires
logic [DATA_WIDTH - 1 : 0] aluInA;
logic [DATA_WIDTH - 1 : 0] aluInB;
logic [DATA_WIDTH - 1 : 0] aluOut;
logic [3 : 0] aluCtl;
logic [1 : 0] aluCtlSel;
logic [1 : 0] aluASel;
logic [2 : 0] aluBSel;

// instantiate ALU module: alu
alu #(.WIDTH(DATA_WIDTH)) ALU(.inA(aluInA), .inB(aluInB), .aluCtl(aluCtl), .out(aluOut));

// immediate generation wires
logic [DATA_WIDTH - 1 : 0] iImm;
logic [DATA_WIDTH - 1 : 0] sImm;
logic [DATA_WIDTH - 1 : 0] bImm;
logic [DATA_WIDTH - 1 : 0] uImm;
logic [DATA_WIDTH - 1 : 0] jImm;

logic [DATA_WIDTH - 1 : 0] dMemLoadData;

//instantiate immediate generation module: immGen
immGen #(.WIDTH(DATA_WIDTH)) immG(.ir(ir), .iImm(iImm), .sImm(sImm), .bImm(bImm), .uImm(uImm), .jImm(jImm));

// uJump ROM wires

logic [$clog2(`MICRO_INST_ROM_SIZE) - 1 : 0] uPCJump;

// alu Op ROM wires

logic [$clog2(`ALU_OP_ROM_SIZE) - 1 : 0] aluOpROMAddr;
logic [`ALU_CTL_WIDTH - 1 : 0] aluOpROMOut;

// micro instruction register and micro PC
logic [`MICRO_INST_ROM_WIDTH - 1 : 0] uIR;
logic [$clog2(`MICRO_INST_ROM_SIZE) - 1 : 0] uPC;

// micro PC mux selct
logic [2 : 0] uPCSel;

// instantiate uCode, uJump and aluOp ROMS
uCodeROM uCROM(.addr(uPC), .out(uIR));
uJumpROM uJROM(.addr(opcode), .out(uPCJump));
aluOpROM aluROM(.addr(aluOpROMAddr), .out(aluOpROMOut));

// register file wires
logic regFileWE;
// regFile write back data sel
logic [1 : 0] regFileWBSel;

logic [DATA_WIDTH - 1 : 0] regFileWBVal;
logic [DATA_WIDTH - 1 : 0] regFileRs1Val;
logic [DATA_WIDTH - 1 : 0] regFileRs2Val;

// istantiate register file: regFileAsyncRead. r0 is always zero
regFileAsyncRead #(.N_REGS(32), .DATA_WIDTH(32), .N_READ_PORTS(2), .N_WRITE_PORTS(1)) 
regFile(.clk(clk), .rst(rst), .we(regFileWE && (rd != {5{1'b0}})), .rAddrs('{rs1, rs2}), .wAddrs('{rd}), 
.rPorts('{regFileRs1Val, regFileRs2Val}), .wPorts('{regFileWBVal}));

// exception register
always_ff @(posedge clk or posedge rst)
begin: exceptionCodeWrite
    if(rst)
        exceptionCode <= `NO_EXCEPTION;
    else
    begin: exceptionCodes
        if(uPC == `MICRO_PC_DECODE_ADDR && uPCJump == `MICRO_PC_UNKNOWN_INST_EX_ADDR) 
            exceptionCode <= `UNKNOWN_INSTRUCTION_EXCEPTION;
        else
        if(misalignedAddr)
            exceptionCode <= `MISALIGNED_ADDRESS_EXCEPTION;
        else
        if(clearExceptionCode)
            exceptionCode <= `NO_EXCEPTION;               
        else
            exceptionCode <= exceptionCode;
    end 
end

// extract instruction fields
assign {funct7, rs2, rs1, funct3, rd, opcode} = ir;
// instruction memory address = pc
assign iMemAddr = pc;
// dMemAddr = aluOut
assign dMemAddr = aluOut[DATA_ADDR_WIDTH - 1 : 0];

// Instruction Register write logic
always_ff @(posedge clk or posedge rst)
begin: ir_write
    if(rst)
        ir <= 'b0;
    else
    if (irWE)
        ir <= iMemDataIn;
    else
        ir <= ir;
end

// Adjust alu output if it is new PC address for some instructions
logic [DATA_WIDTH - 1 : 0] aluOutAdjusted; 
assign aluOutAdjusted =  {aluOut[DATA_WIDTH - 1 : 1], aluOut[0] & (opcode != `OPCODE_JALR)}; // first bit of address is zeroed for JALR

// Program Counter MUX
always_ff @(posedge clk or posedge rst)
begin: pc_write
    if(rst)
        pc <= 'b0;
    else
    case (pcSel)
        `PC_SEL_NOP: pc <= pc;
        `PC_SEL_NPC: pc <= npc;
        `PC_SEL_ALU: pc <= aluOutAdjusted[INST_ADDR_WIDTH - 1 : 0];
        `PC_SEL_BR : pc <= branchTaken ? aluOut[INST_ADDR_WIDTH - 1 : 0] : npc; 
    endcase
end

// Next Program Counter MUX
always_ff @(posedge clk or posedge rst)
begin: npc_write
    if(rst)
        npc <= 'b0;
    else
    case (npcSel)
        `NPC_SEL_NOP: npc <= npc;
        `NPC_SEL_ALU: npc <= aluOut[INST_ADDR_WIDTH - 1 : 0];
    endcase
end

// Register file write mux
always_comb
begin: regFile_write
    case (regFileWBSel)
        `WB_SEL_ALU: regFileWBVal = aluOut;
        `WB_SEL_MEM: regFileWBVal = dMemLoadData;
        `WB_SEL_NPC: regFileWBVal = npc;
         default: regFileWBVal = 'b0;
    endcase
end

// Data Memory word size mux based on funct3 instruction field
always_comb
begin: dMemataSize_mux
    case (funct3[1:0])
        `DMEM_SIZE_BYTE: // byte 
        begin
            case (dMemAddr[1:0])
                2'b00: 
                begin
                    dMemDataOut = {{(DATA_WIDTH - 8){1'b0}}, regFileRs2Val[7 : 0]};
                    dMemByteEn = 4'b0001; 
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 8){dMemDataIn[7]}}, dMemDataIn[7 : 0]}
                    : {{(DATA_WIDTH - 8){1'b0}}, dMemDataIn[7 : 0]};
                end
                2'b01:
                begin
                    dMemDataOut = {{(DATA_WIDTH - 16){1'b0}}, regFileRs2Val[7 : 0], {(DATA_WIDTH - 24){1'b0}}};
                    dMemByteEn = 4'b0010;
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 8){dMemDataIn[15]}}, dMemDataIn[15 : 8]}
                    : {{(DATA_WIDTH - 8){1'b0}}, dMemDataIn[15 : 8]};
                end
                2'b10: 
                begin
                    dMemDataOut = {{(DATA_WIDTH - 24){1'b0}}, regFileRs2Val[7 : 0], {(DATA_WIDTH - 16){1'b0}}};
                    dMemByteEn = 4'b0100;
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 8){dMemDataIn[23]}}, dMemDataIn[23 : 16]}
                    : {{(DATA_WIDTH - 8){1'b0}}, dMemDataIn[23 : 16]}; 
                end
                2'b11: 
                begin      
                    dMemDataOut = {regFileRs2Val[7 : 0], {(DATA_WIDTH - 8){1'b0}}};
                    dMemByteEn = 4'b1000;
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 8){dMemDataIn[31]}}, dMemDataIn[31 : 24]}
                    : {{(DATA_WIDTH - 8){1'b0}}, dMemDataIn[31 : 24]};
                end
            endcase
        end
        `DMEM_SIZE_HALF: // half-word
        begin
            case (dMemAddr[1])
                0:
                begin
                    dMemDataOut = {{(DATA_WIDTH - 16){1'b0}}, regFileRs2Val[15 : 0]};
                    dMemByteEn = 4'b0011;
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 16){dMemDataIn[15]}}, dMemDataIn[15 : 0]} 
                    : {{(DATA_WIDTH - 16){1'b0}}, dMemDataIn[15 : 0]};
                end
                1: 
                begin
                    dMemDataOut = {regFileRs2Val[15 : 0], {(DATA_WIDTH - 16){1'b0}}};
                    dMemByteEn = 4'b1100;
                    dMemLoadData = funct3[2] == `OPERAND_SIGNED ? {{(DATA_WIDTH - 16){dMemDataIn[31]}}, dMemDataIn[31 : 16]} 
                    : {{(DATA_WIDTH - 16){1'b0}}, dMemDataIn[31 : 16]};
                end
            endcase
        end
        `DMEM_SIZE_WORD: // word
        begin
            dMemLoadData = dMemDataIn; 
            dMemByteEn = 4'b1111;
            dMemDataOut = regFileRs2Val;
        end
        default: //word
        begin
            dMemLoadData = dMemDataIn;
            dMemByteEn = 4'b1111; 
            dMemDataOut = regFileRs2Val;
        end
    endcase
end

always_ff @(posedge clk or posedge rst)
begin: branch_taken_write
    if(rst)
        branchTaken <= 1'b0;
    else
    if (uPC == `MICRO_PC_BRANCH_CONDITION_ADDR)
        branchTaken = aluOut[0];
    else
        branchTaken <= branchTaken;
end

// ALU CTL imux
always_comb
begin: aluCtl_mux
    case (aluCtlSel)
        `ALU_CTL_SEL_NOP: aluCtl = `ALU_OP_NOP;
        `ALU_CTL_SEL_ADD: aluCtl = `ALU_OP_ADD;
        `ALU_CTL_SEL_ROM: aluCtl = aluOpROMOut;
        default: aluCtl = `ALU_OP_NOP;
    endcase
end

// ALU A input mux
always_comb
begin: aluA_mux
    case (aluASel)
        `ALU_A_SEL_RS1: aluInA = regFileRs1Val;
        `ALU_A_SEL_PC: aluInA = pc;
        `ALU_A_SEL_ZERO: aluInA = 'b0;
        default: aluInA = 'b0;
    endcase
end

// ALU B input mux
always_comb
begin: aluB_mux
    case (aluBSel)
        `ALU_B_SEL_RS2: aluInB = regFileRs2Val;
        `ALU_B_SEL_I_IMMED: aluInB = iImm;
        `ALU_B_SEL_S_IMMED: aluInB = sImm;
        `ALU_B_SEL_B_IMMED: aluInB = bImm;
        `ALU_B_SEL_U_IMMED: aluInB = uImm;
        `ALU_B_SEL_J_IMMED: aluInB = jImm;
        `ALU_B_SEL_4: aluInB = 'h4;
        `ALU_B_SEL_RESET: aluInB = RESET_PC_VALUE;
    endcase
end

// MISALIGNED ACCESS mux
always_comb
begin: mis_mux
    if (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR)
        misalignedAddr = aluOutAdjusted[1 : 0] != 2'b00; 
    else
    if (opcode == `OPCODE_STORE || opcode == `OPCODE_LOAD)
    case (funct3)
        `FUNCT3_LB: misalignedAddr = 1'b0;  // = FUNCT3_SB
        `FUNCT3_LH: misalignedAddr = aluOutAdjusted[0] != 1'b0; // = FUNCT3_SH
        `FUNCT3_LW: misalignedAddr = aluOutAdjusted[1 : 0] != 2'b00; // = FUNCT3_SW
        default:    misalignedAddr = 1'b0; 
    endcase
    else
        misalignedAddr = 1'b0;
end

// micro PC write mux
always_ff @(posedge clk or posedge rst)
begin: uPCwrite
    if (rst)
    begin: uPCreset
        uPC <= `MICRO_PC_RESET_0_ADDR;
    end
    else
    begin: uPCmux
        case (uPCSel)
            `MICRO_PC_SEL_NOP:   uPC <= 'b0;
            `MICRO_PC_SEL_INC:   uPC <= uPC + 1'b1;
            `MICRO_PC_SEL_FETCH: uPC <= `MICRO_PC_FETCH_ADDR;
            `MICRO_PC_SEL_JUMP:  uPC <= uPCJump;
            `MICRO_PC_SEL_FETCH_OR_MISALIGNED_ADDRESS_EX: uPC <= misalignedAddr == 1'b0 ? `MICRO_PC_FETCH_ADDR :`MICRO_PC_MISALIGNED_ADDRESS_EX_ADDR;
            `MICRO_PC_SEL_INC_OR_MISALIGNED_ADDRESS_EX: uPC <= misalignedAddr == 1'b0 ? uPC + 1'b1 : `MICRO_PC_MISALIGNED_ADDRESS_EX_ADDR;     
        endcase
    end
end

// assign {irWE: 1, pcSel : 2, npcSel : 1, regFileWE : 1, regFileWBSel: 2, aluASel: 2, aluBSel: 3, aluCtlSel: 2,
//         dMemWE : 1, dMemRE : 1, iMemRE: 1, uPCSel : 3} = uIR;

assign irWE = uIR[19];
assign pcSel = uIR[18:17];
assign npcSel = uIR[16];
assign regFileWE = uIR[15];
assign regFileWBSel = uIR[14 : 13];
assign aluASel = uIR[12 : 11];
assign aluBSel = uIR[10 : 8];
assign aluCtlSel = uIR[7 : 6];
assign dMemWE = uIR[5];
assign dMemRE = uIR[4];
assign iMemRE = uIR[3];
assign uPCSel = uIR[2 : 0];

// select aluOp ROM address

always_comb
begin: aluOpROMAddrSel
    case (opcode)
        `OPCODE_LUI: aluOpROMAddr = {opcode[6 : 2], 2'b00};
        `OPCODE_AUIPC: aluOpROMAddr = {opcode[6 : 2], 2'b00};
        `OPCODE_JAL: aluOpROMAddr = {opcode[6 : 2], 2'b00};
        `OPCODE_JALR: aluOpROMAddr = {opcode[6 : 2], 2'b00};
        // opcode[2] and opcode[6] are always zero for instructions below
        `OPCODE_BRANCH: aluOpROMAddr = {opcode[6 : 2], 2'b00} + funct3;
        `OPCODE_LOAD: aluOpROMAddr = {opcode[6 : 2], 2'b00} + funct3;
        `OPCODE_STORE: aluOpROMAddr = {opcode[6 : 2], 2'b00} + funct3;
        // addition below never overflows, 2'b10 at most
        `OPCODE_R_TYPE: aluOpROMAddr = ({opcode[6 : 2], 2'b00} + funct3) | {funct7[5], {6'b000000}};
        `OPCODE_I_TYPE: aluOpROMAddr = ({opcode[6 : 2], 2'b00} + funct3) | {(funct7[5] & (funct3 == `FUNCT3_SRAI)), {6'b000000}};
        default: aluOpROMAddr = {$clog2(`ALU_OP_ROM_SIZE){1'b0}};
    endcase
end

endmodule
