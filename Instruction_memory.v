`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Instruction_memory(
	 input Clk,
    input [31:0] ImemRdAddr,
    output reg[31:0] Instruction
    );
	 reg[31:0] InstMem[0:255];//memory space for storing instructions
	 //initial the instruction and data memory initial 
	 initial
	 begin
		$readmemh("instruction", InstMem, 8'h0);
	 end
		
	 //always @(posedge Clk)	
	 always @(ImemRdAddr)
	 begin
		Instruction <= InstMem[ImemRdAddr>>2];
	 end


endmodule
