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

// systemTop.sv
// uCoded RISC V top level: cpu + instruction and data memories

module systemTop
(
    input logic clk,
    input logic rst,
    input logic clearExceptionCode,
    output logic[1 : 0] exceptionCode
);

localparam INST_WIDTH = 32;
localparam DATA_WIDTH = 32;
localparam INST_ADDR_WIDTH = 10;
localparam DATA_ADDR_WIDTH = 10;

logic [INST_ADDR_WIDTH - 1 : 0] iMemAddr;
logic iMemRE;
logic dMemRE1;
logic dMemRE2;
logic dMemWE;
logic [DATA_ADDR_WIDTH - 1 : 0] dMemAddr;
logic[(DATA_WIDTH / 8) - 1 : 0] byteEn;
logic [INST_WIDTH - 1 : 0] iMemData;
logic [DATA_WIDTH - 1 : 0] dMemDataOut;
logic [DATA_WIDTH - 1 : 0] dMemDataIn;

// RISC V core
uCodedRiscV
#(.DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .RESET_PC_VALUE(10'h000), .INST_ADDR_WIDTH(INST_ADDR_WIDTH))
cpu(.clk(clk), .rst(rst), .clearExceptionCode(clearExceptionCode), .iMemDataIn(iMemData), .dMemDataIn(dMemDataOut), .iMemAddr(iMemAddr), 
    .iMemRE(iMemRE), .dMemRE(dMemRE), .dMemWE(dMemWE), .dMemByteEn(byteEn), .dMemAddr(dMemAddr), 
    .dMemDataOut(dMemDataIn), .exceptionCode(exceptionCode));

// instruction memory
instMem
#(.SIZE(1 << (INST_ADDR_WIDTH)), .DATA_WIDTH(INST_WIDTH), .FALL_THROUGH(1))
iMem(.clk(clk), .rst(rst), .en(iMemRE), .r(iMemRE), .w(), .rAddr({2'b00, iMemAddr[INST_ADDR_WIDTH - 1 : 2]}), .wAddr(), .in(), .out(iMemData));

// data memory (read and write ports, but used as single "write or read" port)
dataMem
#(.SIZE(1 << (DATA_ADDR_WIDTH)), .DATA_WIDTH(DATA_WIDTH), .FALL_THROUGH(0))
dMem(.clk(clk), .rst(rst), .en(dMemRE | dMemWE), .r(dMemRE), .w(dMemWE), .rAddr({2'b00, dMemAddr[DATA_ADDR_WIDTH - 1 : 2]}), 
     .wAddr({2'b00, dMemAddr[DATA_ADDR_WIDTH - 1 : 2]}), .byteEn(byteEn), .in(dMemDataIn), .out(dMemDataOut));

endmodule 
