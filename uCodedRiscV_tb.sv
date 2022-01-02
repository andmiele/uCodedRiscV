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

// uCodeRiscV_tb.sv

`include "controlDefs.sv"

module uCodeRiscV_tb;
localparam period = 10ns;

logic clk;
logic rst;
logic clearExceptionCode;
logic[1 : 0] exceptionCode;

integer i;

systemTop sys (clk, rst, clearExceptionCode, exceptionCode);

// clock signal 
always
begin
    #(period / 2) clk = !clk;
end

initial
begin
    // reset signal asserted
    clk = 1'b1;
    rst = 1'b1;
    clearExceptionCode = 1'b0;
    #period;
    rst = 1'b0;
    for (i = 1; i < 32; i = i + 1)
    begin
        sys.cpu.regFile.regs[i] = 100 + i;
    end
    for (i = 0; i < 1024; i = i + 1) 
    begin
        sys.iMem.mem[i] = 32'b0;
    end
    // load instruction memory
    sys.iMem.mem[0] = {-12'd1, 5'd1, `FUNCT3_ADDI, 5'd1, `OPCODE_I_TYPE}; // ADDI x1,x1,-1
    sys.iMem.mem[1] = {12'd67, 5'd2, `FUNCT3_SLTI, 5'd3, `OPCODE_I_TYPE}; // SLTI x3,x2,67
    sys.iMem.mem[2] = {12'd134, 5'd2, `FUNCT3_SLTI, 5'd3, `OPCODE_I_TYPE}; // SLTI x3,x2,134
    sys.iMem.mem[3] = {-12'd1, 5'd2, `FUNCT3_SLTI, 5'd3, `OPCODE_I_TYPE}; // SLTI x3,x2,-1
    sys.iMem.mem[4] = {12'd4095, 5'd1, `FUNCT3_SLTIU, 5'd4, `OPCODE_I_TYPE}; // SLTI x4,x1,4095
    sys.iMem.mem[5] = {12'd0, 5'd1, `FUNCT3_SLTIU, 5'd5, `OPCODE_I_TYPE}; // SLTIU x5,x1,0
    sys.iMem.mem[6] = {12'd102, 5'd2, `FUNCT3_XORI, 5'd1, `OPCODE_I_TYPE}; // XORI x1,x2,102
    sys.iMem.mem[7] = {12'd2048, 5'd1, `FUNCT3_ORI, 5'd1, `OPCODE_I_TYPE}; // ORI x1,x1,10...0
    sys.iMem.mem[8] = {12'd33, 5'd1, `FUNCT3_ANDI, 5'd2, `OPCODE_I_TYPE}; // ANDI x2,x1,33
    sys.iMem.mem[9] = {12'd5, 5'd4, `FUNCT3_SLLI, 5'd5, `OPCODE_I_TYPE}; // SLLI x5,x4,5
    sys.iMem.mem[10] = {12'd5, 5'd5, `FUNCT3_SRLI, 5'd5, `OPCODE_I_TYPE}; // SRLI x5,x5,5
    sys.iMem.mem[11] = {12'd1029, 5'd1, `FUNCT3_SRAI, 5'd1, `OPCODE_I_TYPE}; // SRAI x1,x1,5
    sys.iMem.mem[12] = {`FUNCT7_ADD, 5'd1, 5'd1, `FUNCT3_ADD, 5'd1, `OPCODE_R_TYPE}; // ADD x1,x1,x1
    sys.iMem.mem[13] = {`FUNCT7_SUB, 5'd5, 5'd1, `FUNCT3_SUB, 5'd2, `OPCODE_R_TYPE}; // SUB x2,x1,x5
    sys.iMem.mem[14] = {`FUNCT7_SLL, 5'd4, 5'd2, `FUNCT3_SLL, 5'd3, `OPCODE_R_TYPE}; // SLL x3,x2,x4
    sys.iMem.mem[15] = {`FUNCT7_SLT, 5'd3, 5'd1, `FUNCT3_SLT, 5'd5, `OPCODE_R_TYPE}; // SLT x5,x1,x3   
    sys.iMem.mem[16] = {`FUNCT7_SUB, 5'd4, 5'd5, `FUNCT3_SUB, 5'd1, `OPCODE_R_TYPE}; // SUB x1,x5,x4
    sys.iMem.mem[17] = {`FUNCT7_SLT, 5'd1, 5'd2, `FUNCT3_SLT, 5'd5, `OPCODE_R_TYPE}; // SLT x5,x2,x1 
    sys.iMem.mem[18] = {`FUNCT7_SLTU, 5'd2, 5'd1, `FUNCT3_SLTU, 5'd5, `OPCODE_R_TYPE}; // SLTU x5,x1,x2
    sys.iMem.mem[19] = {`FUNCT7_SLTU, 5'd1, 5'd2, `FUNCT3_SLTU, 5'd5, `OPCODE_R_TYPE}; // SLTU x5,x2,x1
    sys.iMem.mem[20] = {`FUNCT7_XOR, 5'd1, 5'd4, `FUNCT3_XOR, 5'd1, `OPCODE_R_TYPE}; // XOR x1,x4,x1
    sys.iMem.mem[21] = {`FUNCT7_SRL, 5'd4, 5'd1, `FUNCT3_SRL, 5'd2, `OPCODE_R_TYPE}; // SRL x2,x1,x4
    sys.iMem.mem[22] = {`FUNCT7_SRA, 5'd4, 5'd1, `FUNCT3_SRA, 5'd3, `OPCODE_R_TYPE}; // SRA x3,x1,x4
    sys.iMem.mem[23] = {`FUNCT7_OR, 5'd4, 5'd1, `FUNCT3_OR, 5'd3, `OPCODE_R_TYPE}; // OR x3,x1,x4
    sys.iMem.mem[24] = {`FUNCT7_AND, 5'd4, 5'd1, `FUNCT3_AND, 5'd3, `OPCODE_R_TYPE}; // AND x3,x1,x4
    sys.iMem.mem[25] = {20'hFFFFF, 5'd3, `OPCODE_LUI}; // LUI x3,0xFFFFF
    sys.iMem.mem[26] = {20'hFFFFF, 5'd3, `OPCODE_AUIPC}; // AUIPC x3,0xFFFFF
    sys.iMem.mem[27] = {1'b0, 10'h006, 1'b0, 8'h00, 5'd3, `OPCODE_JAL}; // JAL x3,0x00006: PC + 12
    sys.iMem.mem[28] = {1'b0, 10'h008, 1'b0, 8'h00, 5'd3, `OPCODE_JAL}; // JAL x3,0x00008: PC + 16
    sys.iMem.mem[29] = {1'b0, 10'h004, 1'b0, 8'h00, 5'd3, `OPCODE_JAL}; // JAL x3,0x00004: PC + 8
    sys.iMem.mem[30] = {1'b1, 10'h3FE, 1'b1, 8'hFF, 5'd3, `OPCODE_JAL}; // JAL x3,0xFFFFE: PC - 4
    sys.iMem.mem[31] = {12'd132, 5'd4,`FUNCT3_JALR, 5'd3, `OPCODE_JALR}; // JALR x3,x4,132: PC = 133 = 132 
    sys.iMem.mem[32] = {12'd135, 5'd4,`FUNCT3_JALR, 5'd3, `OPCODE_JALR}; // JALR x3,x4,135: PC = 136(34*4)   
    sys.iMem.mem[33] = {-12'd16, 5'd3,`FUNCT3_JALR, 5'd3, `OPCODE_JALR}; // JALR x3,x3,-16: PC = 112(28*4)
    sys.iMem.mem[34] = {1'b0, 6'h00, 5'd4, 5'd5, `FUNCT3_BEQ, 4'h4, 1'b0, `OPCODE_BRANCH}; // BEQ x5,x4,4: PC + 8  
    sys.iMem.mem[35] = {1'b0, 6'h00, 5'd3, 5'd5, `FUNCT3_BNE, 4'h4, 1'b0, `OPCODE_BRANCH}; // BNE x5,x3,4: PC + 8  
    sys.iMem.mem[36] = {1'b1, 6'h3F, 5'd4, 5'd5, `FUNCT3_BEQ, 4'hE, 1'b1, `OPCODE_BRANCH}; // BEQ x5,x4,-2: PC - 4
    sys.iMem.mem[37] = {1'b0, 6'h00, 5'd4, 5'd1, `FUNCT3_BLT, 4'h4, 1'b0, `OPCODE_BRANCH}; // BLT x1,x4,4: PC + 8
    sys.iMem.mem[38] = {1'b0, 6'h00, 5'd1, 5'd4, `FUNCT3_BLTU, 4'h4, 1'b0, `OPCODE_BRANCH}; // BLTU x4,x1,4: PC + 8
    sys.iMem.mem[39] = {1'b1, 6'h3F, 5'd4, 5'd5, `FUNCT3_BGE, 4'hE, 1'b1, `OPCODE_BRANCH}; // BGE x5,x4,-2: PC - 4
    sys.iMem.mem[40] = {1'b0, 6'h00, 5'd3, 5'd2, `FUNCT3_BGEU, 4'h4, 1'b0, `OPCODE_BRANCH}; // BGEU x2,x3,4: PC + 8
    sys.iMem.mem[41] = {1'b0, 6'h00, 5'd1, 5'd3, `FUNCT3_BGE, 4'h4, 1'b0, `OPCODE_BRANCH}; // BGE x3,x1,4: PC + 8    
    sys.iMem.mem[42] = {1'b1, 6'h3F, 5'd4, 5'd5, `FUNCT3_BGEU, 4'hE, 1'b1, `OPCODE_BRANCH}; // BGEU x5,x4,-2: PC - 4  
    sys.iMem.mem[43] = {1'b0, 6'h00, 5'd4, 5'd5, `FUNCT3_BNE, 4'h4, 1'b0, `OPCODE_BRANCH}; // BNE x5,x4,4: PC + 4  
    sys.iMem.mem[44] = {1'b1, 6'h3F, 5'd4, 5'd1, `FUNCT3_BEQ, 4'hE, 1'b1, `OPCODE_BRANCH}; // BEQ x1,x4,-2: PC + 4
    sys.iMem.mem[45] = {1'b0, 6'h00, 5'd1, 5'd4, `FUNCT3_BLT, 4'h4, 1'b0, `OPCODE_BRANCH}; // BLT x4,x1,4: PC + 4
    sys.iMem.mem[46] = {1'b0, 6'h00, 5'd4, 5'd1, `FUNCT3_BLTU, 4'h4, 1'b0, `OPCODE_BRANCH}; // BLTU x1,x4,4: PC + 4
    sys.iMem.mem[47] = {1'b1, 6'h3F, 5'd4, 5'd1, `FUNCT3_BGE, 4'hE, 1'b1, `OPCODE_BRANCH}; // BGE x1,x4,-2: PC + 4
    sys.iMem.mem[48] = {1'b0, 6'h00, 5'd2, 5'd3, `FUNCT3_BGEU, 4'h4, 1'b0, `OPCODE_BRANCH}; // BGEU x3,x2,4: PC + 4   
    sys.iMem.mem[49] = {7'h00, 5'd1, 5'd4, `FUNCT3_SB, 5'd3, `OPCODE_STORE}; // SB x1,3(x4 = 1)       
    sys.iMem.mem[50] = {7'h00, 5'd5, 5'd4, `FUNCT3_SB, 5'd4, `OPCODE_STORE}; // SB x5,4(x4 = 1)
    sys.iMem.mem[51] = {7'h00, 5'd2, 5'd4, `FUNCT3_SB, 5'd5, `OPCODE_STORE}; // SB x2,5(x4 = 1)  
    sys.iMem.mem[52] = {7'h00, 5'd3, 5'd4, `FUNCT3_SB, 5'd6, `OPCODE_STORE}; // SB x3,6(x4 = 1)  
    sys.iMem.mem[53] = {7'h00, 5'd2, 5'd4, `FUNCT3_SH, 5'd7, `OPCODE_STORE}; // SH x2,7(x4 = 1)  
    sys.iMem.mem[54] = {7'h00, 5'd1, 5'd4, `FUNCT3_SH, 5'd9, `OPCODE_STORE}; // SH x1,9(x4 = 1)
    sys.iMem.mem[55] = {7'h00, 5'd1, 5'd4, `FUNCT3_SW, 5'd11, `OPCODE_STORE}; // SW x1,11(x4 = 1)
    sys.iMem.mem[56] = {12'd3, 5'd4, `FUNCT3_LB, 5'd3, `OPCODE_LOAD}; // LB x3,3(x4 = 1) 
    sys.iMem.mem[57] = {12'd4, 5'd4, `FUNCT3_LB, 5'd3, `OPCODE_LOAD}; // LB x3,4(x4 = 1)     
    sys.iMem.mem[58] = {12'd5, 5'd4, `FUNCT3_LB, 5'd3, `OPCODE_LOAD}; // LB x3,5(x4 = 1)  
    sys.iMem.mem[59] = {12'd6, 5'd4, `FUNCT3_LB, 5'd3, `OPCODE_LOAD}; // LB x3,6(x4 = 1)
    sys.iMem.mem[60] = {12'd7, 5'd4, `FUNCT3_LH, 5'd3, `OPCODE_LOAD}; // LH x3,7(x4 = 1)
    sys.iMem.mem[61] = {12'd9, 5'd4, `FUNCT3_LH, 5'd3, `OPCODE_LOAD}; // LH x3,9(x4 = 1) 
    sys.iMem.mem[62] = {12'd11, 5'd4, `FUNCT3_LW, 5'd3, `OPCODE_LOAD}; // LW x3,11(x4 = 1)
    sys.iMem.mem[63] = {`FUNCT7_ADD, 5'd0, 5'd4, `FUNCT3_ADD, 5'd1, `OPCODE_R_TYPE}; // ADD x1,x4,x0
    sys.iMem.mem[64] = {`FUNCT7_ADD, 5'd0, 5'd4, `FUNCT3_ADD, 5'd0, `OPCODE_R_TYPE}; // ADD x0,x4,x0
    sys.iMem.mem[65] = {7'h00, 5'd2, 5'd4, `FUNCT3_SH, 5'd8, `OPCODE_STORE}; // SH x2,8(x4 = 1)  
    sys.iMem.mem[66] = {7'h00, 5'd2, 5'd4, `FUNCT3_SW, 5'd1, `OPCODE_STORE}; // SH x2,1(x4 = 1)
    sys.iMem.mem[67] = {12'd10, 5'd4, `FUNCT3_LH, 5'd3, `OPCODE_LOAD}; // LH x3,10(x4 = 1) 
    sys.iMem.mem[68] = {12'd12, 5'd4, `FUNCT3_LW, 5'd3, `OPCODE_LOAD}; // LW x3,12(x4 = 1)
    sys.iMem.mem[69] = {1'b0, 10'h007, 1'b0, 8'h00, 5'd3, `OPCODE_JAL}; // JAL x3,0x00007: PC + 14
    sys.iMem.mem[70] = {12'd133, 5'd4,`FUNCT3_JALR, 5'd3, `OPCODE_JALR}; // JALR x3,x4,133: PC = 134
    sys.iMem.mem[71] = {32'hffffffff}; // 0xffffffff unknown instruction
    #period;
    #period;

    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd100})
    begin
        $display("ERROR, ADDI x1,x1,-1: x1 = %4d != 100\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd0})
    begin
        $display("ERROR, SLTI x3,x2,67: x3 = %4d != 0\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd1})
    begin
        $display("ERROR, SLTI x3,x2,134: x3 = %4d != 1\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd0})
    begin
        $display("ERROR, SLTI x3,x2,-1: x3 = %4d != 0\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[4] != {32'd1})
    begin
        $display("ERROR, SLTI x4,x1,4095: x4 = %4d != 1\n", sys.cpu.regFile.regs[4]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd0})
    begin
        $display("ERROR, SLTIU x5,x1,0: x5 = %4d != 0\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd0})
    begin
        $display("ERROR, XORI x1,x2,102: x1 = %4d != 0\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd4294965248})
    begin
        $display("ERROR, ORI x1,x1,10...0 = %4d != 4294965248\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[2] != {32'd0})
    begin
        $display("ERROR, ANDI x2,x1,33 = %4d != 0\n", sys.cpu.regFile.regs[2]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd32})
    begin
        $display("ERROR, SLLI x5,x4,5 = %4d != 32\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd1})
    begin
        $display("ERROR, SRLI x5,x5,5 = %4d != 1\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd4294967232})
    begin
        $display("ERROR, SRAI x1,x1,5 = %4d != 134217664\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    $display("I-TYPE TEST PASSED!\n");
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd4294967168})
    begin
        $display("ERROR, ADD x1,x1,x1 = %4d != 4294967168\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[2] != {32'd4294967167})
    begin
        $display("ERROR, SUB x2,x1,x5 = %4d != 268435327\n", sys.cpu.regFile.regs[2]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd4294967038})
    begin
        $display("ERROR, SLL x3,x2,x4 = %4d != 4294967038\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd0})
    begin
        $display("ERROR, SLT x5,x1,x3 = %4d != 0\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd0})
    begin
        $display("ERROR, SLT x5,x3,x1 = %4d != 0\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {-32'd1})
    begin
        $display("ERROR, SUB x1,x5,x4 = %4d != -1\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    if(sys.cpu.regFile.regs[5] != {32'd1})
    begin
        $display("ERROR, SLT x5,x1,x2 = %4d != 1\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd0})
    begin
        $display("ERROR, SLTU x5,x1,x2 = %4d != 0\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[5] != {32'd1})
    begin
        $display("ERROR, SLTU x5,x2,x1 = %4d != 1\n", sys.cpu.regFile.regs[5]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {-32'd2})
    begin
        $display("ERROR, XOR x1,x4,x1 = %4d != -2\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[2] != {32'd2147483647})
    begin
        $display("ERROR, SRL x2,x1,x4 = %4d != 2147483647\n", sys.cpu.regFile.regs[2]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd4294967295})
    begin
        $display("ERROR, SRA x3,x1,x4 = %4d != 4294967295\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd4294967295})
    begin
        $display("ERROR, OR x3,x1,x4 = %4d != 4294967295\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd0})
    begin
        $display("ERROR, AND x3,x1,x4 = %4d != 0\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    $display("R-TYPE TEST PASSED!\n");
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hFFFFF000})
    begin
        $display("ERROR, LUI x3,0xFFFFF = %4H != 0xFFFFF000\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    $display("LUI TEST PASSED!\n");
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hFFFFF068})
    begin
        $display("ERROR, AUIPC x3,0xFFFFF = %4H != 0xFFFFF068\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    $display("AUIPC TEST PASSED!\n");
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd112})
    begin
        $display("ERROR, JAL x3,0x00006 r3= %4d != 112\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd120})
    begin
        $display("ERROR, JAL x3,0x00006 PC = %4d != 120\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd124})
    begin
        $display("ERROR, JAL x3,0xFFFFE r3 = %4d != 124\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd116})
    begin
        $display("ERROR, JAL x3,0xFFFFE PC = %4d != 116\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd120})
    begin
        $display("ERROR, JAL x3, 0x00004 r3 = %4d != 124\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd124})
    begin
        $display("ERROR, JAL x3,0x00004: PC = %4d != 124\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd128})
    begin
        $display("ERROR, JALR x3,x4,132: r3 = %4d != 128\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd132})
    begin
        $display("ERROR, JALR x3,x4,132: PC = %4d != 132\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd136})
    begin
        $display("ERROR, JALR x3,x3,-16: r3 = %4d != 136\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd112})
    begin
        $display("ERROR, JALR x3,x4,-16 PC = %4d != 112\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd116})
    begin
        $display("ERROR, JAL x3,0x00008 r3 = %4d != 116\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd128})
    begin
        $display("ERROR, JAL x3,0x00008: PC = %4d != 128\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'd132})
    begin
        $display("ERROR, JALR x3,x4,135: r1 = %4d != 132\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    if(sys.cpu.pc != {32'd136})
    begin
        $display("ERROR, JALR x3,x4,135 PC = %4d != 136\n", sys.cpu.pc);
        $stop;
    end
    $display("JAL, JALR TEST PASSED!\n");
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd144})
    begin
        $display("ERROR, BEQ x5,x4,4 PC = %4d != 144\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd140})
    begin
        $display("ERROR, BEQ x5,x4,-2 PC = %4d != 140\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd148})
    begin
        $display("ERROR, BNE x5,x3,4 PC = %4d != 148\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd156})
    begin
        $display("ERROR, BLT x1,x4,4 PC = %4d != 156\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd152})
    begin
        $display("ERROR, BGE x5,x4,-2 PC = %4d != 152\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd160})
    begin
        $display("ERROR, BLTU x4,x1,4 PC = %4d != 160\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd168})
    begin
        $display("ERROR, BGEU x2,x3,4 PC = %4d != 168\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd164})
    begin
        $display("ERROR, BGEU x5,x4,-2 PC = %4d != 164\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd172})
    begin
        $display("ERROR, BGE x3,x1,4 PC = %4d != 172\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd176})
    begin
        $display("ERROR, BNE x5,x4,4 PC = %4d != 176\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd180})
    begin
        $display("ERROR, BEQ x1,x4,-2 PC = %4d != 180\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd184})
    begin
        $display("ERROR, BLT x4,x1,4 PC = %4d != 184\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd188})
    begin
        $display("ERROR, BLTU x1,x4,4 PC = %4d != 188\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd192})
    begin
        $display("ERROR, BGE x1,x4,-2 PC = %4d != 192\n", sys.cpu.pc);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.pc != {32'd196})
    begin
        $display("ERROR, BGEU x3,x2,4, PC = %4d != 196\n", sys.cpu.pc);
        $stop;
    end
    $display("BRANCH TEST PASSED!\n");
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[1] != {32'd254})
    begin
        $display("ERROR, SB x1, 3(x4 = 1), dMem[1] = %4d != 254\n", sys.dMem.mem[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[1] != {32'h01fe})
    begin
        $display("ERROR, SB x5, 4(x4 = 1), dMem[1] = 0x%4H != 0x01fe\n", sys.dMem.mem[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[1] != {32'hff01fe})
    begin
        $display("ERROR, SB x2, 5(x4 = 1), dMem[1] = 0x%4H != 0xff01fe\n", sys.dMem.mem[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[1] != {32'h84ff01fe})
    begin
        $display("ERROR, SB x3, 6(x4 = 1), dMem[1] = 0x%4H != 0x84ff01fe\n", sys.dMem.mem[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[2] != {32'hffff})
    begin
        $display("ERROR, SH x2, 7(x4 = 1), dMem[2] = 0x%4H != 0xffff\n", sys.dMem.mem[2]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[2] != {32'hfffeffff})
    begin
        $display("ERROR, SH x1, 9(x4 = 1), dMem[2] = 0x%4H != 0xfffeffff\n", sys.dMem.mem[2]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.dMem.mem[3] != {32'hfffffffe})
    begin
        $display("ERROR, SW x1, 9(x4 = 1), dMem[3] = 0x%4H != 0xfffffffe\n", sys.dMem.mem[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hfffffffe})
    begin
        $display("ERROR, LB x3, 3(x4 = 1), R3 = 0x%4H != 0xfffffffe\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'h1})
    begin
        $display("ERROR, LB x3, 4(x4 = 1), R3 = 0x%4H != 0x1\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hffffffff})
    begin
        $display("ERROR, LB x3, 5(x4 = 1), R3 = 0x%4H != 0xffffffff\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hffffff84})
    begin
        $display("ERROR, LB x3, 6(x4 = 1), R3 = 0x%4H != 0xffffff84\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hffffffff})
    begin
        $display("ERROR, LH x3, 7(x4 = 1), R3 = 0x%4H != 0xffffffff\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hfffffffe})
    begin
        $display("ERROR, LH x3, 9(x4 = 1), R3 = 0x%4H != 0xfffffffe\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    #period;
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[3] != {32'hfffffffe})
    begin
        $display("ERROR, LW x3, 11(x4 = 1), R3 = 0x%4H != 0xfffffffe\n", sys.cpu.regFile.regs[3]);
        $stop;
    end
    $display("LOAD/STORE TEST PASSED!\n");
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[1] != {32'd1})
    begin
        $display("ERROR, ADD x1,x4,x0 = %4d != 1\n\n", sys.cpu.regFile.regs[1]);
        $stop;
    end
    #period;
    #period;
    #period;
    if(sys.cpu.regFile.regs[0] != {32'd0})
    begin
        $display("ERROR, ADD x0,x4,x0 = %4d != 0\n\n", sys.cpu.regFile.regs[0]);
        $stop;
    end
    $display("R0 TEST PASSED!\n");
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, SH x2, 8(x4 = 1) did not generate an exception\n");
        $stop;
    end
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1;
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, SW x2, 1(x4 = 1) did not generate an exception\n");
        $stop;
    end
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1; 
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, LH x3,10(x4 = 1) did not generate an exception\n");
        $stop;
    end
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1; 
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, LW x3,12(x4 = 1) did not generate an exception\n");
        $stop;
    end
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1; 
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, JAL x3,0x00007: PC + 14 did not generate an exception\n");
        $stop;
    end
    sys.cpu.pc = 32'd280;
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1;
    #period;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `MISALIGNED_ADDRESS_EXCEPTION)
    begin
        $display("ERROR, JALR x3,x4,133: PC = 134 did not generate an exception\n");
        $stop;
    end
    $display("MISALIGNED ADDRESS TEST PASSED!\n");
    sys.cpu.pc = 32'd284;
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1;
    #period;
    #period;
    #period;
    if(sys.exceptionCode != `UNKNOWN_INSTRUCTION_EXCEPTION)
    begin
        $display("ERROR, 0xffffffff did not generate an unknown instruction exception\n");
        $stop;
    end
    sys.cpu.uPCSel = `MICRO_PC_SEL_FETCH;
    clearExceptionCode = 1'b1; 
    $display("UNKNOWN INSTRUCTION EXCEPTION TEST PASSED!\n");
    $stop;
end

//Monitoring
initial
begin
    $monitor ("R1: %4d, R2: %4d, R3: %4d, R4: %4d, R5: %4d", sys.cpu.regFile.regs[1], sys.cpu.regFile.regs[2], sys.cpu.regFile.regs[3], sys.cpu.regFile.regs[4], sys.cpu.regFile.regs[5]);
end

endmodule
