// Roland R15229844 rate mapping logic testbench

`timescale 1ns/1ns
`include "rate_map.v"

module tb();

reg [7:0] REG_RATE;
wire [14:0] RATE_TR;

RATEMAP UUT(
	REG_RATE,
	RATE_TR
);

initial begin
	$dumpfile("rate_map.vcd");
	$dumpvars(-1, tb);
end

integer i;

initial begin
	REG_RATE <= 8'd0;
	
	for (i = 0; i < 256; i = i + 1) begin
		#2 REG_RATE <= i;
	end

	#10 $finish;
end

endmodule
