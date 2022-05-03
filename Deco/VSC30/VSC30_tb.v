`timescale 1ns/1ns
`include "VSC30.v"

module tb(
);

reg clk;
reg reset;

VSC30 DUT(
	.PIN1(reset),
	.PIN19(clk)
);

initial begin
	$dumpfile("VSC30.vcd");
	$dumpvars(-1, DUT);
end

always @(*)
	#1 clk <= ~clk;

initial begin
	clk <= 1'b0;
	reset <= 1'b0;
	#10
	reset <= 1'b1;

	#5000
	$finish();
end

endmodule
