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

// systemTopFPGA.sv
// uCoded RISC V top level: cpu + instruction and data memories + memory mapped LED

module systemTopFPGA
(
    input logic clk,
    input logic rstn,
    input logic clearExceptionCoden,
    output logic LED,
    output logic[1 : 0] exceptionCode
);

localparam INST_WIDTH = 32;
localparam DATA_WIDTH = 32;
localparam INST_ADDR_WIDTH = 5;
localparam DATA_ADDR_WIDTH = 10;

logic [INST_ADDR_WIDTH - 1 : 0] iMemAddr;
logic iMemRE;
logic dMemRE;
logic dMemWE;
logic [DATA_ADDR_WIDTH - 1 : 0] dMemAddr;
logic [DATA_ADDR_WIDTH - 1 : 0] dMemAddrIO;
logic [(DATA_WIDTH / 8) - 1 : 0] byteEn;
logic [INST_WIDTH - 1 : 0] iMemData;
logic [DATA_WIDTH - 1 : 0] dMemDataOut;
logic [DATA_WIDTH - 1 : 0] dMemDataIn;
logic [DATA_WIDTH - 1 : 0] LEDReg;

assign LED = LEDReg[0];
logic rst, clearExceptionCode;
assign rst = ~rstn;
assign clearExceptionCode = ~clearExceptionCoden;

// LEDReg
always_ff @(posedge clk or posedge rst)
begin: LEDRegRS
    if(rst)
        LEDReg <= {DATA_WIDTH{1'b0}};
    else
    begin: LEDREGSet
        if((dMemAddr == {DATA_ADDR_WIDTH{1'b0}}) && dMemWE)
            LEDReg <= dMemDataIn;
        else
            LEDReg <= LEDReg;
    end
end



// RISC V core
uCodedRiscV
#(.DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .RESET_PC_VALUE(10'h000), .INST_ADDR_WIDTH(INST_ADDR_WIDTH))
cpu(.clk(clk), .rst(rst), .clearExceptionCode(clearExceptionCode), .iMemDataIn(iMemData), .dMemDataIn(dMemAddr != {DATA_ADDR_WIDTH{1'b0}} ? dMemDataOut : LEDReg), .iMemAddr(iMemAddr), 
    .iMemRE(iMemRE), .dMemRE(dMemRE), .dMemWE(dMemWE), .dMemByteEn(byteEn), .dMemAddr(dMemAddr), 
.dMemDataOut(dMemDataIn), .exceptionCode(exceptionCode));

// instruction memory
instMem
#(.SIZE(1 << (INST_ADDR_WIDTH)), .DATA_WIDTH(INST_WIDTH), .FALL_THROUGH(1), .ZERO_OUT_RST(0))
iMem(.clk(clk), .rst(rst), .en(iMemRE), .r(iMemRE), .w(), .rAddr({2'b00, iMemAddr[INST_ADDR_WIDTH - 1 : 2]}), .wAddr(), .in(), .out(iMemData));

// data memory (read and write ports, but used as single "write or read" port)
dataMem
#(.SIZE(1 << (DATA_ADDR_WIDTH)), .DATA_WIDTH(DATA_WIDTH), .FALL_THROUGH(0))
dMem(.clk(clk), .rst(rst), .en((dMemRE | dMemWE) & (dMemAddr != {DATA_ADDR_WIDTH{1'b0}})), .r(dMemRE), .w(dMemWE), .rAddr({2'b00, dMemAddr[DATA_ADDR_WIDTH - 1 : 2]}), 
.wAddr({2'b00, dMemAddr[DATA_ADDR_WIDTH - 1 : 2]}), .byteEn(byteEn), .in(dMemDataIn), .out(dMemDataOut));

endmodule 
