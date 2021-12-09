//John Fluke
//Integer ALU
module IntegerAlu(
    input Clk,
    output reg [255:0] IntDataOut,
    input [255:0] ExeDataOut,
    input [15:0] address,
    input nRead,
    input nWrite,
    input nReset
    );
    
//Split and assign address bus values
wire [3:0] Enable, Select;
wire [7:0] OpCode;
assign Enable = address[15:12]; //first 4 bits of address is enable signal
assign Select = address[11:8];  //middle 4 bits can be used as selection signal for select 
assign OpCode = address[7:0];	//last 4 bits for opcode

//internal registers for storing integers
reg [15:0] intA, intB;

//internal register to store result
reg [15:0] intR;  

//Enable ALU and write data to integer registers A and B
always @ *
begin
if (Enable == 4'd5) begin
    if (~nWrite) begin
		if (Select == 4'd0) begin
            intA = ExeDataOut[15:0];
            end
		else if  (Select == 4'd1) begin
            intB = ExeDataOut[15:0];
            end     
    end
end
end   

//Set parameters for ALU operations
localparam [7:0] IntAdd  = 8'h10,
                 IntSub  = 8'h11,
                 IntMult = 8'h12,
                 IntDiv  = 8'h13;

//ALU calculations
always @*
begin
intR = 16'd0;
case(OpCode)
IntAdd:  intR = intA + intB ; //addition
IntSub:  intR = intA - intB ; //subtraction
IntMult: intR = intA * intB ; //multiplication
IntDiv:  intR = intA / intB ; //division
endcase
end  

//Send final result to output register
always @ (posedge Clk)
begin
if (Enable == 4'd5) begin
if (~nReset) begin
    IntDataOut = 256'd0;
end
else if (~nRead) begin
   IntDataOut = intR;  
end
end  
end             
                 
endmodule