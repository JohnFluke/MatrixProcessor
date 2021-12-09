//John Fluke
//Matrix ALU
//Based loosely on code from https://verilogcodes.blogspot.com/2020/12/synthesizable-matrix-multiplication-in.html
//						and https://github.com/pontazaricardo/Verilog_Calculator_Matrix_Multiplication/blob/master/main/Calculator.v
module MatrixAlu(
    input Clk,
    output reg [255:0] MatrixDataOut,
    input [255:0] ExeDataOut,
    input [15:0] address,
    input nRead,
    input nWrite,
    input nReset
    );
    
//Split and assign address bus values
wire [3:0] Enable, Select;
wire [7:0] OpCode;
assign Enable = address[15:12]; //first 4 bits enables ALU
assign Select = address[11:8];  //middle 4 bits select matrix
assign OpCode = address[7:0];	//last 4 bits for opcode

//internal registers for storing sources in matrix form
reg [15:0] A [0:3] [0:3];
reg [15:0] B [0:3] [0:3];

//internal register to store result
reg [15:0] R [0:3] [0:3]; 

//Enable ALU and write data to matrix registers A and B
always @*
begin
if (Enable == 4'd3) begin
    if (~nWrite) begin
       if (Select == 4'd0) begin
             {A[0][0],A[0][1],A[0][2],A[0][3],A[1][0],A[1][1],A[1][2],A[1][3],A[2][0],A[2][1],A[2][2],A[2][3],A[3][0],A[3][1],A[3][2],A[3][3]} = ExeDataOut;
             end
       else if  (Select == 4'd1) begin
             {B[0][0],B[0][1],B[0][2],B[0][3],B[1][0],B[1][1],B[1][2],B[1][3],B[2][0],B[2][1],B[2][2],B[2][3],B[3][0],B[3][1],B[3][2],B[3][3]} = ExeDataOut;
             end     
    end
end
end   

//Set parameters for ALU operations
localparam [7:0] MMult       = 8'h00,
                 Madd        = 8'h01,
                 Msub        = 8'h02,
                 Mtranspose  = 8'h03,
                 MScale      = 8'h04,
                 MScaleImm   = 8'h05;

//ALU calculations
integer i,j,k;
always @*
begin
//Assign default values
i = 0;
j = 0;
k = 0;
{R[0][0],R[0][1],R[0][2],R[0][3],R[1][0],R[1][1],R[1][2],R[1][3],R[2][0],R[2][1],R[2][2],R[2][3],R[3][0],R[3][1],R[3][2],R[3][3]} = 256'd0;
case(OpCode)
MMult:  	begin    //Matrix multiplication
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						for(k=0;k < 4;k=k+1)
							R[i][j] = R[i][j] + (A[i][k] * B[k][j]);
			end            
Madd:  		begin    //Matrix addition
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						R[i][j] = A[i][j] + B[i][j];
			end  
Msub:  		begin    //Matrix subtraction
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						R[i][j] = A[i][j] - B[i][j];
			end 
Mtranspose: begin    //Matrix transpose
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						R[i][j] = A[j][i];
			end  
//For scaling, the integer is stored as the last 16 bits of ExeDataOut in B[3][3]
MScale:  	begin    //Matrix scaling
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						R[i][j] = A[i][j] * B[3][3];
			end  
MScaleImm:  begin    //Matrix subtraction
				for(i=0;i < 4;i=i+1)
					for(j=0;j < 4;j=j+1)
						R[i][j] = A[i][j] * B[3][3];
			end        
endcase
end  

//Send final result to output register
always @ (posedge Clk)
begin
if (Enable == 4'd3) 
begin
	if (~nReset)
		MatrixDataOut = 256'd0;
	else if (~nRead)
		MatrixDataOut = {R[0][0],R[0][1],R[0][2],R[0][3],R[1][0],R[1][1],R[1][2],R[1][3],R[2][0],R[2][1],R[2][2],R[2][3],R[3][0],R[3][1],R[3][2],R[3][3]};  
end  
end             
endmodule