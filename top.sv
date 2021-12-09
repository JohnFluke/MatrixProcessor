// John Fluke
// HDL 4321 Fall 2021
// Final Project
//
// Top Module provided by Mr. Welker
// Instruction Memory and Main Memory Modules based on those provided by Mr. Welker

module top ();

logic [255:0] InstructDataOut;
logic [255:0] MemDataOut;
logic [255:0] ExeDataOut;
logic [255:0] IntDataOut;
logic [255:0] MatrixDataOut;
logic nRead,nWrite,nReset,Clk;
logic [15:0] address;


InstructionMemory  U1(Clk,InstructDataOut, address, nRead,nReset);

MainMemory  U2(Clk,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);

Execution  U3(Clk,InstructDataOut,MemDataOut,MatrixDataOut,IntDataOut,ExeDataOut, address, nRead,nWrite, nReset);

MatrixAlu  U4(Clk,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);

IntegerAlu  U5(Clk,IntDataOut,ExeDataOut, address, nRead,nWrite, nReset);

TestMatrix  UTest(Clk,nReset);

initial begin //. setup to allow waveforms for edaplayground
   $dumpfile("dump.vcd");
   $dumpvars(1);
end

always @(InstructDataOut) begin // this block checks to make certain the proper data is in the memory.
		if (InstructDataOut == 256'h00000000000000000000000000000000000000000000000000000000ff000000)
// we are about to execute the stop
		if (U2.MainMemory[6] == 256'h0000000000000000000000000000000000000000000000000047fff6fff6fff7)
			$display ( "output is correct ");
		else
			$display (" Output is WRONG");

end
endmodule