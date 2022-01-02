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

// uCodeRiscVFPGA_tb.sv

`include "controlDefs.sv"

module uCodeRiscVFPGA_tb;
localparam period = 10ns;

logic clk;
logic rst;
logic gpio;
logic clearExceptionCode;
logic[1 : 0] exceptionCode;

integer i;

systemTopFPGA sys (clk, rst, clearExceptionCode, gpio, exceptionCode);

// clock signal 
always
    #(period / 2) clk = !clk;

initial
begin
    // reset signal asserted
    clk = 1'b1;
    rst = 1'b0;
    clearExceptionCode = 1'b1;
    #period;
    rst = 1'b1;

    for (i = 0; i < 1024; i = i + 1) 
    begin
        sys.iMem.mem[i] = 32'b0;
    end

    // load instruction memory
    sys.iMem.mem[0] = {20'h00100, 5'd1, `OPCODE_LUI}; // LUI x1,0x00100 (x1 = 2^20)
    sys.iMem.mem[1] = {1'b0, 6'h00, 5'd0, 5'd1, `FUNCT3_BEQ, 4'h6, 1'b0, `OPCODE_BRANCH}; // BEQ x1,x0,6: PC + 12
    sys.iMem.mem[2] = {-12'd1, 5'd1, `FUNCT3_ADDI, 5'd1, `OPCODE_I_TYPE}; // ADDI x1,x1,-1
    sys.iMem.mem[3] = {1'b1, 10'h3FC, 1'b1, 8'hFF, 5'd3, `OPCODE_JAL}; // JAL x3,0xFFFFA: PC - 8
    sys.iMem.mem[4] = {12'd1, 5'd2, `FUNCT3_XORI, 5'd2, `OPCODE_I_TYPE}; // XORI x2,x0,1
    sys.iMem.mem[5] = {7'h00, 5'd2, 5'd0, `FUNCT3_SW, 5'd0, `OPCODE_STORE}; // SW x2,0(x0 = 0)
    sys.iMem.mem[6] = {1'b1, 10'h3F4, 1'b1, 8'hFF, 5'd3, `OPCODE_JAL}; // JAL x3,0xFFFF4: PC - 24

    #period;
    #period;

    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd1048576})
    begin
        $display("ERROR, LUI x1,0x00100 = %4d != 1048576 \n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd8})
    begin
        $display("ERROR, BEQ x1,x0,6 PC = %4d != 8\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd1048575})
    begin
        $display("ERROR, ADDI x1,x1,-1: x3 = %4d != 1048575\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd16})
    begin
        $display("ERROR, JAL x3,0xFFFFA: r3 = %4d != 16\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd4})
    begin
        $display("ERROR, JAL x3,0xFFFFA: PC = %4d != 4\n", sys.cpu.pc);
        $stop;
    end
end

//Monitoring
initial
begin
    $monitor ("R1: %4d, R2: %4d, R3: %4d, R4: %4d, R5: %4d", sys.cpu.regFile.regs[1], sys.cpu.regFile.regs[2], sys.cpu.regFile.regs[3], sys.cpu.regFile.regs[4], sys.cpu.regFile.regs[5]);
end

endmodule
