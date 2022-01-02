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

// aluOpROM.sv
// aluOpROM

`include "controlDefs.sv"

module aluOpROM
(
    input logic [$clog2(`ALU_OP_ROM_SIZE) - 1 : 0] addr,
    output logic [`ALU_CTL_WIDTH - 1 : 0] out
);
always_comb
begin: aluOpROM
    case (addr)
        `ALU_OP_ADD_ADDR: out = `ALU_OP_ADD;
        `ALU_OP_SUB_ADDR: out = `ALU_OP_SUB;
        `ALU_OP_SLL_ADDR: out = `ALU_OP_SLL;
        `ALU_OP_SLT_ADDR: out = `ALU_OP_LT;
        `ALU_OP_SLTU_ADDR: out = `ALU_OP_LTU;
        `ALU_OP_XOR_ADDR: out = `ALU_OP_XOR;
        `ALU_OP_SRL_ADDR: out = `ALU_OP_SRL;
        `ALU_OP_SRA_ADDR: out = `ALU_OP_SRA;
        `ALU_OP_OR_ADDR: out = `ALU_OP_OR;
        `ALU_OP_AND_ADDR: out = `ALU_OP_AND;
        `ALU_OP_BEQ_ADDR: out = `ALU_OP_EQ;
        `ALU_OP_BNE_ADDR: out = `ALU_OP_NEQ;
        `ALU_OP_BLT_ADDR: out = `ALU_OP_LT;
        `ALU_OP_BGE_ADDR: out = `ALU_OP_GE;
        `ALU_OP_BLTU_ADDR: out = `ALU_OP_LTU;
        `ALU_OP_BGEU_ADDR: out = `ALU_OP_GEU;
        `ALU_OP_ADDI_ADDR: out = `ALU_OP_ADD;
        `ALU_OP_SLTI_ADDR: out = `ALU_OP_LT;
        `ALU_OP_SLTIU_ADDR: out = `ALU_OP_LTU;
        `ALU_OP_XORI_ADDR: out = `ALU_OP_XOR;
        `ALU_OP_ORI_ADDR: out = `ALU_OP_OR;
        `ALU_OP_ANDI_ADDR: out = `ALU_OP_AND;
        `ALU_OP_SLLI_ADDR: out = `ALU_OP_SLL;
        `ALU_OP_SRLI_ADDR: out = `ALU_OP_SRL;
        `ALU_OP_SRAI_ADDR: out = `ALU_OP_SRA;
         default:          out = {`ALU_CTL_WIDTH{1'b1}};
    endcase
end
endmodule 
