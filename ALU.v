`timescale 1ns / 1ps

module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [4:0] ALUCtr,
    output Zero,
    output reg[31:0] ALURes // ALU计算结果
    );
	reg[31:0] HI;
	reg[31:0] LO;
	reg OverFlow;
	reg [31:0] i;
	reg j;
	reg [31:0] TmpForSrcB;
	reg [64:0] A;
	reg [64:0] B;
	reg [64:0] Temp;
	reg [31:0] TmpForSrcA;
	/////////////////////////////////////////////////
	reg Branch = 1;
	assign Zero = (Branch == 0)? 1:0;//Branch 0 跳转
	/////////////////////////////////////////////////
	always @(SrcA or SrcB or ALUCtr)
	begin 
		OverFlow = 0;	
		TmpForSrcB = 0;
		HI = 0;
		LO = 0;
		A = 0;
		B = 0;
		case(ALUCtr)	
			5'b00000:
			begin
				TmpForSrcB = {16'b0,SrcB[15:0]};
				ALURes = SrcA & TmpForSrcB;  
			end
			5'b00001: 
			begin
				TmpForSrcB = {16'b0,SrcB[15:0]};
				ALURes = SrcA | TmpForSrcB; 
			end
			
			5'b00010: ALURes = SrcA + SrcB;
			

			5'b00011: // 有符号除法
			begin
				ALURes = SrcA / SrcB;
				LO = SrcA / SrcB;
				HI = SrcA % SrcB;
			end	
				
			5'b00100: // 有符号乘法
			begin
				A = SrcA[31:31]?{32'hffffffff, SrcA} : {32'h00000000, SrcA};
				B = SrcB[31:31]?{32'hffffffff, SrcB} : {32'h00000000, SrcB};
				Temp = A * B ;
				ALURes = Temp[31:0];
				HI = Temp[63:32];
				LO = Temp[31:0];
			end
			
			5'b00101: ALURes = (SrcB << SrcA);  // my : sllv (逻辑可变左移)
			
			5'b00110:Branch = SrcA - SrcB;
			
			5'b11110:
				Branch = (SrcA >=0)?0:1;
			5'b00111: 
			begin
				ALURes = SrcA<SrcB?1:0;
				Branch = 0;
			end
			
			5'b01000: ALURes = (SrcB >> SrcA);  // my : srav (逻辑可变右移)
			5'b01001:
			begin
			TmpForSrcB = {16'b0,SrcB[15:0]};
			ALURes = (SrcA ^ TmpForSrcB);  // my : xor
			end
			
			5'b01010: 
			begin
				ALURes = {1'b0,SrcA}<{1'b0,SrcB}?1:0;
				Branch = 0;
			end
			
			5'b01011:
			begin
//				TmpForSrcB = SrcB;
//				if (SrcB[31:31])
////				begin
////					for(i=0;i<SrcA;i=i+1)
////					begin
////						TmpForSrcB = TmpForSrcB>>1;
////						TmpForSrcB = {1'b1, TmpForSrcB[30:0]};  
////					end
////				end
//				else
//				begin
//					TmpForSrcB = TmpForSrcB>>SrcA;
//				end
//				ALURes =TmpForSrcB;
			end
			
			5'b01101: 
			begin
			if(SrcA == SrcB)
				Branch = 0;
			else
				Branch = 1;
			end
			5'b01110: 
			begin
				if(SrcA[31:31])
				begin
					Branch = 1;
				end
				else
				begin
					Branch = 0;
				end
			end
			
			
			5'b01111: 
			begin
				if(SrcA[31:31] | SrcA == 0)
				begin
					Branch = 1;
				end
				else
				begin
					Branch = 0;
				end
			end
			
			5'b10000: 
			begin
				if(SrcA[31:31] || SrcA == 0)
				begin
					Branch = 0;
				end
				else
				begin
					Branch = 1;
				end
			end
			5'b10001:
			begin
				if(SrcA[31:31])
				begin
					Branch = 0;
				end
				else
				begin
					Branch = 1;
				end
			end

			5'b10010: 
			begin
				ALURes = SrcA + SrcB;
				if ((SrcA[31] != SrcB[31]) || (SrcA[31] == SrcB[31] && ALURes[31] == SrcA[31]))
					begin
						OverFlow = 1'b0;
					end
				else 
					if (SrcA[31] == SrcB[31] && ALURes[31] != SrcA[31])
					begin
						OverFlow = 1'b1;
					end
			end
			5'b10011: 
			begin
				TmpForSrcB = SrcB;
				TmpForSrcB[31] = (TmpForSrcB[31]+1)%2;
				ALURes = SrcA + TmpForSrcB;
				if ((SrcA[31] != TmpForSrcB[31]) || (SrcA[31] == TmpForSrcB[31] && ALURes[31] == SrcA[31]))
					begin
						OverFlow = 1'b0;
					end
				else 
					if (SrcA[31] == TmpForSrcB[31] && ALURes[31] != SrcA[31])
					begin
						OverFlow = 1'b1;
					end
			end
			
			5'b10100:
			begin
				ALURes = {1'b0,SrcA} / {1'b0,SrcB};
				LO = {1'b0,SrcA} / {1'b0,SrcB};
				HI = {1'b0,SrcA} % {1'b0,SrcB};
			end
			
			5'b10101:
			begin
				Temp ={32'b0,SrcA}*{32'b0,SrcB};
				HI = Temp[63:32];
				LO = Temp[31:0];
				ALURes = Temp[31:0];
			end
			
			default: ALURes = 32'h0;
		endcase
	end

endmodule
