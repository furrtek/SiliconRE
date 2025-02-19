// M5M4416 DRAM simplified model

`timescale 1ns/1ns

module DRAM(
	input nCAS, nRAS, nWE,
	input [7:0] A,
	output [3:0] D_out,
	input [3:0] D_in
);

reg [3:0] memory [0:16383];
reg [13:0] address;

initial begin
	address <= 14'd0;
end

always @(negedge nRAS)
	address[7:0] <= A;

always @(negedge nCAS) begin
	address[13:8] <= A[6:1];
	if (!nWE)
		memory[{A[6:1], address[7:0]}] <= D_in;	// Early write (nWE low when nCAS falls)
end

always @(negedge nWE) begin
	if (!nCAS)
		memory[address] <= D_in;	// Delayed write (nWE falls when nCAS low)
end

assign D_out = memory[address];

endmodule

