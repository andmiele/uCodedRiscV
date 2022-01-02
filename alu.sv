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

// alu.sv
// Combinational ALU

`include "controlDefs.sv"

module alu
#(parameter WIDTH = 32)
(
    input logic [WIDTH - 1 : 0] inA,
    input logic [WIDTH - 1 : 0] inB,
    input logic [`ALU_CTL_WIDTH - 1 : 0] aluCtl,
    output logic [WIDTH - 1 : 0] out
);

logic [WIDTH - 1: 0] subOut;

assign subOut = inA - inB;

always_comb
begin: aluOps
    case (aluCtl)
        `ALU_OP_SLL: 
        begin
            out = inA << inB[$clog2(WIDTH) - 1 : 0];
        end
        `ALU_OP_SRL: 
        begin
            out = inA >> inB[$clog2(WIDTH) - 1 : 0];
        end
        `ALU_OP_SRA: 
        begin
            out = $signed(inA) >>> inB[$clog2(WIDTH) - 1 : 0];
        end
        `ALU_OP_ADD: 
        begin
            out = inA + inB;
        end
        `ALU_OP_SUB: 
        begin
            out = subOut;
        end
        `ALU_OP_AND: 
        begin
            out = inA & inB;
        end
        `ALU_OP_OR: 
        begin
            out = inA | inB;
        end
        `ALU_OP_XOR: 
        begin
            out = inA ^ inB;
        end
        `ALU_OP_LTU: 
        begin
            out = inA < inB ? 'b1 : 'b0;
        end
        `ALU_OP_LT: 
        begin
            if (inA[WIDTH - 1] == inB[WIDTH - 1])
                out = subOut[WIDTH - 1] ? {{(WIDTH - 1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            else
                out = inA[WIDTH - 1] ? {{(WIDTH - 1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
        end
        `ALU_OP_EQ: 
        begin
            out = subOut == 'b0;
        end
        `ALU_OP_NEQ: 
        begin
            out = subOut != 'b0;
        end
        `ALU_OP_GEU: 
        begin
            out = inA < inB ? 'b0 : 'b1;
        end
        `ALU_OP_GE: 
        begin
            if (inA[WIDTH - 1] == inB[WIDTH - 1])
                out = subOut[WIDTH - 1] ? {WIDTH{1'b0}} : {{(WIDTH - 1){1'b0}}, 1'b1};
            else
                out = inA[WIDTH - 1] ? {WIDTH{1'b0}} : {{(WIDTH - 1){1'b0}}, 1'b1};
        end
        default: // NOP
        begin
            out = inA;
        end
    endcase
end 
endmodule
