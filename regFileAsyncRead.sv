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

// regFileAsyncRead.sv
// multi-ported register file with transparent read for RISC V core
// reg0 is hardwired to zero
module regFileAsyncRead
#(parameter N_REGS = 32, parameter DATA_WIDTH = 32, parameter N_READ_PORTS = 2, parameter N_WRITE_PORTS = 1,  parameter ADDR_WIDTH = $size(N_REGS))
(
    input logic clk,
    input logic rst,
    input logic we,
    input wire logic [ADDR_WIDTH - 1 : 0] rAddrs [0 : N_READ_PORTS - 1],
    input wire logic [ADDR_WIDTH - 1 : 0] wAddrs [0 : N_WRITE_PORTS - 1],
    input wire logic [DATA_WIDTH - 1 : 0] wPorts [0 : N_WRITE_PORTS - 1],
    output wire logic [DATA_WIDTH - 1 : 0] rPorts [0 : N_READ_PORTS - 1]
);

logic [DATA_WIDTH - 1 : 0] regs [0 : N_REGS - 1];

// read
genvar j;
generate
for (j = 0; j < N_READ_PORTS; j++)
begin: readPorts
    assign rPorts[j] = regs[rAddrs[j]];
end
endgenerate

always_ff @(posedge clk or posedge rst)
begin: rf

    if (rst)
    begin: reset // set all registers to zero
        for(int i = 0; i < N_REGS; i++)
            regs[i] <= 'b0;
    end
    else        
    begin: write // register file write operations
        if (we)
        begin: writeEnabled
            for (int i = 0; i < N_WRITE_PORTS; i++)
            if(wAddrs[i] != 'b0)
                regs[wAddrs[i]] <= wPorts[i];
        end
    end

end
endmodule
