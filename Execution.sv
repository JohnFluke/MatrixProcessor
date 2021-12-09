//John Fluke
//Execution module
//`timescale 1ns / 1ps

module Execution(
    input Clk,
    input [255:0] InstructDataOut,
	input [255:0] MemDataOut,
	input [255:0] MatrixDataOut,
	input [255:0] IntDataOut,
    output reg [255:0] ExeDataOut,
    output [15:0] address,
    output reg nRead,
    output reg nWrite,
    input nReset
    );
 
//Define states for execution engine state machine
typedef enum {Idle,
				InstructFetch, 
				StopCheck,
				Source1_Read1,
				Source1_Read2, 
				Source1_Write,
				Source2_Read1,
				Source2_Read2,
				Source2_Write,
				ALU_Result,
				ALU_Read1,
				ALU_Read2,
				ALU_Write} 
				state_type;
 
				  
state_type state_current = Idle; //ensure engine starts in Idle state
state_type state_next;
 
//Split address into 3 signals for easier use
reg [3:0] Enable;  		//first 4 bits for enabling modules
reg [3:0] Select;		//Selects matrix in ALU
reg [7:0] Location; 	//last 8 bits for address of the instruction, memory, or register
 
//Address encoding for external use
assign address = {Enable,Select,Location};
 
//internal register for program counter
reg [3:0] pCount = 0;
 
//Temporary registers for execution engine
reg [255:0] Inst_Reg;	//stores current opcode
reg [255:0] S1_Reg;	//stores data from source 1
reg [255:0] S2_Reg;	//stores data from source 2
reg [255:0] ALU_Reg;	//stores result from ALU

//Temporary registers for storing results based on instructions
reg [255:0] temp_reg [16:17];	//10h = 16d and 11h = 17d

//Split instructions into their 4 components for easier use
wire [7:0] OpCode, Destination, Source1, Source2;  
assign {OpCode, Destination, Source1, Source2} = Inst_Reg[31:0]; 

//Set initial state and then drive state machine
always @ (posedge Clk or posedge nReset)
begin
if (~nReset) begin
		state_current <= InstructFetch;   //execution starts from instruction fetch when reset
			pCount = 4'd0;
            end
else state_current <= state_next;
end 

//Walkthrough of state machine
//
//The state machine has 13 states and takes at most 12 clock cycles to complete an instruction
//If both data sources are internal registers an instruction can be completed in 9 clock cycles if not starting from idle
//
//The state machine begins in the Idle state and waits for the reset to begin its process
//Next it will fetch instructions from the instruction memory and store it in a register
//Depending on the instructions the machine will fetch data from memory if the source is not a register
//The data is then written to either ALU depending on the opcode
//This process is repeated for the second source
//Results are read from either ALU again depending on the opcode
//Finally, results are written to either memory or a register and the program counter is increased
//This repeats until the stop code is loaded from instruction memory the machine will re-enter the Idle state and wait for reset


//state machine logic
always @*
begin
//Read and Write defaults
nRead = 1'b1;
nWrite = 1'b1;	
case(state_current)
Idle: 			begin
				if(~nReset)
					state_next = InstructFetch;
				end
InstructFetch:	begin
				Enable = 4'd2;					//Instruction memory selected
				Select = 4'd0;					//Set select to 0 for matrix/integer A
				Location = pCount;				//Set location for address
				nRead = 1'b0;
				Inst_Reg = InstructDataOut;		//Load Instructions into register
				state_next = StopCheck;
				end
StopCheck:		begin							//Check if stop code was loaded into register
				if(Inst_Reg == 32'hFF_00_00_00)
					state_next = Idle;
				else
					state_next = Source1_Read1;
				end
Source1_Read1:	begin
				if(Source1[7:4] == 4'd0)		//check if reading from a register
				begin
					Enable = 4'd0;				//Main memory selected
					state_next = Source1_Read2;
				end
				else
				begin
					S1_Reg = temp_reg[Source1];	//Load temp register into Source register
					state_next = Source1_Write;
				end
				Location = Source1;				//Set location for address
				end
Source1_Read2:	begin
				Enable = 4'd0;					//Main memory enabled
				nRead = 1'b0;
				S1_Reg = MemDataOut;			//Load data from memory
				state_next = Source1_Write;
				end
Source1_Write:	begin
				if(OpCode[7:4] == 4'd0)			//Check which ALU is needed
					Enable = 4'd3;				//Matrix ALU enabled
				else
					Enable = 4'd5;				//Integer ALU enabled
				ExeDataOut = S1_Reg;			//Send data to ALU
				nWrite = 1'b0;
				Select = 4'b0;					//Set select for ALU
				Location = OpCode;				//Set location for ALU
				state_next = Source2_Read1;
				end
Source2_Read1:	begin
				if(Source2[7:4] == 4'd0)		//check if reading from register
				begin
					Enable = 4'd0;				//Main memory selected
					state_next = Source2_Read2;
				end
				else
				begin
					S2_Reg = temp_reg[Source2];	//Load temp register into source register
					state_next = Source2_Write;
				end
				Location = Source2;				//Set location for address
				end
Source2_Read2:	begin
				Enable = 4'd0;					//Main memory enabled
				nRead = 1'b0;
				S2_Reg = MemDataOut;			//Load data from memory
				state_next = Source2_Write;
				end
Source2_Write:	begin
				if(OpCode[7:4] == 4'd0)			//Check which ALU is needed
					Enable = 4'd3;				//Matrix ALU enabled
				else
					Enable = 4'd5;				//Integer ALU enabled
				ExeDataOut = S2_Reg;			//Send data to ALU
				nWrite = 1'b0;
				Select = 4'b1;					//Set select for ALU
				Location = OpCode;				//Set location for ALU
				state_next = ALU_Result;
				end
ALU_Result:		begin
				if(OpCode[7:4] == 4'd0)			//Check which ALU is needed
				begin
					Enable = 4'd3;				//Matrix ALU enabled
					state_next = ALU_Read1;
				end
				else
				begin
					Enable = 4'd5;				//Integer ALU enabled
					state_next = ALU_Read2;
				end
				end
ALU_Read1:		begin
				nRead = 1'b0;
				Enable = 4'd3;					//Matrix ALU enabled
				ALU_Reg = MatrixDataOut;		//Load ALU output into register
				state_next = ALU_Write;
				end
ALU_Read2:		begin
				nRead = 1'b0;
				Enable = 4'd5;					//Integer ALU enabled
				ALU_Reg = IntDataOut;			//Load ALU output into register
				state_next = ALU_Write;
				end
ALU_Write:		begin
				if(Destination[7:4] == 4'd0)	//check if reading from register
				begin
					Enable = 4'd0;				//Main memory selected
					ExeDataOut = ALU_Reg;		//Send data to output
				end
				else
					temp_reg[Destination] = ALU_Reg;	//Write data to register
				nWrite = 1'b0;
				Location = Destination;			//Set location for data to be written
				pCount = pCount + 4'd1;
				state_next = InstructFetch;
				end
endcase
end		
endmodule