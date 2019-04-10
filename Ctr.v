`timescale 1ns / 1ps

module Ctr(
    input [5:0] OpCode,
    input [5:0] Funct,
	 output reg RegWriteD,
	 output reg MemtoRegD,
	 output reg MemWriteD,
	 output reg BranchD,
	 output reg [4:0] ALUControlD,
	 output reg ALUSrcD,
    output reg RegDstD
    );
	 reg[1:0] ALUOp;
	 always @(OpCode) 
	 begin
		case(OpCode)
			// R-I
			// addiu
			6'b001001:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			//addi
			6'b001000:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			//andi
			6'b001100:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			
			//
			
			//ori
			6'b001101:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			
			//slti
			6'b001010:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			
			//sltiu
			6'b001011:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			
			//xori
			6'b001110:
			begin
				RegDstD = 0;
				ALUSrcD = 1;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end		
			// R-format
			6'b000000:
			begin
				if((Funct == 5'b011011)||(Funct == 5'b011001))
					RegDstD = 0;
				else
					RegDstD = 1;
				ALUSrcD = 0;
				MemtoRegD = 0;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b10;
			end
			// lw
			6'b100011:
			begin
				RegDstD = 0;
				ALUSrcD = 1;	
				MemtoRegD = 1;
				RegWriteD = 1;
				MemWriteD = 0;
				BranchD = 0;
				ALUOp = 2'b00;
			end
			// sw
			6'b101011:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 1;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 1;
				BranchD = 0;
				ALUOp = 2'b00;
			end
			// beq
			6'b000100:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
			//bne
			6'b000101:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
			
			//bgez
			6'b000001:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
			
			//bgtz
			6'b000111:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
			
			//blez
			6'b000110:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
			
			//bltz
			6'b010001:
			begin
				RegDstD = 1'bx;
				ALUSrcD = 0;
				MemtoRegD = 1'bx;
				RegWriteD = 0;
				MemWriteD = 0;
				BranchD = 1;
				ALUOp = 2'b01;
			end
		endcase
	end
	      
	 always @(ALUOp or Funct) 
	 begin
		casex({OpCode ,ALUOp, Funct}) 
			14'b10001100xxxxxx: ALUControlD = 5'b00010; // LW 
			14'b00010001xxxxxx: ALUControlD = 5'b00110; // beq
			14'b0000001x100001: ALUControlD = 5'b00010; // addu
			14'b0000001x100011: ALUControlD = 5'b00110; // subu
			14'b0000001x100100: ALUControlD = 5'b00000; // AND
			14'b0000001x100101: ALUControlD = 5'b00001; // OR
			14'b0000001x101010: ALUControlD = 5'b00111; // slt
			14'b0000001x101011: ALUControlD = 5'b01010; // sltu
			14'b0000001x011010: ALUControlD = 5'b00011; // div
			14'b0000001x011000: ALUControlD = 5'b00100; // mul 
			14'b0000001x000100: ALUControlD = 5'b00101; 
			14'b0000001x000110: ALUControlD = 5'b01000; 
			14'b0000001x100110: ALUControlD = 5'b01001; // xor
			14'b0010011xxxxxxx: ALUControlD = 5'b00010; // addiu
			14'b0011001xxxxxxx: ALUControlD = 5'b00000; // andi
			14'b0011011xxxxxxx: ALUControlD = 5'b00001; // ori
			14'b0010101xxxxxxx: ALUControlD = 5'b00111; // slti
			14'b0010111xxxxxxx: ALUControlD = 5'b01010; // sltiu
			14'b0011101xxxxxxx: ALUControlD = 5'b01001; // xori
			14'b0000001x000000: ALUControlD = 5'b00101; // sll (Âß¼­×óÒÆ)
			14'b0000001x000010: ALUControlD = 5'b01000; // srl (Âß¼­ÓÒÒÆ)
			14'b0000001x000011: ALUControlD = 5'b01011; // sra £¨ËãÊýÓÒÒÆ£©
			14'b0000001x100000: ALUControlD = 5'b10010; // add
			14'b0000001x100010: ALUControlD = 5'b10011; // sub
			14'b0010001xxxxxxx: ALUControlD = 5'b10010; // addi
			14'b0000001x011011: ALUControlD = 5'b10100; // divu
			14'b0000001x011001: ALUControlD = 5'b10101; // mulu
			14'bzzzzzzxxzzzzzz: ALUControlD = 5'bzzzzz; 
			default: ALUControlD = 5'bzzzzz;
		endcase
	end
endmodule
