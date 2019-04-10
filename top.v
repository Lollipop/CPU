`timescale 1ns / 1ps

module top(
	 input ClkIn,
	 input Rst,
    output [7:0] led,
	 output [31:0] ResultTop
    );


assign led[7:0] = InstructionF[7:0];
assign ResultTop = (MemtoRegW)? ReadDataW : ALUOutW;  //判断最终的结果是来自ALU还是主存
reg [4:0] stall=5'b11111;
reg flag = 1'bz;
// ------------------Fetch-------------
// PC
reg [31:0] PCF = 32'h0;
wire [31:0] PCPlus4F;

reg [31:0] PCPlus4F_Reg;
// Instruction
wire [31:0] ImemRdAddrF;
wire [31:0] InstructionF;
reg [31:0] InstructionF_Reg;
// -------------------Decode------------
wire [31:0] InstructionD;
// Control
wire [5:0] OpCode;
wire [5:0] Funct;
wire RegWriteForCtrD;
wire MemtoRegD;
wire MemWriteD;
wire BranchD;
wire [4:0] ALUControlD;
wire ALUSrcD;
wire RegDstD;


reg  [1:0] HazardD=2'b00;
reg [1:0] HazardB = 2'b00;
reg stallB = 0;

reg RegWriteForCtrD_Reg;
reg MemtoRegD_Reg;
reg MemWriteD_Reg;
reg BranchD_Reg;
reg [4:0] ALUControlD_Reg;
reg ALUSrcD_Reg;
reg RegDstD_Reg;
// Rigster
wire RegWriteForRegisterD;
wire [4:0] RegARdAddrD;
wire [4:0] RegBRdAddrD;
wire [4:0] RegWrAddrD;  // A3
wire [31:0] RegWrDataD; // WD3
wire [31:0] RegARdDataD;
wire [31:0] RegBRdDataD;

reg [31:0] RegARdDataD_Reg;
reg [31:0] RegBRdDataD_Reg;
// SignExt
wire [15:0] inst16D;
wire [31:0] SignImmD;
reg [31:0] SignImmD_Reg;
// else
wire [31:0] PCPlus4D;
reg [31:0] PCPlus4D_Reg;
reg [4:0] RtE_Reg;
reg [4:0] RdE_Reg;

//------------------Execute-------------
//Control
wire RegWriteForCtrE;
wire MemtoRegE;
wire MemWriteE;
wire BranchE;
wire [4:0] ALUControlE;
wire ALUSrcE;
wire RegDstE;
wire [4:0] WriteRegE;

reg RegWriteForCtrE_Reg;
reg MemtoRegE_Reg;
reg MemWriteE_Reg;
reg BranchE_Reg;
reg [4:0] ALUControlE_Reg;
reg ALUSrcE_Reg;
reg RegDstE_Reg;
// ALU
wire [31:0] SrcAE;
wire [31:0] SrcBE;
wire [4:0] ALUCtrE;
wire ZeroE;
wire [31:0] ALUResE;
reg [31:0] ALUResE_Reg;
reg ZeroE_Reg;
wire OverFlowE;


// Data Memory
wire [31:0] WriteDataE;
reg [31:0] WriteDataE_Reg;
// else
wire [4:0] RtE;
wire [4:0] RdE;
reg [4:0] WriteRegE_Reg;

wire [31:0] SignImmE;
wire [31:0] PCPlus4E;
reg [31:0] PCBranchE_Reg;

//------------------Memory-------------
//Control
wire RegWriteForCtrM;
wire MemtoRegM;
wire MemWriteM;
wire BranchM;

reg RegWriteForCtrM_Reg;
reg MemtoRegM_Reg;
reg MemWriteM_Reg;
reg BranchM_Reg;
// ALU
wire ZeroM;
// Data Memory
wire [31:0] DmemAddrM; // A
reg [31:0] DmemAddrM_Reg; 
wire [31:0] DmemWrDataM; // WD	 
wire DmemWriteM;

wire [31:0] DmemRdDataM; // RD
reg [31:0] DmemRdDataM_Reg; // RD
// else 
wire [4:0] WriteRegM;
reg [4:0] WriteRegM_Reg;
wire [31:0] PCBranchM;


//------------------Writeback-------------
//ControlW
wire RegWriteForCtrW;
wire MemtoRegW;
//else
// Data Memory
wire [31:0] ALUOutW; // AW
wire [31:0] ReadDataW; // RD
wire [4:0] WriteRegW;
 

Clk_gen Clock(
		.CLK_IN1(ClkIn),
		.RESET(Rst),
		.CLK_OUT1(Clk),
		.LOCKED()
);



Data_memory Data_memory(
		.Clk(Clk),
		.DmemAddr(DmemAddrM),
		.DmemWrData(DmemWrDataM),
		.DmemWrite(DmemWriteM),
		.DmemRdData(DmemRdDataM)
);

register myReg(
		.Clk(Clk),
		.RegARdAddr(RegARdAddrD),
		.RegBRdAddr(RegBRdAddrD),
		.RegWrAddr(RegWrAddrD),
		.RegWrData(RegWrDataD),
		.RegWrite(RegWriteForRegisterD),
		.RegARdData(RegARdDataD),
		.RegBRdData(RegBRdDataD)
);

signext signext(
		.inst16(inst16D),
		.SignImm(SignImmD)
);

// ------------------Fetch-------------
// PC


assign ImemRdAddrF = (stall[0])? PCF:ImemRdAddrF;

Instruction_memory myInstruction_memory(
		.Clk(Clk),
		.ImemRdAddr(ImemRdAddrF),
		.Instruction(InstructionF)
);

always @(posedge Clk) 
begin
	if((flag == 1) && !(stall[0]) )
	begin
		PCF= PCF - 4;
		flag = 0;
	end
	else if((flag == 0) && (!(stall[0])||stallB))
		PCF = PCF;
	else
		PCF = PCF + 4;

	if (BranchM&ZeroM) PCF = PCBranchM; //当跳转字段和跳转条件均满足时，赋值跳转地址
	
	InstructionF_Reg = InstructionF;
	PCPlus4F_Reg = PCF;

	if (InstructionF[31:26] == 6'b000010) //如果为jump指令
	begin 
		PCF = {PCF[31:28],InstructionF[25:0],2'b00};
	end

	if(HazardB!=0)
	begin
		HazardB=HazardB-1;
		InstructionF_Reg = 32'bz;
		PCPlus4F_Reg = 32'bz;
		if(HazardB==0)
		begin
			stallB = 0;
		end
	end
	if((HazardB == 0)&&(HazardD==0)&&((InstructionF[31:26] == 6'b000101) ||(InstructionF[31:26] == 6'b000001)||(InstructionF[31:26] == 6'b000111)||(InstructionF[31:26] == 6'b000110)||(InstructionF[31:26] == 6'b010001) || (InstructionF[31:26] == 6'b000100)))
	begin
		HazardB = 3;
		stallB = 1;
	end
end

// -----------------Decode--------------

assign PCPlus4D = (stall[1])? PCPlus4F_Reg : PCPlus4D;   
// Control input
assign InstructionD = (stall[1])?InstructionF_Reg:InstructionD; 

assign OpCode = InstructionD[31 : 26];  
assign Funct = InstructionD[5 : 0];
//Register File input

assign RegARdAddrD = InstructionD[25:21];
assign RegBRdAddrD = InstructionD[20:16];

assign RegWrAddrD = 	WriteRegW;
assign RegWrDataD = (MemtoRegW)? ReadDataW : ALUOutW;  //判断写回的数据是来自ALU还是主存
assign RegWriteForRegisterD = RegWriteForCtrW;  //寄存器写信号
assign inst16D = InstructionD[15 : 0];    //立即数
//// For 立即数移位
reg [31:0] SrcAInput_RegD;
reg Judge_RegD;

/////////////////

Ctr myCtr(
		.OpCode(OpCode),
		.Funct(Funct),
		.RegWriteD(RegWriteForCtrD),
		.MemtoRegD(MemtoRegD),
		.MemWriteD(MemWriteD),
		.BranchD(BranchD),
		.ALUControlD(ALUControlD),
		.ALUSrcD(ALUSrcD),
		.RegDstD(RegDstD)
);

ALU myALU(
		.SrcA(SrcAE),
		.SrcB(SrcBE),
		.ALUCtr(ALUCtrE),
		.Zero(ZeroE),
		.ALURes(ALUResE)
);

always @(posedge Clk) 
begin
	if(HazardD!=0)
	begin
		HazardD=HazardD-1;
		if(HazardD==0)
		begin
			stall=5'b11111;
		end
	end
   
		  //数据冲突检测
	if((HazardB == 0)&&(InstructionD[25:21]==WriteRegE || InstructionD[20:16]==WriteRegE)&&(HazardD==0))
	begin
		HazardD = 3;
		stall=5'b11100;
		flag = 1;
	end
	else if((HazardB == 0)&&(InstructionD[25:21]==WriteRegM || InstructionD[20:16]==WriteRegM)&&(HazardD==0))
	begin
	  HazardD = 2;
	  stall=5'b11100;
	  flag = 1;
	end
	else if((HazardB == 0)&&(InstructionD[25:21]==WriteRegW || InstructionD[20:16]==WriteRegW)&&(HazardD==0))
	begin
	  HazardD = 1;
	  stall=5'b11100;
	  flag = 1;
	end
	
	
	RegARdDataD_Reg = (stall[1])?RegARdDataD:32'bz;  //将数据保存到流水段寄存器中
	RegBRdDataD_Reg = (stall[1])?RegBRdDataD:32'bz;
	RtE_Reg = (stall[1])? InstructionD[20:16]:5'bz;  
	RdE_Reg = (stall[1])? InstructionD[15:11]:5'bz;
	SignImmD_Reg = (stall[1])? SignImmD:32'bz;
	PCPlus4D_Reg = (stall[1])? PCPlus4D:32'bz;
	// Control
	RegWriteForCtrD_Reg = (stall[1])? RegWriteForCtrD:1'bz;
	MemtoRegD_Reg = (stall[1])? MemtoRegD:1'bz;
	MemWriteD_Reg = (stall[1])? MemWriteD:1'bz;
	BranchD_Reg = (stall[1])? BranchD:1'bz;
	ALUControlD_Reg = (stall[1])? ALUControlD:5'bz;
	ALUSrcD_Reg = (stall[1])? ALUSrcD:1'bz;
	RegDstD_Reg = (stall[1])? RegDstD:1'bz;

	// For 立即数移位    若为逻辑左移，逻辑右移，算术右移
	Judge_RegD = (InstructionD[31 : 26] == 6'b000000 && (InstructionD[5 : 0] == 6'b000000 || InstructionD[5 : 0] == 6'b000010 || InstructionD[5 : 0] == 6'b000011) )? 1'b1 : 1'b0;
	SrcAInput_RegD = (stall[1])?{27'h0, InstructionD[10:6]}:32'bz;
	//将10:6中的常数s取出，代表移位位数
	
end
// -----------------Execute--------------
assign PCPlus4E =  PCPlus4D_Reg;
// Control
assign RegWriteForCtrE = RegWriteForCtrD_Reg;
assign MemtoRegE =  MemtoRegD_Reg;
assign MemWriteE = MemWriteD_Reg;
assign BranchE =  BranchD_Reg;
assign ALUControlE = ALUControlD_Reg;
assign ALUSrcE = ALUSrcD_Reg;
assign RegDstE =  RegDstD_Reg;


// ALU
wire JudgeE;
assign JudgeE =  Judge_RegD;
wire [4:0] my_stall;
assign my_stall=stall;
//判断是否为移位操作，从而决定第一操作数来自哪里
assign SrcAE = (JudgeE)? SrcAInput_RegD : RegARdDataD_Reg;	

assign SrcBE = (ALUSrcE)? SignImmE:RegBRdDataD_Reg;  //判断第二操作数来自寄存器还是扩展的立即数

assign ALUCtrE = ALUControlE;  //ALU的控制号
assign WriteDataE = RegBRdDataD_Reg;  //传递来自寄存器的第二操作数，可能成为存入主存的数据

// else
assign RtE = RtE_Reg;
assign RdE = RdE_Reg;
assign SignImmE = SignImmD_Reg;

assign WriteRegE =(RegDstE)? RdE : RtE;

always @(posedge Clk) 
begin
	

	// Control
	RegWriteForCtrE_Reg = RegWriteForCtrE;
	MemtoRegE_Reg = MemtoRegE;
	MemWriteE_Reg = MemWriteE;
	BranchE_Reg = BranchE;
	ALUControlE_Reg = ALUControlE;
	ALUSrcE_Reg = ALUSrcE;
	RegDstE_Reg = RegDstE;
	// ALU
	ZeroE_Reg = ZeroE;
	ALUResE_Reg = ALUResE;
	WriteDataE_Reg = WriteDataE;

	// else
	WriteRegE_Reg = WriteRegE;  //选出要写回的寄存器
	PCBranchE_Reg = (SignImmE<<2) + PCPlus4E;  //分支指令地址计算
end

// -----------------Memory--------------
assign PCBranchM = PCBranchE_Reg;
// Control
assign RegWriteForCtrM = RegWriteForCtrE_Reg;
assign MemtoRegM = MemtoRegE_Reg;
assign MemWriteM = MemWriteE_Reg;
assign BranchM = BranchE_Reg;
assign ZeroM = ZeroE_Reg;
// Data_Memory
assign DmemAddrM = ALUResE_Reg;
assign DmemWrDataM = WriteDataE_Reg;
assign DmemWriteM = MemWriteM;
// else
assign WriteRegM = WriteRegE_Reg;

always @(posedge Clk) 
begin
	// Control
	RegWriteForCtrM_Reg = RegWriteForCtrM;
	MemtoRegM_Reg = MemtoRegM;
	MemWriteM_Reg = MemWriteM;
	BranchM_Reg = BranchM;
	// Data_Memory
	DmemAddrM_Reg = DmemAddrM;
	DmemRdDataM_Reg = DmemRdDataM;
	//else 
	WriteRegM_Reg = WriteRegM;
end

// -----------------Writeback--------------
assign RegWriteForCtrW = RegWriteForCtrM_Reg;
assign MemtoRegW = MemtoRegM_Reg;
assign ALUOutW = DmemAddrM_Reg; // AW
assign ReadDataW = DmemRdDataM_Reg; // RD
assign WriteRegW = WriteRegM_Reg;
endmodule