module auxin(
	input PIN_AXXA,
	input AXDA_SYNC,
	input PIN_YMD,
	output [15:0] AXDMUX
);

/*
YM3012:
CLK  _#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#
SAM1 ####________________________________________________################____
SAM2 ____________________################____________________________________
SD       xxXXxxD0D1D2D3D4D5D6D7D8D9S0S1S2xxXXxxD0D1D2D3D4D5D6D7D8D9S0S1S2
CH       1111111111111111111111111111111122222222222222222222222222222222
LAT  _____#_______________________________#__________________________________

I2S:
BCK     _#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#
LRCK/WS ####________________________________################################____
SD      ______FFEEDDCCBBAA99887766554433221100FFEEDDCCBBAA99887766554433221100__
CH      ______LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR__

YM	      D0D1D2D3D4D5D6D7D8D9S0S1S2
LIN	FFEEDDCCBBAA99887766554433221100

AXXA: Clock
AXDA: Data
AXWA: ?
ALRA: ?

YMD=0: I2S stream
		E110 = delayed AXWA & ~ALRA
		J108 = AXWA & ~ALRA
		D122 = AXWA & ALRA
YMD=1: YM3012 stream
		E110 = delayed AXWA
		J108 = ALRA
		D122 = AXWA
*/

// SIPO
reg [15:0] AXD;
always @(posedge PIN_AXXA) begin
	AXD <= {AXD[14:0], AXDA_SYNC};
end

assign B109 = |{AXD[2:1]};

// 13bit YM exp data to linear 16bit
wire [15:0] YM_DEC;
assign YM_DEC[0] = AXD[12];	// Use YM D0 directly
assign YM_DEC[1] = (AXD[1:0] != 2'd0) ? AXD[12] : AXD[2] ? AXD[11] : 1'b0;
assign YM_DEC[2] = AXD[0] ? AXD[12] :
					AXD[1] ?
						AXD[2] ? AXD[12] : AXD[11] : 	// 3 2
						AXD[2] ? AXD[10] : 1'b0;		// 1 0
assign YM_DEC[3] = AXD[0] ? AXD[12] :
					AXD[1] ?
						AXD[2] ? AXD[11] : AXD[10] : 	// 3 2
						AXD[2] ? AXD[9] : 1'b0;			// 1 0
assign YM_DEC[4] = AXD[0] ? B109 ? AXD[12] : AXD[11] :
					AXD[1] ?
						AXD[2] ? AXD[10] : AXD[9] : 	// 3 2
						AXD[2] ? AXD[8] : 1'b0;			// 1 0

assign YM_DEC[5] = AXD[0] ? |{AXD[12] & AXD[1], &{AXD[11], AXD[2], ~AXD[1]}, &{AXD[10], ~AXD[2], ~AXD[1]}} :
					AXD[1] ?
						AXD[2] ? AXD[9] : AXD[8] : 		// 3 2
						AXD[2] ? AXD[7] : 1'b0;			// 1 0

assign YM_DEC[6] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[12] : AXD[11] : 	// 3 2
						AXD[2] ? AXD[10] : AXD[9] :		// 1 0
					AXD[1] ?
						AXD[2] ? AXD[8] : AXD[7] : 		// 3 2
						AXD[2] ? AXD[6] : 1'b0;			// 1 0

assign YM_DEC[7] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[11] : AXD[10] : 	// 3 2
						AXD[2] ? AXD[9] : AXD[8] :		// 1 0
					AXD[1] ?
						AXD[2] ? AXD[7] : AXD[6] : 		// 3 2
						AXD[2] ? AXD[5] : 1'b0;			// 1 0

assign YM_DEC[8] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[10] : AXD[9] : 	// 3 2
						AXD[2] ? AXD[8] : AXD[7] :		// 1 0
					AXD[1] ?
						AXD[2] ? AXD[6] : AXD[5] : 		// 3 2
						AXD[2] ? AXD[4] : 1'b0;			// 1 0

assign YM_DEC[9] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[9] : AXD[8] : 		// 3 2
						AXD[2] ? AXD[7] : AXD[6] :		// 1 0
					AXD[1] ?
						AXD[2] ? AXD[5] : AXD[4] : 		// 3 2
						AXD[2] ? ~AXD[3] : 1'b0;		// 1 0

assign YM_DEC[10] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[8] : AXD[7] : 		// 3 2
						AXD[2] ? AXD[6] : AXD[5] :		// 1 0
						|{AXD[1] & AXD[2] & AXD[4], &{AXD[1] ^ AXD[2], ~AXD[3]}};		// |{AXD[1] & AXD[2] & AXD[4], &{~AXD[2], ~AXD[1]}, &{AXD[1] ^ AXD[2], ~AXD[3]}};

assign YM_DEC[11] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[7] : AXD[6] : 		// 3 2
						AXD[2] ? AXD[5] : AXD[4] :		// 1 0
					B109 ? ~AXD[3] : 1'b0;

assign YM_DEC[12] = AXD[0] ?
					AXD[1] ?
						AXD[2] ? AXD[6] : AXD[5] : 		// 3 2
						AXD[2] ? AXD[4] : ~AXD[3] :		// 1 0
					B109 ? ~AXD[3] : 1'b0;

assign YM_DEC[13] = AXD[0] ? |{AXD[2] & AXD[1] & AXD[5], ~AXD[1] & ~AXD[3], &{~AXD[2], AXD[1], AXD[4]}} :
					B109 ? ~AXD[3] : 1'b0;

assign YM_DEC[14] = AXD[0] ?
					&{AXD[2:1]} ? AXD[4] : ~AXD[3] :
					B109 ? ~AXD[3] : 1'b0;

assign YM_DEC[15] = ~AXD[3];	// Checked, means AXDMUX is signed

assign AXDMUX = PIN_YMD ? YM_DEC : AXD;

endmodule
