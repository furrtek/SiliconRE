// Roland R15229844 testbench
// furrtek 2024

`timescale 1ns/1ns
`include "R15229844.v"
//`include "sine.v"
`include "DRAM.v"

module tb();

wire [7:0] DRAM_A;
wire [3:0] DRAM_D_in;
wire [3:0] DRAM_D_out;
wire [7:0] VD_out;
reg [15:0] IO_in;
wire [15:0] IO_out;

R15229844 UUT(
	CLK_IN,
	nRESET,

	IO_in,
	IO_out,

	DRAM_A,
	DRAM_D_in,
	DRAM_D_out,
	nDRAM_RAS, nDRAM_CAS, nDRAM_WE,

	VD_in,
	VD_out,
	DPTH, RATE, DELY,

	K64, LONG, nINIT, DIO, SYNC,
	CPU, COMP,
	GETA, SH0, TST0, MUTE, SH1
);

DRAM UUT_DRAM(
	nDRAM_CAS, nDRAM_RAS, nDRAM_WE,
	DRAM_A,
	DRAM_D_out,
	DRAM_D_in
);

// Simulate external audio SH
/*sine UUT_SINE(
	sine_index,
	input_audio
);*/

initial begin
	$dumpfile("R15229844.vcd");
	$dumpvars(-1, tb);
end

reg CLK_IN, nRESET;
reg K64, LONG, nINIT, DIO, SYNC;
reg CPU;
reg [7:0] VD_in;
reg run = 1'b0;

integer s;

//assign match_region = (UUT.raster_line >= 9'd47) && (UUT.raster_line <= 9'd47 + 6'd19);

always @(*) begin
	if (run)
		#1 CLK_IN <= ~CLK_IN;
end

initial begin
	CLK_IN <= 1'b0;
	nRESET <= 1'b0;
	//sine_index <= 8'd0;
	input_audio <= 16'd0;

    VD_in <= 8'h0;
	CPU <= 1'b0;		// Autonomous mode, as in RCE-10
	DIO <= 1'b0;
	SYNC <= 1'b1;
	nINIT <= 1'b1;
	LONG <= 1'b0;
	K64 <= 1'b1;

	#10 run <= 1'b1;

	#10 nRESET <= 1'b1;

	#300000

	$finish;
end

// Simulate external resistor DAC, pots and comparators with fixed values
assign RATE = VD_out >= 8'h0A;	//8'h1C;
assign DELY = VD_out >= 8'h35;
assign DPTH = VD_out >= 8'h44;

reg [15:0] input_audio;
/*
// Simulate audio ramp waveform at CLK_IN * 6 / 65536
// At 4MHz CLK_IN: ~366Hz
always @(posedge CLK_IN) begin
	input_audio <= input_audio + 16'd6;
end*/

// Simulate external audio SH
reg [15:0] input_SH;
always @(*)
	if (SH1) input_SH <= input_audio;

// Simulate external audio resistor DAC and comparator
assign COMP = ~(IO_out > input_SH);

endmodule
