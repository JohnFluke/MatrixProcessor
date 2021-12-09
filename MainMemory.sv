// John Fluke
// Main memory module provided by Mr. Welker

/// cannot be an enum because we need a specific address to be decoded.
// This is the memory locations for the system.
/////////////////////////////////////////////
parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter AluEn = 3;
parameter ExecuteEn = 4;
parameter IntAlu = 5;

module MainMemory(Clk,MemDataOut,ExeDataOut, address, nRead,nWrite, nReset);


input logic [255:0] ExeDataOut; // from the CPU
input logic nRead,nWrite, nReset, Clk;
input logic [15:0] address;

output logic [255:0] MemDataOut; // to the CPU 

logic [255:0]MainMemory[14]; // this is the physical memory



always_ff @(negedge Clk or negedge nReset)
begin
	if (~nReset) begin
	MainMemory[0] = 256'h0003_0002_0008_0006_000c_0006_0003_0009_0009_000c_0002_000d_000c_000e_0010_0003;
	MainMemory[1] = 256'h0006_0004_0007_000f_0007_000a_0004_0007_0004_0003_0005_0008_000c_0005_0002_0006;
	MainMemory[2] = 256'h0;
	MainMemory[3] = 256'h0;
	MainMemory[4] = 256'h0;
	MainMemory[5] = 256'h0;
	MainMemory[6] = 256'h0;
	MainMemory[7] = 256'h0;
	MainMemory[8] = 256'h04;
	MainMemory[9] = 256'h11;
	MainMemory[10] = 256'h0;
	MainMemory[11] = 256'h0;
	MainMemory[12] = 256'h0;
	MainMemory[13] = 256'h0;
      MemDataOut=0;
	end

	else if(address[15:12] == MainMemEn) // talking to Main memory
		begin
			if (~nRead)begin
				MemDataOut <= MainMemory[address[7:0]]; // data will remain on dataout until it is changed.
			end
			if(~nWrite)begin
		    MainMemory[address[7:0]] <= ExeDataOut;
			end
		end
end 	

endmodule