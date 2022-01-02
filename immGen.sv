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

// immGen.sv
// immediate generation module, follows figure 2.3 from spec

`include "controlDefs.sv"

module immGen
#(parameter WIDTH = 32)
(
    input logic [31 : 0] ir,
    output logic [WIDTH - 1 : 0] iImm,
    output logic [WIDTH - 1 : 0] sImm,
    output logic [WIDTH - 1 : 0] bImm,
    output logic [WIDTH - 1 : 0] uImm,
    output logic [WIDTH - 1 : 0] jImm
);

// OPCODE_I_TYPE | OPCODE_JALR
assign iImm = {ir[31] ? {(WIDTH - 11){1'b1}} : {(WIDTH - 11){1'b0}},
ir[30 : 25], ir[24 : 21], ir[20]};
// OPCODE_STORE 
assign sImm = {ir[31] ? {(WIDTH - 11){1'b1}} : {(WIDTH - 11){1'b0}}, 
ir[30 : 25], ir[11 : 8], ir[7]};
// OPCODE_BRANCH 
assign bImm = {ir[31] ? {(WIDTH - 12){1'b1}} : {(WIDTH - 12){1'b0}}, 
ir[7], ir[30 : 25], ir[11 : 8], 1'b0};  
// OPCODE_LUI | OPCODE_AUIPC
assign uImm = {ir[31 : 12], 12'b0};
// OPCODE_JAL 
assign jImm = {ir[31] ? {(WIDTH - 20){1'b1}} : {(WIDTH - 20){1'b0}}, 
ir[19 : 12], ir[20], ir[30 : 25], ir[24 : 21], 1'b0};                            

endmodule
