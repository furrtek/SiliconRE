// Konami 053260 testbench

`timescale 1ns/1ns
`include "k053260.v"

module tb(
	);

reg CLK, nRES, STBI, AUX1, AUX2;
wire TIM2, NE, NQ;

assign ST1 = 1'b0;
assign ST2 = 1'b0;

k053260 UUT(
	CLK,				// YM2151 clock
	nRES,				// Reset
	ST1, ST2,			// Config ?
	TIM2,
	NE, NQ,				// 6809 E/Q
	STBI, AUX1, AUX2,	// YM2151 SH1 for sync, two possible input streams
	SY, SH1, SH2, SO	// For YM3012, SY must be CLK/2
);

/*task setreg;
	input [3:0] addr;
	input [7:0] data;
	begin
		A <= {7'd0, addr};
		DOUT <= data;
		#100
		IOCS <= 1'b0;
		RW <= 1'b0;
		#100
		IOCS <= 1'b1;
		RW <= 1'b1;
		#100
		RW <= 1'b1;
	end
endtask*/

//integer i, fd;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    //fd = $fopen("log_video.txt", "w");

    STBI <= 1'b0;
    AUX1 <= 1'b0;
    AUX2 <= 1'b0;
    CLK <= 1'b0;
    nRES <= 1'b0;
    SH_counter <= 6'd0;

    #10
	nRES <= 1'b1;

    #50000

	$finish;
end

always @(*)
    #1 CLK <= ~CLK;

reg [5:0] SH_counter;

always @(negedge CLK) begin
	SH_counter <= SH_counter + 1'd1;
	if (SH_counter == 5'd15) STBI <= 1'b1;
	if (SH_counter == 5'd31) STBI <= 1'b0;
end

endmodule
