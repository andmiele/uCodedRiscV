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

// instMem.sv
// generic synchronous sram module with read and write ports

module instMem
#(parameter SIZE = 16, parameter DATA_WIDTH = 4, parameter FALL_THROUGH = 0, parameter ADDR_WIDTH = $clog2(SIZE), parameter ZERO_OUT_RST = 1'b1)
(
	input logic clk,
	input logic rst,
	input logic en,
	input logic r,
	input logic w,
	input logic[ADDR_WIDTH - 1 : 0] rAddr,
	input logic[ADDR_WIDTH - 1 : 0] wAddr,
	input logic [DATA_WIDTH - 1 : 0] in,
	output logic[DATA_WIDTH - 1 : 0] out
);


logic [DATA_WIDTH - 1 : 0] mem [0 : SIZE - 1];

logic [DATA_WIDTH - 1 : 0] out_r;
logic [DATA_WIDTH - 1 : 0] out_t;

// for FALL THROUGH
assign out_t = mem[rAddr];
assign out = FALL_THROUGH ? out_t : out_r;

  initial begin
    $readmemh("instructionMemory.hex", mem);
  end

always_ff @(posedge clk or posedge rst)
begin
	if(rst)
	begin: reset // set all words to zero
	for(int i = 0; i < SIZE; i++)
        begin: rstMem
              if(ZERO_OUT_RST)
		             mem[i] <= 'b0;
              else
                   mem[i] <= mem[i];
        end
        out_r <= 'b0;
        end
else
begin: run
	if(en)
	begin: enable
		if(w)
		begin: write
			mem[wAddr] <= in;
		end
		if(r)
		begin: read
			out_r <= mem[rAddr];
		end
	end
end
end

endmodule
