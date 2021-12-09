// John Fluke
// Instruction memory modified based on module provided by Mr. Welker 
// holds the instructions that the processor will execute.
//
// the address lines are generic and each module must handle thier own decode. 
// The address bus is large enough that each module can contain a local address decode. This will save on multiple enmables. 
// bit 11-0 are for adressing inside each unit.
// nWrite = 0 means databus is being written into the part on the falling edge of write
// nRead = 0 means it is expected to drive the databus while this signal is low and the address is correct until the nRead goes high independent of addressd bus.


// Each and EVERY memory address location is 256 bits.

/// cannot be an enum because we need a specific address to be decoded.
// This is the memory locations for the system.
/////////////////////////////////////////////
parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter AluEn = 3;
parameter ExecuteEn = 4;
parameter IntAlu = 5;


//////////////////////////////
//Moved stop to third instruction for this example
/////////////////////////////////////////////////
// instruction: OPcode :: dest :: src1 :: src2 Each section is 8 bits.
//Stop::FFh::00::00::00
//MMult::00h::Reg/mem::Reg/mem::Reg/mem
//Madd::01h::Reg/mem::Reg/mem::Reg/mem
//Msub::02h::Reg/mem::Reg/mem::Reg/mem
//Mtranspose::03h::Reg/mem::Reg/mem::Reg/mem
//MScale::04h::Reg/mem::Reg/mem::Reg/mem
//MScaleImm::05h:Reg/mem::Reg/mem::Immediate
//IntAdd::10h::Reg/mem::Reg/mem::Reg/mem
//IntSub::11h::Reg/mem::Reg/mem::Reg/mem
//IntMult::12h::Reg/mem::Reg/mem::Reg/mem
//IntDiv::13h::Reg/mem::Reg/mem::Reg/mem

// add the data at location 0 to the data at location 1 and place result in location 2
parameter Instruct1 = 32'h01_02_00_01; // add first matrix to second matrix store in memory
parameter Instruct2 = 32'h10_10_09_08; // add 16 bit numbers in location 8 to 9 store in temp register
parameter Instruct3 = 32'h02_03_02_00; //Subtract the first matrix from the result in step 1 and store the result somewhere else in memory. 
parameter Instruct4 = 32'h03_04_02_00;//Transpose the result from step 1 store in memory
parameter Instruct5 = 32'h04_05_03_10;//Scale the result in step 3 by the result from step 2 store in a matrix register
parameter Instruct6 = 32'h00_06_04_03; //Multiply the result from step 4 by the result in step 3, store in memory.

parameter Instruct7 = 32'h12_0a_01_00;//Multiply the integer value in memory location 0 to location 1. Store it in memory location 0x0A
parameter Instruct8 = 32'h11_11_0a_01;//Subtract the integer value in memory location 01 from memory location 0x0A and store it in a register
parameter Instruct9 = 32'h13_0b_0a_11;//Divide Memory location 0x0A by the register in step 8 and store it in location 0x0B
parameter Instruct10 = 32'hFF_00_00_00;// stop


module InstructionMemory(Clk,InstructDataOut, address, nRead,nReset);
// NOTE the lack of datain and write. This is because this is a ROM model

input logic nRead, nReset, Clk;
input logic [15:0] address;

output reg [255:0] InstructDataOut; // 1 - 32 it instructions at a time.

logic [255:0]InstructMemory[0:9]; // this is the physical memory

//Split address into Enable and a program counter for the instruction memory
wire [3:0] Enable;     			//enable for instruction memory
reg [3:0] pCount;    			//last 4 bits used for program counter
assign Enable = address[15:12]; //first 4 bits enables instruction memory

//ensure program counter is 0 after reset
always @*
begin
if (~nReset)
	pCount = 4'd0;
else 
	pCount = address[3:0];  
end 

always @(negedge nReset)
begin
//	set in the default instructions 
	InstructMemory[0] = Instruct1;  	
	InstructMemory[1] = Instruct2;  	
  	InstructMemory[2] = Instruct3;
	InstructMemory[3] = Instruct4;	
	InstructMemory[4] = Instruct5;
	InstructMemory[5] = Instruct6;
	InstructMemory[6] = Instruct7;
	InstructMemory[7] = Instruct8;
	InstructMemory[8] = Instruct9;
	InstructMemory[9] = Instruct10;
end 

//send instruction to output if enabled
always @ (posedge Clk)
begin
if (Enable == 4'd2) 
begin
if (~nRead) 
    InstructDataOut = InstructMemory[pCount];
end
end

endmodule