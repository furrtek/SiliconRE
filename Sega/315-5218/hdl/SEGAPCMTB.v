`timescale 1ns/1ns

`include "SEGAPCM.v"
`include "ram.v"
`include "rom.v"

module SEGAPCMTB(
);
	reg nRESET, CLK;
	reg nSRD, nSWR, nSCS;
    wire [11:0] RSD;
    reg [15:0] A;
    wire [7:0] D;
    reg [7:0] D_REG;
    wire [9:0] AB;
    wire [15:0] DB;
    wire [1:0] nWE;
    wire [7:0] GD;
    wire [15:0] GA;
    wire nSOE;
    
    ram RAML(AB, DB[7:0], ~nWE[0], nWE[0]);
    ram RAMU(AB, DB[15:8], ~nWE[1], nWE[1]);

    rom ROM(GA, GD, 1'b0);

    initial begin
    	$dumpfile("SEGAPCM.vcd");
    	$dumpvars(-1, SEGAPCMTB);
    end

	initial begin
	    CLK <= 0;
		nRESET <= 1;
		nSRD <= 1;
		nSWR <= 1;
		nSCS <= 1;
		A <= 16'h0000;
		#30
		nRESET <= 0;
	    #100
	    nRESET <= 1;
		#1023
		
		// Z80 runs at 4MHz
		D_REG <= 8'h55;
		nSCS <= 0;
		#8nSWR <= 0;
		@(posedge nWAIT);
		nSCS <= 1;
  		nSWR <= 1;

		#10000	// Run for 50ms
		$finish;
	end

	assign D = (nSCS | nSWR) ? 8'bzzzzzzzz : D_REG;
	
	always @(*) begin
	    #1 CLK <= ~CLK;    // "16MHz"
	end

	//assign DB[7:0] = nWE[0] ? 8'h00 : 8'bzzzzzzzz;
	//assign DB[15:8] = nWE[1] ? 8'h00 : 8'bzzzzzzzz;

    SEGAPCM DUT(
    	CLK,
    	nRESET,
    	nSRD, nSWR, nSCS,
    	nWAIT,
    	LGT, RGT,
    	RSD,
    	A[10:0],
    	D,
    	AB,
        DB,
    	GA,
    	GD,
    	nSOE,
    	nWE,
    	nGL
	);

	//palram PALRAM({PALBNK, PA}, PC, nPALWE);

endmodule
