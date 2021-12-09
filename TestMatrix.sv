//John Fluke
//Test Bench

module TestMatrix(
	output reg Clk,
    output reg nReset);

//Clock signal
initial begin
Clk = 1'b0;
forever #10 Clk = ~Clk;
end

//Reset
initial begin
nReset = 1'b1;
#10 nReset = 1'b0;
#20 nReset = 1'b1;
#2500 $finish;
end

endmodule