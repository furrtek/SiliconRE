// Do-nothing PLL for testbench

module pll (
	input inclk0,
	output c0,
	output locked);

assign c0 = 1'b0;
assign locked = 1'b1;

endmodule
