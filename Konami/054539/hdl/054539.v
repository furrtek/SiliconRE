// Konami 054539
// furrtek 2025

`include "DEC2.v"
`include "DEC3.v"
`include "REG8.v"
`include "RAM.v"
`include "ROM.v"
`include "startstop.v"
`include "auxin.v"
`include "lfo.v"

module k054539(
	input NRES,
	input CLK,

	input [7:0] PIN_AB,
	input PIN_AB09,
	input [7:0] PIN_DB_IN,
	output [7:0] PIN_DB_OUT,
	input PIN_NCS,
	input PIN_NRD,
	input PIN_NWR,
	output PIN_WAIT,

	output reg PIN_DTCK,
	output reg PIN_WDCK,

	input PIN_DTS1,
	input PIN_DTS2,

	output reg [23:0] PIN_RA,
	input [7:0] PIN_RD_IN,
	output reg [7:0] PIN_RD_OUT,
	output PIN_TIM,

	input PIN_RRMD,
	input PIN_DLY,
	input PIN_AXDA,
	input PIN_ALRA,
	input PIN_USE2,
	input PIN_YMD,

	input PIN_AXXA,
	input PIN_AXWA,
	input PIN_ADDA,

	output PIN_FRDL,
	output PIN_FRDT,
	output PIN_REDL,
	output PIN_REDT,

	output PIN_AXDT,

	output PIN_RACS,
	output PIN_RAWP,
	output PIN_RAOE,

	output PIN_ROCS,
	output PIN_ROBS,
	output PIN_ROOE
);

// CLOCKS AND RESET

reg R131 = 0;
always @(posedge CLK) begin
	R131 <= NRES;
end
assign nRES = NRES & R131;

// Divide-by-3
reg R53 = 0, R46 = 0;
always @(posedge CLK) begin
	R46 <= ~&{nRES, R46, ~S36};
	R53 <= &{nRES, R46 ^ R53};
end
assign S36 = &{R53, R46};

// This could be replaced by simple up-counters ?
reg [6:0] CLKDIVTHREE = 0;	// 384, 192, 96, 48, 24, 12, 6
reg [8:0] CLKDIV = 0;
reg [8:0] CLKDIVD = 0;		// 512, 256, 128, 64, 32, 16, 8, 4, 2
always @(posedge CLK) begin
	CLKDIVTHREE[0] <= &{nCYCLERES, CLKDIVTHREE[0] ^ S36};							// R49
	CLKDIVTHREE[1] <= &{nCYCLERES, ~(CLKDIVTHREE[1] ^ ~&{CLKDIVTHREE[0], S36})};	// R32
	CLKDIVTHREE[2] <= &{nCYCLERES, ~(CLKDIVTHREE[2] ^ ~&{CLKDIVTHREE[1:0], S36})};	// R44
	CLKDIVTHREE[3] <= &{nCYCLERES, ~(CLKDIVTHREE[3] ^ ~&{CLKDIVTHREE[2:0], S36})};	// M10
	CLKDIVTHREE[4] <= &{nCYCLERES, ~(CLKDIVTHREE[4] ^ ~&{CLKDIVTHREE[3:0], S36})};	// P34
	CLKDIVTHREE[5] <= &{nCYCLERES, ~(CLKDIVTHREE[5] ^ ~&{CLKDIVTHREE[4:0], S36})};	// P40
	CLKDIVTHREE[6] <= &{nCYCLERES, ~(CLKDIVTHREE[6] ^ ~&{CLKDIVTHREE[5:0], S36})};	// P35

	CLKDIV[0] <= ~(~nCYCLERES | CLKDIV[0]);						// K62
	CLKDIV[1] <= &{nCYCLERES, CLKDIV[1] ^ CLKDIV[0]};			// J76
	CLKDIV[2] <= &{nCYCLERES, ~(CLKDIV[2] ^ ~&{CLKDIV[1:0]})};	// H74
	CLKDIV[3] <= &{nCYCLERES, ~(CLKDIV[3] ^ ~&{CLKDIV[2:0]})};	// J82A
	CLKDIV[4] <= &{nCYCLERES, ~(CLKDIV[4] ^ ~&{CLKDIV[3:0]})};	// J91
	CLKDIV[5] <= &{nCYCLERES, ~(CLKDIV[5] ^ ~&{CLKDIV[4:0]})};	// J85
	CLKDIV[6] <= &{nCYCLERES, ~(CLKDIV[6] ^ ~&{CLKDIV[5:0]})};	// K64
	CLKDIV[7] <= &{nCYCLERES, ~(CLKDIV[7] ^ ~&{CLKDIV[6:0]})};	// K72
	CLKDIV[8] <= &{nCYCLERES, ~(CLKDIV[8] ^ ~&{CLKDIV[7:0]})};	// K76

	CLKDIVD <= CLKDIV;
end

// Low pulse every 384 CLK cycles
assign nCYCLERES = nRES & ~&{CLKDIVTHREE, S36};


// S11 is the load signal for the final output PISO, it should match the falling edge of LRCK (start of new sample pair output) OK
assign S2 = ~|{~SR_S1[0], SR_H3[2]};

reg S10 = 0;
always @(posedge PIN_DTCK) begin
	S10 <= S2;
end
assign S11 = ~|{S10, S2};
assign AG103 = S11;
assign AH95 = SRA[3] | S11;

// COUNTERS

// Two identical parts
// TODO: Make modules

reg [7:0] REG222;
always @(*) begin
	if (!nWR222)
		REG222 <= ~PIN_DB_IN;
end

reg [7:0] AR23;
reg CNTB_OVF, CNTB_OVF_D;
always @(posedge CLK) begin
	if (!nRES) begin
		AR23 <= 8'd0;
		CNTB_OVF <= 1'b0;
	end else if (AR23 == 8'hFF) begin
		AR23 <= REG222;
		CNTB_OVF <= 1'b1;
	end else begin
    	AR23 <= AR23 + 1'b1;
		CNTB_OVF <= 1'b0;
	end

	CNTB_OVF_D <= CNTB_OVF;
end

reg [7:0] REG21B;
always @(*) begin
	if (!nWR21B)
		REG21B <= ~PIN_DB_IN;
end

reg [7:0] AS26;
reg CNTA_OVF, CNTA_OVF_D;
always @(posedge CLK) begin
	if (!nRES) begin
		AS26 <= 8'd0;
		CNTA_OVF <= 1'b0;
	end else if (AS26 == 8'hFF) begin
		AS26 <= REG21B;
		CNTA_OVF <= 1'b1;
	end else begin
    	AS26 <= AS26 + 1'b1;
		CNTA_OVF <= 1'b0;
	end

	CNTA_OVF_D <= CNTA_OVF;
end

reg AF117;
always @(posedge CLK) begin
	AF117 <= |{~CLKDIVD[3:2], CLKDIVD[1]};
end

reg [15:0] CNTC;	// Test not implemented
always @(posedge CLK) begin
	if (!nRES)
		CNTC <= 16'd0;
	else
    	CNTC <= CNTC + 1'b1;
end

// MUX C

reg [15:0] MUXC_PRE_A;
always @(*) begin
	if (!SRA[6])
		MUXC_PRE_A <= MULB_OUT;
end
reg [15:0] MUXC_PRE_B;
always @(*) begin
	if (!SRA[2])
		MUXC_PRE_B <= MULB_OUT;
end
reg [15:0] MUXC_PRE_C;
always @(*) begin
	if (!SRA[0])
		MUXC_PRE_C <= MULB_OUT;
end
reg [15:0] MUXC_PRE_D;
always @(*) begin
	if (!AJ106)	// Weird
		MUXC_PRE_D <= MULB_OUT;
end

reg [15:0] MUXC;
always @(*) begin
	case({CLKDIV[4], AM47B})
		2'b00: MUXC <= MUXC_PRE_D;
		2'b01: MUXC <= MUXC_PRE_C;
		2'b10: MUXC <= MUXC_PRE_B;
		2'b11: MUXC <= MUXC_PRE_A;
	endcase
end


// AUX SIPO

reg AXDA_SYNC;
always @(posedge PIN_AXXA) begin
	AXDA_SYNC <= PIN_AXDA;
end

wire [15:0] AXDMUX;
auxin AUXIN(
	PIN_AXXA,
	AXDA_SYNC,
	PIN_YMD,
	AXDMUX
);

wire [15:0] nAXDMUX;
assign nAXDMUX = ~AXDMUX;

// AUX DATA CONTROL

assign C127A = PIN_AXWA & ~PIN_ALRA;
assign C126 = PIN_AXWA & PIN_ALRA;

reg A139, E110, J108, D122;
always @(negedge PIN_AXXA) begin
	A139 <= PIN_YMD ? PIN_AXWA : C127A;
	J108 <= ~(PIN_YMD ? PIN_ALRA : C127A);
	D122 <= ~(PIN_YMD ? PIN_AXWA : C126);
end

always @(posedge CLK) begin
	E110 <= A139;
end

// AUX DATA LATCHES

reg [15:0] nAXDMUX_REGA1;
always @(posedge J108) begin
	nAXDMUX_REGA1 <= nAXDMUX;
end

reg [15:0] nAXDMUX_REGB1;
always @(posedge D122) begin
	nAXDMUX_REGB1 <= nAXDMUX;
end

reg [15:0] nAXDMUX_REGA2;
reg [15:0] nAXDMUX_REGB2;
always @(posedge E110) begin
	nAXDMUX_REGA2 <= nAXDMUX_REGA1;
	nAXDMUX_REGB2 <= nAXDMUX_REGB1;
end

wire [15:0] AXWORD;
assign AXWORD = ROMA_A[5] ? ~nAXDMUX_REGB2 : ~nAXDMUX_REGA2;

// LFOs

wire [7:0] LFOA;
LFO CA(
	.nRES(nRES),
	.PIN_DB_IN(PIN_DB_IN),
	.nWR(nWR21C),
	.CK(CNTA_OVF),
	.JKCK(CNTA_OVF_D),
	.LFO(LFOA)
);

wire [7:0] LFOB;
LFO CB(
	.nRES(nRES),
	.PIN_DB_IN(PIN_DB_IN),
	.nWR(nWR223),
	.CK(CNTB_OVF),
	.JKCK(CNTB_OVF_D),
	.LFO(LFOB)
);

// D LATCHES and MUX F

reg [30:0] DLAT_A;
always @(*) begin
	if (!D8)
		DLAT_A <= ADDD;
end

reg [30:0] DLAT_B;
always @(*) begin
	if (!TRIGD)
		DLAT_B <= ADDD;
end

reg [30:0] DLAT_C;
always @(*) begin
	if (!TRIGA)
		DLAT_C <= ADDD;
end

reg [30:0] DLAT_D;
always @(*) begin
	if (!TRIGF)
		DLAT_D <= ADDD;
end

reg [7:0] ALAT;
reg [7:0] BLAT;
always @(*) begin
	if (!TRIGP[14]) begin
		ALAT <= RAMA_DO[7:0];
		BLAT <= RAMB_DO[7:0];
	end
end

reg [7:0] A2LAT;
reg [7:1] B2LAT;
always @(*) begin
	if (!TRIGP[13]) begin
		A2LAT <= RAMA_DO[7:0];
		B2LAT <= RAMB_DO[7:1];
	end
end

assign P12 = MUXBIT4;
assign P8 = MUXBIT5;

reg [15:0] MUXF;
always @(*) begin
	case({P12, P8})
		2'b00: MUXF <= DLAT_C[30:15];
		2'b01: MUXF <= DLAT_B[30:15];
		2'b10: MUXF <= {ALAT, BLAT};
		2'b11: MUXF <= DLAT_A[30:15];
	endcase
end

// ACC C

// 16-bit accumulator, add or subtract

assign AD158 = |{~CLKDIVD[5:1]};
assign AD160 = |{CLKDIVD[3:1]};
assign AE119 = |{CLKDIVD[5:4], ~CLKDIVD[3:2], CLKDIVD[1]};
assign AE120 = |{CLKDIVD[5:4], ~CLKDIVD[3:2], ~CLKDIVD[1]};
assign AD159 = ~&{AD158, AD160, AE119, AE120};

reg nACCC_RES;
always @(posedge CLKDIVD[0]) begin
	nACCC_RES <= AD159;
end

assign ACCC_NEG = ~&{AE119, AE120};

assign AB103A = CLKDIV[6] ? REG224[6] : REG224[2];

assign AE131 = ~&{CLKDIVD[3], ~CLKDIVD[4]};
assign AB178 = CLKDIVD[3] & CLKDIVD[1];

assign AD69 = ~|{AE131, ~CLKDIVD[6]};
assign AE53 = ~&{AB178, CLKDIVD[6]};

reg [15:0] ACCC_MUX;
always @(*) begin
	casex({AE131, AB178, AD69, AE53})
		4'bxx00: ACCC_MUX <= {7'd0, REG224[5] ? {LFOB[7:0], 1'b0} : {1'b0, LFOB[7:0]}};	// Normal or << 1
		4'bxx01: ACCC_MUX <= {REG220, REG21F};
		4'b0010: ACCC_MUX <= {7'd0, REG224[1] ? {LFOA[7:0], 1'b0} : {1'b0, LFOA[7:0]}};	// Normal or << 1
		4'b0110: ACCC_MUX <= {REG219, REG218};
		4'b1010: ACCC_MUX <= AB103A ? {1'b0, CNTC[15:1]} : CNTC;	// Normal or >> 1
		4'b1110: ACCC_MUX <= {REG21E, REG21D};
		4'bxx11: ACCC_MUX <= {REG217, REG216};
	endcase
end

wire [15:0] ACCC_MUX_XOR;
assign ACCC_MUX_XOR = ACCC_NEG ? ~ACCC_MUX : ACCC_MUX;

reg [15:0] ACCC_PRE;
always @(negedge CLKDIVD[0]) begin
	ACCC_PRE <= nACCC_RES ? (ACCC_NEG + ACCC_PRE + ACCC_MUX_XOR) : 16'd0;
end

reg [14:0] ACCC;
reg AG83;	// AG83 is ACCC[15]
always @(posedge AF117) begin
	ACCC <= ACCC_PRE[14:0];
	AG83 <= REG224[3] ?
				REG225_D5 ?
					REG225_D4 ? ACCC_PRE[15] : ACCC_PRE[13] :
					REG225_D4 ? ACCC_PRE[11] : ACCC_PRE[9] :
				CLKDIVD[6];
end

// EXT MEM DATA

reg AE145;
always @(posedge CLKDIVD[1]) begin
	AE145 <= CLKDIVD[4];
end

reg [15:0] ACCD_OUT_REG;
always @(posedge AE145) begin
	ACCD_OUT_REG <= ACCD;
end

assign AB98B = CLKDIV[6] ? REG224[4] : REG224[0];

always @(*) begin
	casex({REG22F_D4, CLKDIVD[4], AB98B, CLKDIVD[3]})
		4'b0000: PIN_RD_OUT <= REGEEB[7:0];
		4'b0001: PIN_RD_OUT <= REGEEB[15:8];
		4'b0010: PIN_RD_OUT <= REGEFB[7:0];
		4'b0011: PIN_RD_OUT <= REGEFB[15:8];
		4'b01x0: PIN_RD_OUT <= ACCD_OUT_REG[7:0];
		4'b01x1: PIN_RD_OUT <= ACCD_OUT_REG[15:8];
		4'b1xxx: PIN_RD_OUT <= PIN_DB_IN;
	endcase
end

// EXT MEM CONTROL

assign AB103A = CLKDIV[6] ? REG224[6] : REG224[2];
assign AB79 = CNTC[0];	// Test not implemented

assign AA120 = ~|{~AB103A, AB79};

assign AH108 = SRA[0] | |{~CLKDIVD[8], ~CLKDIVD[6], ~CLKDIVD[5], AA120};
assign AH104 = SRA[0] | |{~CLKDIVD[8], CLKDIVD[6], ~CLKDIVD[5], AA120};

reg W92;
assign nCLKDIVD16 = ~CLKDIVD[3];
always @(posedge nCLKDIVD16 or negedge nRES) begin
	if (!nRES)
		W92 <= 1'b0;
	else
		W92 <= ~|{REG22F_D4, CLKDIV[6] & REG224[3], AA120, PIN_DLY};
end

assign W93 = ~CLKDIVD[8] | ~W92;
assign Y117 = CLKDIVD[2] | W93;

reg X124, W99, W112;
always @(negedge CLKDIV[1]) begin
	X124 <= Y117;
	W99 <= ~|{~CLKDIVD[2], ~MUX_ACTIVE, CLKDIVD[4], CLKDIV[8], REG22F_D4};
	W112 <= W100;
end

reg X103, W100, W111, Y115, W101;
always @(posedge CLK) begin
	X103 <= ~^{CLKDIV[5:4]};
	W100 <= ~W99;
	W111 <= ~W112;
	Y115 <= X123;
	W101 <= W110;
end

assign Y114 = ~&{~X123, ~Y115};
assign W94 = PIN_NRD | nACCESS22D;

reg X123;
always @(posedge CLK or negedge nRES) begin
	if (!nRES)
		X123 <= 1'b1;
	else
		X123 <= X124;
end

reg X105, X121, X120;
always @(negedge CLK) begin
	X105 <= ~|{~X103, Y114};
	X121 <= ~X105;
	X120 <= X121;
end
assign X110 = ~REG22F_D4 | REG22E[7];
assign Y109 = ~&{REG22F_D4, REG22E[7]};
assign W95 = PIN_NWR | nACCESS22D;
assign PIN_RAWP = ~|{~|{~X120, ~X105}, ~|{W95, Y109}};
assign PIN_RDWP = ~|{~|{PIN_RAWP, ~PIN_RRMD}, ~|{W95, X110}};
assign RD_DIR = PIN_RAWP & PIN_RDWP;

assign X122B = ~|{~|{PIN_USE2, PIN_NRD | nACCESS22D}, ~X123};
assign W110 = ~|{~|{W100, PIN_USE2}, ~W111};
assign TESTEN = 1'b0;
assign PIN_RA_EN = &{~REG22F_D4, ~TESTEN, X122B, W110};

assign PIN_RACS = Y114 & (nACCESS22D | Y109);
assign PIN_RABS = Y117 & Y109;
assign PIN_ROBS = &{~PIN_RRMD | PIN_RABS, W100, X110};
assign PIN_RAOE = ~|{~|{Y109, W94}, ~|{X123, X103}};
assign PIN_ROCS = ~&{~|{PIN_RACS, ~PIN_RRMD}, ~|{W101, W110}, ~|{X110, nACCESS22D}};
assign PIN_ROOE = &{X110 | W94, W110, PIN_RAOE | ~PIN_RRMD};

// TIMER

// REG227
reg [7:0] REG227;
always @(*) begin
	if (!nWR227)
		REG227 <= PIN_DB_IN;
end

reg [7:0] TIMER_CNT = 0;
always @(posedge CLKDIVD[6]) begin
	if (!Y4) begin
		TIMER_CNT <= REG227;
	end else begin
		TIMER_CNT <= TIMER_CNT + 1'b1;
	end
end

assign TIMER_TC = (TIMER_CNT == 8'hFF);
assign Y4 = ~|{~REG22F_D5, TIMER_TC};

reg X5;
always @(posedge CLKDIVD[6] or negedge REG22F_D5) begin
	if (!REG22F_D5) begin
		X5 <= 1'b0;
	end else begin
		X5 <= TIMER_TC ^ X5;
	end                                                                                                    
end

assign PIN_TIM = ~X5;

// POST address counter

reg [16:0] ADDRCNT;
always @(posedge nACCESS22D or negedge REG22F_D4) begin
	if (!REG22F_D4)
		ADDRCNT <= 17'h00000;
	else
        ADDRCNT <= ADDRCNT + 1'b1;
end

// CPU DATA

reg [7:0] IRAM_OUT_REG;
always @(posedge IRAM_INT) begin
	IRAM_OUT_REG <= PIN_AB[0] ? RAMB_DO : RAMA_DO;
end

assign PIN_DB_OUT = PIN_AB09 ? PIN_AB[0] ? PIN_RD_IN : CH_ACTIVE : IRAM_OUT_REG;
assign PIN_DB_DIR = PIN_NCS | PIN_NRD;	// Low: PIN_DB are outputs

// EXT RAM ADDRESS

assign T130 = &{CLKDIVD[8], ~REG22F_D4};
assign T127 = REG22F_D4;

always @(*) begin
	case({T127, T130})
		2'b00: PIN_RA <= ADDB;
		2'b01: PIN_RA <= {7'd0, AG83, ACCC, CLKDIVD[3]};
		2'b10: PIN_RA <= {REG22E[6:0], ADDRCNT};
		2'b11: PIN_RA <= 24'd0;	// Test mode
	endcase
end

// REGISTERS DECODE

assign CPU_REGS = ~|{PIN_NCS, ~PIN_AB09};

reg [5:0] REGDECTOP;
always @(*) begin
	case({CPU_REGS, PIN_AB[5:3]})
		4'b1_000: REGDECTOP <= 6'b111110;	// S78
		4'b1_001: REGDECTOP <= 6'b111101;	// S76
		4'b1_010: REGDECTOP <= 6'b111011;	// S80
		4'b1_011: REGDECTOP <= 6'b110111;	// S75
		4'b1_100: REGDECTOP <= 6'b101111;	// S79
		4'b1_101: REGDECTOP <= 6'b011111;	// S77
		default: REGDECTOP <= 6'b111111;
	endcase
end

assign WR0007 = ~|{REGDECTOP[0], PIN_NWR};
assign WR080F = ~|{REGDECTOP[1], PIN_NWR};
assign WR1017 = ~|{REGDECTOP[2], PIN_NWR};
assign WR181F = ~|{REGDECTOP[3], PIN_NWR};
assign WR2027 = ~|{REGDECTOP[4], PIN_NWR};
assign WR282F = ~|{REGDECTOP[5], PIN_NWR};

DEC3 REGDECA(
	PIN_AB[2:0],
	WR0007,
	{nWR207, nWR206, nWR205, nWR204, nWR203, nWR202, nWR201, nWR200}
);

DEC3 REGDECB(
	PIN_AB[2:0],
	WR080F,
	{nWR20F, nWR20E, nWR20D, nWR20C, nWR20B, nWR20A, nWR209, nWR208}
);

DEC3 REGDECC(
	PIN_AB[2:0],
	WR1017,
	{nWR217, nWR216, nWR215, nWR214, nWR213, nWR212, nWR211, nWR210}
);

DEC3 REGDECD(
	PIN_AB[2:0],
	WR181F,
	{nWR21F, nWR21E, nWR21D, nWR21C, nWR21B, nWR21A, nWR219, nWR218}
);

// Reg 226 doesn't exist
DEC3 REGDECE(
	PIN_AB[2:0],
	WR2027,
	{nWR227, nWR226, nWR225, nWR224, nWR223, nWR222, nWR221, nWR220}
);

// Reg 22C doesn't exist
// Reg 22D is R/W
DEC3 REGDECF(
	PIN_AB[2:0],
	WR282F,
	{nWR22F, nWR22E, nWR22D, nWR22C, nWR22B, nWR22A, nWR229, nWR228}
);
assign nACCESS22D = ~&{PIN_AB[2:0] == 3'd5, ~REGDECTOP[5]};

// Registers

wire [7:0] REG216;
wire [7:0] REG217;
wire [7:0] REG218;
wire [7:0] REG219;
wire [7:0] REG21A;

REG8 R216(nWR216, ~PIN_DB_IN, REG216);
REG8 R217(nWR217, ~PIN_DB_IN, REG217);
REG8 R218(nWR218, ~PIN_DB_IN, REG218);
REG8 R219(nWR219, ~PIN_DB_IN, REG219);
REG8 R21A(nWR21A, ~PIN_DB_IN, REG21A);

wire [7:0] REG21D;
wire [7:0] REG21E;
wire [7:0] REG21F;
wire [7:0] REG220;
wire [7:0] REG221;

REG8 R21D(nWR21D, ~PIN_DB_IN, REG21D);
REG8 R21E(nWR21E, ~PIN_DB_IN, REG21E);
REG8 R21F(nWR21F, ~PIN_DB_IN, REG21F);
REG8 R220(nWR220, ~PIN_DB_IN, REG220);
REG8 R221(nWR221, ~PIN_DB_IN, REG221);


// REG224
reg [6:0] REG224 = 0;
always @(*) begin
	if (!nWR224)
		REG224 <= PIN_DB_IN[6:0];
end

// REG225
reg REG225_D0;
reg REG225_D1;
reg REG225_D4;
reg REG225_D5;
always @(*) begin
	if (!nWR225) begin
		REG225_D0 <= PIN_DB_IN[0];
		REG225_D1 <= PIN_DB_IN[1];
		REG225_D4 <= PIN_DB_IN[4];
		REG225_D5 <= PIN_DB_IN[5];
	end
end

assign AH92 = CLKDIV[5] ? REG225_D0 : REG225_D1;

// REG22E
reg [7:0] REG22E;
always @(*) begin
	if (!nWR22E)
		REG22E <= PIN_DB_IN;
end


// REG22F
reg REG22F_D7;
always @(*) begin
	if (!nRES) begin
		REG22F_D7 <= 1'b0;
	end else begin
		if (!nWR22F)
			REG22F_D7 <= PIN_DB_IN[7];	// Reg 22F bit 7: Disable internal RAM internal updates
	end
end

reg REG22F_D0;
reg REG22F_D1;
reg REG22F_D4 = 0;
reg REG22F_D5;
always @(posedge nWR22F) begin
	REG22F_D0 <= PIN_DB_IN[0];
	REG22F_D1 <= PIN_DB_IN[1];
	REG22F_D4 <= PIN_DB_IN[4];
	REG22F_D5 <= PIN_DB_IN[5];
end

wire [7:0] REG200;
wire [7:0] REG202;
wire [7:0] REG204;
wire [7:0] REG206;
wire [7:0] REG208;
wire [7:0] REG20A;
wire [7:0] REG20C;
wire [7:0] REG20E;

REG8 R200(nWR200, PIN_DB_IN, REG200);
REG8 R202(nWR202, PIN_DB_IN, REG202);
REG8 R204(nWR204, PIN_DB_IN, REG204);
REG8 R206(nWR206, PIN_DB_IN, REG206);
REG8 R208(nWR208, PIN_DB_IN, REG208);
REG8 R20A(nWR20A, PIN_DB_IN, REG20A);
REG8 R20C(nWR20C, PIN_DB_IN, REG20C);
REG8 R20E(nWR20E, PIN_DB_IN, REG20E);

reg REG210_D7, REG210_D6, REG210_D1, REG210_D0;
always @(*) begin
	if (!nWR210) begin
		REG210_D7 <= PIN_DB_IN[7];
		REG210_D6 <= PIN_DB_IN[6];
		REG210_D1 <= PIN_DB_IN[1];
		REG210_D0 <= PIN_DB_IN[0];
	end
end

reg REG211_D7, REG211_D6, REG211_D1, REG211_D0;
always @(*) begin
	if (!nWR211) begin
		REG211_D7 <= PIN_DB_IN[7];
		REG211_D6 <= PIN_DB_IN[6];
		REG211_D1 <= PIN_DB_IN[1];
		REG211_D0 <= PIN_DB_IN[0];
	end
end

reg REG212_D7, REG212_D6, REG212_D1, REG212_D0;
always @(*) begin
	if (!nWR212) begin
		REG212_D7 <= PIN_DB_IN[7];
		REG212_D6 <= PIN_DB_IN[6];
		REG212_D1 <= PIN_DB_IN[1];
		REG212_D0 <= PIN_DB_IN[0];
	end
end

reg REG213_D7, REG213_D6, REG213_D1, REG213_D0;
always @(*) begin
	if (!nWR213) begin
		REG213_D7 <= PIN_DB_IN[7];
		REG213_D6 <= PIN_DB_IN[6];
		REG213_D1 <= PIN_DB_IN[1];
		REG213_D0 <= PIN_DB_IN[0];
	end
end

reg E51;
always @(posedge CLKDIVD[0])
	E51 <= (CLKDIVD[4] ^ CLKDIVD[2]) | CLKDIV[3];

// MULA

reg [7:0] MULA_A_LATA;
reg [7:0] MULA_A_LATB;
always @(*) begin
	if (!TRIGP[10])
		{MULA_A_LATB, MULA_A_LATA} <= {RAMB_DO, RAMA_DO};
end

wire [7:0] MULA_A;	// Test not implemented
assign MULA_A = TRIGE ? MULA_A_LATB : MULA_A_LATA;

wire [15:0] MULA_B;	// Test not implemented
assign MULA_B = TRIGH ?
					E51 ? {1'b0, DLAT_A[14:0]} : {1'b0, DLAT_D[14:0]} :
					E51 ? DLAT_A[30:15] : DLAT_D[30:15];

wire [31:0] MULA_OUT_RAW;
assign MULA_OUT_RAW = {8'd0, MULA_A} * MULA_B;

wire [23:0] MULA_OUT;
assign MULA_OUT = MULA_OUT_RAW[23:0];	// Intermediate MULA_OUT_RAW maybe not needed

// SHEET 54 REGEEB / REGEFB

reg [15:0] REGEEB;
reg [15:0] REGEFB;
always @(negedge PIN_DTCK) begin
	if (!AG103) begin
		REGEEB <= REGEE;
		REGEFB <= REGEF;
	end
end

// ROMA ADDRESS

// This stuff not actually related to ROMA:
assign AJ57 = (CLKDIV[6] ^ CLKDIV[8]) | CLKDIV[7];

wire [3:0] AJ92;
DEC2 AJ92Cell(
	{~CLKDIV[6], CLKDIV[5]},
	AJ92
);

assign AJ94 = |{AJ57, AJ92[0]} & |{AJ57, AJ92[1]};

// MUX H

reg [15:0] MUXH_PRE_REGA;
always @(posedge AH104) begin
	MUXH_PRE_REGA <= {RD_REG2A, RD_REG2B};
end

reg [15:0] MUXH_PRE_REGB;
always @(posedge AH108) begin
	MUXH_PRE_REGB <= {RD_REG2A, RD_REG2B};
end

reg [15:0] MUXH;
always @(*) begin
	case({AH92, CLKDIV[5]})
    	2'd0: MUXH <= MUXH_PRE_REGA;
		2'd1: MUXH <= MUXH_PRE_REGB;
		2'd2: MUXH <= REGEEB;
		3'd3: MUXH <= REGEFB;
	endcase
end

// MUX G

reg [15:0] MUXF_REG;
always @(posedge CLKDIVD[4]) begin
	MUXF_REG <= MUXF;
end

wire [15:0] MUXG_PRE;
assign MUXG_PRE = AJ94 ? MUXH : AXWORD;

wire [15:0] MUXG;
assign MUXG = AJ57 ? MUXF_REG : MUXG_PRE;

// MUL B

reg [15:0] MULB_A;
always @(posedge CLKDIVD[0]) begin
	MULB_A <= AJ114 ? ROMB_D : {1'b0, CLKDIVD[6] ? REG221 : REG21A, 7'd0};
end

reg [15:0] MUXG_REG;
always @(negedge CLKDIVD[4]) begin
	MUXG_REG <= MUXG;
end

reg [15:0] MULB_B;
always @(posedge CLKDIVD[0]) begin
	MULB_B <= AS70 ? AJ106 ? MUXG_REG : {RD_REG2A, RD_REG2B} : MUXC;
end

wire [31:0] MULB_OUT_RAW;
assign MULB_OUT_RAW = MULB_A * MULB_B;

wire [15:0] MULB_OUT;
assign MULB_OUT = MULB_OUT_RAW[31:16];

// ROM A

wire [8:0] ROMA_A;
assign ROMA_A = CLKDIV;

wire [6:0] ROMA_D;
ROM #(9, 7, "ROMA.mem") ROMA(
	CLK,
	ROMA_A,
	ROMA_D
);

// ROM B

assign AS70 = |{CLKDIV[4:2]};
assign AS75 = CLKDIV[3] ^ CLKDIV[2];
assign AM47B = ~^{CLKDIV[3:2]} ^ CLKDIV[4];	// Weird

reg AK50A, AK55;
always @(posedge CLKDIV[1]) begin
	AK50A <= CLKDIV[4] ^ CLKDIV[3];
	AK55 <= ~^{CLKDIV[2:1]};
end

assign AK51 = &{~REG22F_D1, ~AK55, W67};
assign AS27 = REG22F_D1 | AS17;
assign AK54 = &{~REG22F_D1, AR1};
assign AK53 = &{~REG22F_D1, AR12};
assign AK52 = &{~REG22F_D1, AS15};



reg [7:0] ROMB_A_RAMB_LAT;
always @(*) begin
	if (!TRIGP[8])
		ROMB_A_RAMB_LAT <= RAMB_DO[6:0];
end

reg [7:0] ROMB_B_RAMA_REG;
always @(negedge CLKDIVD[4]) begin
	ROMB_B_RAMA_REG <= ROMB_A_RAMB_LAT;
end




reg [7:0] ROMB_A_RAMA_REG;
always @(posedge SRA[4]) begin
	ROMB_A_RAMA_REG <= RAMA_DO[6:0];
end

reg [7:0] ROMB_A_RAMA_LAT;
always @(*) begin
	if (!TRIGP[7])
		ROMB_A_RAMA_LAT <= ROMB_A_RAMA_REG;
end





wire [7:0] ROMB_A;
wire [6:0] ROMB_A_PRE;

reg [6:0] REG228;
always @(*) begin
	if (!nWR228)
		REG228 <= PIN_DB_IN[6:0];
end

reg [6:0] REG229;
always @(*) begin
	if (!nWR229)
		REG229 <= PIN_DB_IN[6:0];
end

reg [6:0] REG22A;
always @(*) begin
	if (!nWR22A)
		REG22A <= PIN_DB_IN[6:0];
end

reg [6:0] REG22B;
always @(*) begin
	if (!nWR22B)
		REG22B <= PIN_DB_IN[6:0];
end

reg [6:0] ROMB_A_PRE_MUXB;
always @(*) begin
	case({W62, X60})
		2'd0: ROMB_A_PRE_MUXB <= REG228;
		2'd1: ROMB_A_PRE_MUXB <= REG229;
		2'd2: ROMB_A_PRE_MUXB <= REG22A;
		2'd3: ROMB_A_PRE_MUXB <= REG22B;
	endcase
end

reg [6:0] ROMB_A_PRE_MUXA;
always @(*) begin
	case({AS75, ~CLKDIV[2]})
		2'd0: ROMB_A_PRE_MUXA <= ROMB_A_RAMA_LAT;
		2'd1: ROMB_A_PRE_MUXA <= ROMB_A_PRE_MUXB;
		2'd2: ROMB_A_PRE_MUXA <= {ROMB_B_RAMA_REG[3:0], 3'b111};
		2'd3: ROMB_A_PRE_MUXA <= {ROMB_B_RAMA_REG[7:4], 3'b111};
	endcase
end

assign ROMB_A_PRE = AK50A ? {1'b0, AK51, ~CLKDIV[1], AS27, AK54, AK53, AK52} : ROMB_A_PRE_MUXA;

assign ROMB_A = {AK50A, ROMB_A_PRE};

wire [15:0] ROMB_D;
ROM #(8, 16, "ROMB.mem") ROMB(
	CLKDIVD[0],
	ROMB_A,
	ROMB_D
);

// RAM A DIN

wire [7:0] RAMA_DI;
assign RAMA_DI = IRAM_INT ? RAMA_DI_INT : PIN_DB_IN;

reg [7:0] RAMA_DI_INT;
always @(posedge CLK) begin
	RAMA_DI_INT <= RAMA_DI_MUXA;
end

wire [7:0] RAMA_DI_MUXA;
assign RAMA_DI_MUXA = S122 ? RAMA_DI_MUXC : RAMA_DI_MUXB;

wire [7:0] RAMA_DI_MUXB;
assign RAMA_DI_MUXB = CLKDIV[1] ? ADDA[31:24] : RAMA_DI_MUXD;

wire [7:0] RAMA_DIN_MUXD;
assign RAMA_DI_MUXD = CLKDIV[2] ?
							(~CLKDIV[0]) ? BASE[15:8] : ADDA[39:32] :
							(~CLKDIV[0]) ? ADDA[15:8] : MUXD[15:8];

wire [7:0] RAMA_DIN_MUXC;
assign RAMA_DI_MUXC = H69 ?
							H70 ? RAMA_MUXC_PRE_D : RAMA_MUXC_PRE_C :
							H70 ? RAMA_MUXC_PRE_B : RAMA_MUXC_PRE_A;

reg [7:0] RAMA_MUXC_PRE_A;
reg [7:0] RAMA_MUXC_PRE_B;
reg [7:0] RAMA_MUXC_PRE_C;
reg [7:0] RAMA_MUXC_PRE_D;

always @(*) begin
	if (!TRIGB) begin
		RAMA_MUXC_PRE_A <= ADDD[14:7];
		RAMA_MUXC_PRE_D <= ADDD[30:23];
	end
end

always @(*) begin
	if (!TRIGC) begin
		RAMA_MUXC_PRE_B <= ADDD[30:23];
		RAMA_MUXC_PRE_C <= ADDD[14:7];
	end
end

// RAM B DIN
wire [7:0] RAMB_DI;
assign RAMB_DI = IRAM_INT ? RAMB_DI_INT : PIN_DB_IN;

reg [7:0] RAMB_DI_INT;
always @(posedge CLK) begin
	RAMB_DI_INT <= RAMB_DI_MUXA;
end

wire [7:0] RAMB_DI_MUXA;
assign RAMB_DI_MUXA = S122 ? RAMB_DI_MUXC : RAMB_DI_MUXB;

wire [7:0] RAMB_DI_MUXB;
assign RAMB_DI_MUXB = CLKDIV[1] ? ADDA[23:16] : RAMB_DI_MUXD;

wire [7:0] RAMB_DI_MUXD;
assign RAMB_DI_MUXD = CLKDIV[2] ?
							(~CLKDIV[0]) ? BASE[7:0] : BASE[23:16] :
							(~CLKDIV[0]) ? ADDA[7:0] : MUXD[7:0];

wire [7:0] RAMB_DI_MUXC;
assign RAMB_DI_MUXC = H69 ?
							H70 ? RAMB_MUXC_PRE_D : RAMB_MUXC_PRE_C :
							H70 ? RAMB_MUXC_PRE_B : RAMB_MUXC_PRE_A;

reg [7:0] RAMB_MUXC_PRE_A;
reg [7:0] RAMB_MUXC_PRE_B;
reg [7:0] RAMB_MUXC_PRE_C;
reg [7:0] RAMB_MUXC_PRE_D;

always @(*) begin
	if (!TRIGB) begin
		RAMB_MUXC_PRE_A <= {ADDD[6:0], 1'b0};
		RAMB_MUXC_PRE_D <= ADDD[22:15];
	end
end

always @(*) begin
	if (!TRIGC) begin
		RAMB_MUXC_PRE_B <= ADDD[22:15];
		RAMB_MUXC_PRE_C <= {ADDD[6:0], 1'b0};
	end
end

// Internal RAM control

// IRAM_INT=1: RAM fed by internal data
// IRAM_INT=0: RAM fed by CPU data

assign R79 = PIN_AB09 | PIN_NCS;
assign CPU_WR_IRAM = ~|{R79, PIN_NWR};
assign CPU_IRAM = (CPU_WR_IRAM | ~|{R79, PIN_NRD});
assign CPU_REGS = ~|{~PIN_AB09, PIN_NCS};
assign PIN_WAIT = ~R83 | R79;	// Doesn't look right but maybe correct ?

reg P69, R83 = 0;
always @(posedge CLK or negedge CPU_IRAM) begin
	if (!CPU_IRAM)
		R83 <= 1'b1;
	else
		R83 <= P67;
end

always @(posedge CLK) begin
	P69 <= CPU_IRAM;
end

reg CPU_IRAM_WR;	// P74
always @(posedge CLK or negedge CPU_WR_IRAM) begin
	if (!CPU_WR_IRAM)
		CPU_IRAM_WR <= 1'b0;
	else
		CPU_IRAM_WR <= ~|{P72, N43, P67};
end

reg P72;
always @(posedge CPU_IRAM_WR or negedge CPU_WR_IRAM) begin
	if (!CPU_WR_IRAM)
		P72 <= 1'b0;
	else
		P72 <= 1'b1;
end

// Internal RAM internal write pulse gen
assign P84B = ~&{ROMA_A[4:3], ~&{~CLKDIV[2:1]}};
assign P88 = ~&{~&{P84B, ~CLKDIV[8], ROMA_A[4], ~&{~CLKDIV[3:2]}, MUX_ACTIVE}, P84B | ~P91};

reg P91 = 0;
always @(posedge ROMA_A[5]) begin
	P91 <= ~CLKDIV[8];
end

reg P87 = 0;
always @(posedge CLK) begin
	P87 <= P88;
end

assign INT_IRAM_WR = ~|{REG22F_D7, ~P87};	// P86

// CPU-triggered IRAM writes must fall on slots where ROMA_D == xF (CPU access slot)
// IRAM_INT high = slot is internal access, IRAM_INT low = slot is CPU access, matches CPU access slots with RAM address OK

assign N45 = CPU_IRAM_WR & PIN_AB[0];		// Odd write
assign P75A = ~|{~CPU_IRAM_WR, PIN_AB[0]};	// Even write

assign RAMA_WR = CLK | ~(IRAM_INT ? INT_IRAM_WR : N45);
assign RAMB_WR = CLK | ~(IRAM_INT ? INT_IRAM_WR : P75A);

reg [6:0] RAM_A;
always @(posedge CLK) begin
	RAM_A <= N43 ? ROMA_D : PIN_AB[7:1];
end

assign N43 = ~&{CLKDIVD[1], ~CLKDIVD[0]};

wire [3:0] P59;
DEC2 P59Cell(
	{CLKDIVD[1], ~CLKDIVD[0]},
	P59
);

wire [3:0] P61;
DEC2 P61Cell(
	{PIN_DTS2, PIN_DTS1},
	P61
);

assign P62 = ~|{~|{P59[0], P61[0]}, ~|{P59[1], P61[1]}, ~|{P59[2], P61[2]}, ~|{P59[3], P61[3]}};
assign P67 = (P62 | ~P69) & R83;

reg IRAM_INT;
always @(posedge CLK) begin
	IRAM_INT <= N43;
end

assign H69 = ~|{~CLKDIV[2], CLKDIV[1]};
assign H70 = ~|{~CLKDIV[2], CLKDIV[0]};

assign S122 = |{ROMA_A[2:1]} & ROMA_A[3];

// ADPCM STEP

reg [15:0] STEP;
always @(*) begin
	case(DTYPE[2:1])
    	2'd0: STEP[10:0] <= {RD_REGA[2:0], RD_REGB[7:0]};
		2'd1: STEP[10:0] <= {DPCM_STEP[2:0], 8'd0};
		2'd2: STEP[10:0] <= {DPCM_STEP[6:0], 4'd0};
		3'd3: STEP[10:0] <= {{4{DPCM_STEP[7]}}, DPCM_STEP[6:0]};
	endcase
end
always @(*) begin
	case(DTYPE[2:1])
		2'd0: STEP[15:11] <= RD_REGA[7:3];
		3'd1: STEP[15:11] <= DPCM_STEP[7:3];
    	2'd2, 2'd3: STEP[15:11] <= {5{DPCM_STEP[7]}};
	endcase
end

// Stop marker detect
assign Z26 = ~&{DTYPE[2:1]};
assign V34B = ~|{{5{~DTYPE[2]}} & {STEP[14:11], STEP[9]}, {2{Z26}} & {STEP[10], STEP[8]}, ~STEP[15]};
assign V38A = ~&{|{STEP[7] & Z26, STEP[6:0]}, V34B};

// START/STOP

// Channel end update pulse generation
wire [7:0] M5;
DEC3 M5Cell(
	CLKDIVD[7:5],
	1'b1,
	M5
);
assign M5_GATED = M5 | {8{~&{CLKDIV[4], ~CLKDIV[8]}}};

// nCYCLERES delayed 1 clk
reg W17;
always @(posedge CLK) begin
	W17 <= nCYCLERES;
end

wire [7:0] CH_ACTIVE;
wire [7:0] nCH_LOOP;
wire [7:0] W15;
wire [7:0] W26;
wire [7:0] nODD_D4;
wire [7:0] nODD_D5;

wire [7:0] CHConfigWRs;
assign CHConfigWRs = {nWR201, nWR203, nWR205, nWR207, nWR209, nWR20B, nWR20D, nWR20F};

genvar i;
generate
	for (i = 0; i < 8; i = i + 1) begin
		startstop #(.chnum(i)) SSCH(
			.nRES(nRES),
			.CLK(CLK),			// Main CLK
			.DB_IN(PIN_DB_IN),
			.nODDWR(CHConfigWRs[i]),	// Odd channel config register write
			.nKONWR(nWR214),	// Key ON register write, common
			.nKOFFWR(nWR215),	// Key OFF register write, common
			.V38A(V38A),		// Common to all channels
			.M4(M5[i]),			// Pulses from M5 decoder
			.W17(W17),			// Common to all channels
			.CH_ACTIVE(CH_ACTIVE[i]),
			.nCH_LOOP(nCH_LOOP[i]),
			.nODDREG_D4(nODD_D4[i]),
			.nODDREG_D5(nODD_D5[i]),
			.W15(W15[i]),
			.W26(W26[i])
		);
	end
endgenerate


reg MUX_ACTIVE;		// MUX_ACTIVE must be active low
reg LOOPFLAG;
reg R88;			// What is this ?
always @(*) begin
	case(CLKDIVD[7:5])
		3'd0: begin
			MUX_ACTIVE <= CH_ACTIVE[0];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[0]};	// W15
			R88 <= W26[0];
		end
		3'd1: begin
			MUX_ACTIVE <= CH_ACTIVE[1];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[1]};	// AA25
			R88 <= W26[1];
		end
		3'd2: begin
			MUX_ACTIVE <= CH_ACTIVE[2];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[2]};	// R35
			R88 <= W26[2];
		end
		3'd3: begin
			MUX_ACTIVE <= CH_ACTIVE[3];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[3]};	// T18
			R88 <= W26[3];
		end
		3'd4: begin
			MUX_ACTIVE <= CH_ACTIVE[4];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[4]};	// N4
			R88 <= W26[4];
		end
		3'd5: begin
			MUX_ACTIVE <= CH_ACTIVE[5];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[5]};	// S34
			R88 <= W26[5];
		end
		3'd6: begin
			MUX_ACTIVE <= CH_ACTIVE[6];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[6]};	// Y37
			R88 <= W26[6];
		end
		3'd7: begin
			MUX_ACTIVE <= CH_ACTIVE[7];
			LOOPFLAG <= ~&{nCH_LOOP[0], ~W15[7]};	// Y38
			R88 <= W26[7];
		end
	endcase
end

// EXT DATA REGISTERS

reg [7:0] RD_REGA;
always @(negedge CLKDIVD[2] or negedge MUX_ACTIVE) begin
	if (!MUX_ACTIVE)
		RD_REGA <= 8'd0;
	else
		RD_REGA <= PIN_RD_IN;
end

reg [7:0] RD_REGB;
always @(negedge CLKDIVD[2] or negedge DTYPE[0]) begin
	if (!DTYPE[0])
		RD_REGB <= 8'd0;
	else
		RD_REGB <= RD_REGA;
end

// Weird, same clock and same bus as above, but no reset
reg [7:0] RD_REG2A;
reg [7:0] RD_REG2B;
always @(negedge CLKDIVD[2]) begin
	RD_REG2A <= PIN_RD_IN;
	RD_REG2B <= RD_REG2A;
end


// DPCM step decode

// T132: Nibble select
assign T132 = REVERSE ^ ADDA_LAT_B[0];
assign T133 = ~(ADDA[16] ^ ADDA_LAT_B[0]);

wire [3:0] DEC_IN;
assign DEC_IN = T133 ? 3'b111 : T132 ? ~RD_REGA[7:4] : ~RD_REGA[3:0];

wire [7:0] N37_X;
DEC3 N37(
	DEC_IN[2:0],
	1'b1,
	N37_X
);

assign N24 = N37_X[0] & N37_X[1];
assign N27 = N24 & N37_X[2];
assign N20 = N27 & N37_X[3];
assign N32 = N20 & N37_X[4];
assign N28 = N32 & N37_X[5];
assign N29 = N28 & N37_X[6];

wire [7:0] DPCM_STEP;
assign DPCM_STEP = DEC_IN[3] ? ~{1'b0, N29, N28, N32, N20, N27, N24, N37_X[0]} :
								~{1'b1, N37_X[0], N37_X[1], N37_X[2], N37_X[3], N37_X[4], N37_X[5], N37_X[6]};

// Register mux

reg [2:0] DTYPE;
reg REVERSE;
always @(*) begin
	case(CLKDIVD[7:5])
		3'd0: {REVERSE, DTYPE} <= REG200[5:2];
		3'd1: {REVERSE, DTYPE} <= REG202[5:2];
		3'd2: {REVERSE, DTYPE} <= REG204[5:2];
		3'd3: {REVERSE, DTYPE} <= REG206[5:2];
		3'd4: {REVERSE, DTYPE} <= REG208[5:2];
		3'd5: {REVERSE, DTYPE} <= REG20A[5:2];
		3'd6: {REVERSE, DTYPE} <= REG20C[5:2];
		3'd7: {REVERSE, DTYPE} <= REG20E[5:2];
	endcase
end

reg MUXBIT5;
reg MUXBIT4;
always @(*) begin
	case(CLKDIVD[7:5])
		3'd0: {MUXBIT5, MUXBIT4} <= {nODD_D5[7], nODD_D4[7]};
		3'd1: {MUXBIT5, MUXBIT4} <= {nODD_D5[0], nODD_D4[0]};
		3'd2: {MUXBIT5, MUXBIT4} <= {nODD_D5[1], nODD_D4[1]};
		3'd3: {MUXBIT5, MUXBIT4} <= {nODD_D5[2], nODD_D4[2]};
		3'd4: {MUXBIT5, MUXBIT4} <= {nODD_D5[3], nODD_D4[3]};
		3'd5: {MUXBIT5, MUXBIT4} <= {nODD_D5[4], nODD_D4[4]};
		3'd6: {MUXBIT5, MUXBIT4} <= {nODD_D5[5], nODD_D4[5]};
		3'd7: {MUXBIT5, MUXBIT4} <= {nODD_D5[6], nODD_D4[6]};
	endcase
end

reg W67;
always @(*) begin
	case({CLKDIVD[8:5], CLKDIV[1]})
		5'b00000: W67 <= ~(REG212_D7);	// D3 D3 A
		5'b00001: W67 <= ~(REG212_D6);	// D3 D3 B
		5'b00010: W67 <= ~(REG213_D7);	// D2 D3 A
		5'b00011: W67 <= ~(REG213_D6);	// D2 D3 B

		5'b00100: W67 <= ~(REG200[7]);	// D1 D3 A
		5'b00101: W67 <= ~(REG200[6]);	// D1 D3 B
		5'b00110: W67 <= ~(REG202[7]);	// D0 D3 A
		5'b00111: W67 <= ~(REG202[6]);	// D0 D3 B

		5'b01000: W67 <= ~(REG204[7]);	// D3 D2 A
		5'b01001: W67 <= ~(REG204[6]);	// D3 D2 B
		5'b01010: W67 <= ~(REG206[7]);	// D2 D2 A
		5'b01011: W67 <= ~(REG206[6]);	// D2 D2 B

		5'b01100: W67 <= ~(REG208[7]);	// D1 D2 A
		5'b01101: W67 <= ~(REG208[6]);	// D1 D2 B
		5'b01110: W67 <= ~(REG20A[7]);	// D0 D2 A
		5'b01111: W67 <= ~(REG20A[6]);	// D0 D2 B

		5'b10000: W67 <= ~(REG20C[7]);	// D3 D1 A
		5'b10001: W67 <= ~(REG20C[6]);	// D3 D1 B
		5'b10010: W67 <= ~(REG20E[7]);	// D2 D1 A
		5'b10011: W67 <= ~(REG20E[6]);	// D2 D1 B

		5'b10100: W67 <= ~(REG210_D7);	// D1 D1 A
		5'b10101: W67 <= ~(REG210_D6);	// D1 D1 B
		5'b10110: W67 <= ~(REG211_D7);	// D0 D1 A
		5'b10111: W67 <= ~(REG211_D6);	// D0 D1 B

		default: W67 <= 1'b0;			// x D0 x
	endcase
end

reg W62;
always @(*) begin
	case(CLKDIVD[8:5])
		4'b0000: W62 <= ~REG212_D1;	// D3 D3
		4'b0001: W62 <= ~REG213_D1;	// D2 D3
		4'b0010: W62 <= ~REG200[1];	// D1 D3
		4'b0011: W62 <= ~REG202[1];	// D0 D3

		4'b0100: W62 <= ~REG204[1];	// D3 D2
		4'b0101: W62 <= ~REG206[1];	// D2 D2
		4'b0110: W62 <= ~REG208[1];	// D1 D2
		4'b0111: W62 <= ~REG20A[1];	// D0 D2

		4'b1000: W62 <= ~REG20C[1];	// D3 D1
		4'b1001: W62 <= ~REG20E[1];	// D2 D1
		4'b1010: W62 <= ~REG210_D1;	// D1 D1
		4'b1011: W62 <= ~REG211_D1;	// D0 D1

		default: W62 <= 1'b0;		// x D0
	endcase
end

reg X60;
always @(*) begin
	case(CLKDIVD[8:5])
		4'b0000: X60 <= ~REG212_D0;	// D3 D3
		4'b0001: X60 <= ~REG213_D0;	// D2 D3
		4'b0010: X60 <= ~REG200[0];	// D1 D3
		4'b0011: X60 <= ~REG202[0];	// D0 D3

		4'b0100: X60 <= ~REG204[0];	// D3 D2
		4'b0101: X60 <= ~REG206[0];	// D2 D2
		4'b0110: X60 <= ~REG208[0];	// D1 D2
		4'b0111: X60 <= ~REG20A[0];	// D0 D2

		4'b1000: X60 <= ~REG20C[0];	// D3 D1
		4'b1001: X60 <= ~REG20E[0];	// D2 D1
		4'b1010: X60 <= ~REG210_D0;	// D1 D1
		4'b1011: X60 <= ~REG211_D0;	// D0 D1

		default: X60 <= 1'b0;		// x D0
	endcase
end

assign AA50 = |{DTYPE[2:1]};


// ADDR OFFSET SELECT

reg [23:0] MUX_OFFS;
always @(*) begin
	case({DTYPE[0], AA50})
    	2'b00: MUX_OFFS <= ADDA_LAT_B;								// DTYPE 0: Offset << 0
    	2'b01: MUX_OFFS <= {1'b0, ADDA_LAT_B[23:1]};				// DTYPE 2, 4, 6: Offset >> 0
    	2'b10, 2'b11: MUX_OFFS <= {ADDA_LAT_B[22:0], CLKDIVD[4]};	// DTYPE 1, 3, 5, 7: Offset << 1
	endcase
end

wire [23:0] OFFS;
assign OFFS = {24{REVERSE}} ^ MUX_OFFS;

wire [23:0] ADDB;
assign ADDB = REVERSE + OFFS + BASE;

reg [23:0] BASE;
always @(*) begin
	if (!N155)
		BASE[15:0] <= {RAMA_DO, RAMB_DO};
end
always @(*) begin
	if (!N153A)
		BASE[23:16] <= RAMB_DO;
end

assign N155 = ~&{~(LOOPFLAG ? TRIGP[0] : TRIGP[2]), ~&{TRIGP[0], TRIGP[2]}};
assign N153A = ~&{~(LOOPFLAG ? TRIGP[1] : TRIGP[3]), ~&{TRIGP[1], TRIGP[3]}};


assign PIN_DTAC = R83 & ~CPU_REGS;

wire [7:0] RAMA_DO;
wire [7:0] RAMB_DO;

RAM #(7, 8) RAMA(
	RAM_A,
	RAMA_DI,
	RAMA_DO,
	RAMA_WR
);

RAM #(7, 8) RAMB(
	RAM_A,
	RAMB_DI,
	RAMB_DO,
	RAMB_WR
);

assign R89 = R88 & LOOPFLAG;


// ADDER A (phase accumulation ?)

reg [23:0] ADDA_LAT_A;	// Should be delta value read from IRAM
always @(*) begin
	if (!MUX_ACTIVE) begin
		ADDA_LAT_A[23:0] <= 24'd0;
	end else begin
		if (!TRIGP[6])
			ADDA_LAT_A[15:0] <= {RAMA_DO, RAMB_DO};
		else if (!TRIGP[7])
			ADDA_LAT_A[23:16] <= RAMB_DO;
	end
end

reg [39:0] ADDA_LAT_B;	// Should be current accumulator value read, modified, stored in IRAM
always @(*) begin
	if (!R88) begin
		ADDA_LAT_B[15:0] <= 16'd0;
	end else begin
		if (!TRIGP[5])
			ADDA_LAT_B[15:0] <= {RAMA_DO, RAMB_DO};
	end
end

always @(*) begin
	if (!R89) begin
		ADDA_LAT_B[39:16] <= 24'd0;
	end else begin
		if (!TRIGP[1])
			ADDA_LAT_B[39:32] <= RAMA_DO;
		else if (!TRIGP[4])
			ADDA_LAT_B[31:16] <= {RAMA_DO, RAMB_DO};
	end
end

// 24bit + 40bit = 40bit
wire [39:0] ADDA;
assign ADDA = ADDA_LAT_A + ADDA_LAT_B;



always @(posedge CLK) begin
	PIN_DTCK <= CLKDIVTHREE[1];
end

reg [2:0] SR_WDCK = 0;
reg [2:0] SR_H3 = 0;
always @(posedge ~CLKDIVD[4]) begin
	SR_WDCK <= {SR_WDCK[1:0], CLKDIVTHREE[5]};
	SR_H3 <= {SR_H3[1:0], CLKDIVTHREE[6]};
end

reg [2:0] SR_S1 = 0;
always @(negedge PIN_DTCK) begin
	PIN_WDCK <= SR_WDCK[2];
	SR_S1 <= {SR_S1[1:0], SR_H3[2]};
end

assign PIN_LRCK = PIN_ADDA ? ~SR_S1[2] : SR_S1[0];

assign AH66 = ~&{PIN_ADDA, SR_S1[0]};

// ROOT51

assign F69 = ~CLKDIVD[4] | ~|{CLKDIVD[3:2]};

reg F68, F73;
always @(posedge CLKDIVD[1]) begin
	F68 <= ~|{CLKDIVD[3:2]} | F69;
	F73 <= CLKDIVD[3];
end

reg F66, F71;
always @(posedge CLKDIVD[0]) begin
	F66 <= F68;
	F71 <= F73;
end

assign F3 = ~F66;
assign F17 = ~F71;

reg [30:0] MUX_LAT2;
always @(*) begin
	if (!TRIGP[12])
		MUX_LAT2[30:15] <= {RAMA_DO, RAMB_DO};
	else if (!TRIGP[11])
		MUX_LAT2[14:0] <= {RAMA_DO, RAMB_DO[7:1]};
end

wire [30:0] ADDD_IN_AMUX;
assign ADDD_IN_AMUX = F3 ?
			F17 ? DLAT_D : {LAT_H40[15], LAT_H40, 14'd0} :
			F17 ? MUX_LAT2 : {ADDE, MULA_LAT[13:7]};

wire [30:0] ADDD_IN_A;
assign ADDD_IN_A = TRIGF ? ADDD_IN_AMUX : ~ADDD_IN_AMUX;


// ADDER C
// V38A = 0: MUXD = 0, otherwise MUX2

assign AA40 = ~|{AA50, ~V38A};
assign AA47 = ~|{~AA50, ~V38A};

reg [15:0] MUXAB_REG;
always @(posedge R89 or negedge TRIGP[9]) begin
	if (!TRIGP[9])
		MUXAB_REG <= 16'd0;
	else
		MUXAB_REG <= {RAMA_DO, RAMB_DO};
end

wire [15:0] ADDC;
assign ADDC = STEP + MUXAB_REG;

wire [15:0] MUXD;
assign MUXD = AA40 ? {RD_REGA, RD_REGB} : AA47 ? ADDC : 16'd0;


// ADDER D

reg D62;
always @(posedge CLKDIVD[0]) begin
	D62 <= ((CLKDIVD[1] & CLKDIVD[3]) | ~CLKDIVD[4]) & (CLKDIVD[1] | CLKDIVD[4]);
end

wire [30:0] ADDD_IN_BMUX;
assign ADDD_IN_BMUX = TRIGG ?
			D62 ? DLAT_B : {ALAT, BLAT, A2LAT, B2LAT[7:1]} :
			D62 ? DLAT_C : {ADDE, MULA_LAT[13:7]};

wire [30:0] ADDD_IN_B;
assign D11 = ~&{TRIGA, TRIGJ};
assign ADDD_IN_B = D11 ? ~ADDD_IN_BMUX : ADDD_IN_BMUX;

assign D12A = D11 | ~TRIGF;

wire [30:0] ADDD;
assign ADDD = D12A + ADDD_IN_B + ADDD_IN_A;


// ADDER E

wire [23:0] ADDER_E_RAW;
assign ADDER_E_RAW = L81_REG + MULA_OUT[23:14];

reg [23:0] ADDE;
reg [13:7] MULA_LAT;
reg [23:0] L81_REG;
always @(posedge CLKDIVD[0]) begin
	L81_REG <= MULA_OUT[23:0];
	ADDE <= ADDER_E_RAW;
	MULA_LAT <= MULA_OUT[13:7];
end



// TRIGGERS

wire [3:0] H58;
DEC2 H58Cell(
	CLKDIVD[4:3],
	H58
);

assign F118 = ~|{CLK, H58[0]};
assign J70 = ~|{CLK, H58[1]};
assign H57 = ~|{CLK, H58[2]};
assign H61B = ~|{CLK, H58[3]};

assign H61A = ~&{H61B, CLKDIVD[2:0] == 3'b010};

reg [14:0] TRIGP;
always @(*) begin
	case({F118, CLKDIVD[2:0]})
		4'b1_000: TRIGP[5:0] <= 6'b111110;	// N149
		4'b1_001: TRIGP[5:0] <= 6'b111101;	// N152
		4'b1_010: TRIGP[5:0] <= 6'b111011;	// N145
		4'b1_100: TRIGP[5:0] <= 6'b110111;	// N146
		4'b1_101: TRIGP[5:0] <= 6'b101111;	// M93
		4'b1_110: TRIGP[5:0] <= 6'b011111;	// N144
		default: TRIGP[5:0] <= 6'b111111;
	endcase
end

always @(*) begin
	case({J70, CLKDIVD[2:0]})
		4'b1_000: TRIGP[11:6] <= 6'b111110;	// J63
		4'b1_001: TRIGP[11:6] <= 6'b111101;	// K49
		4'b1_010: TRIGP[11:6] <= 6'b111011;	// J64
		4'b1_100: TRIGP[11:6] <= 6'b110111;	// J62
		4'b1_101: TRIGP[11:6] <= 6'b101111;	// K50
		4'b1_110: TRIGP[11:6] <= 6'b011111;	// J65
		default: TRIGP[11:6] <= 6'b111111;
	endcase
end

always @(*) begin
	case({H57, CLKDIVD[2:0]})
		4'b1_000: TRIGP[14:12] <= 3'b110;	// A119
		4'b1_001: TRIGP[14:12] <= 3'b101;	// A122
		4'b1_010: TRIGP[14:12] <= 3'b011;	// A117A
		default: TRIGP[14:12] <= 3'b111;
	endcase
end

assign D8 = TRIGJ & D67;

assign AB166 = ~&{~CLKDIV[4:1]};

// Weird, to confirm
reg AB167, AJ114;
always @(negedge CLKDIVD[0]) begin
	AB167 <= AB166;
	AJ114 <= AB167;
end

reg [11:0] SRA;
reg AJ106;
always @(posedge CLKDIVD[0]) begin
	SRA <= {SRA[10:0], AJ114};
	AJ106 <= AB167;
end

// The gaps between these decoded triggers match the CPU access slots OK
reg TRIGA, TRIGB, TRIGC, TRIGD, TRIGE, TRIGF, TRIGG, TRIGJ, E54, D67;
always @(posedge CLKDIVD[0]) begin
	TRIGA <= ~&{~CLKDIVD[4:1]};							// D72 0000
	TRIGB <= ~&{~CLKDIVD[4], CLKDIVD[3], ~CLKDIVD[2], CLKDIVD[1]};	// D75 0101
	TRIGC <= ~&{~CLKDIVD[4:3], CLKDIVD[2], ~CLKDIVD[1]};	// E63 0010
	TRIGD <= ~&{CLKDIVD[4], ~CLKDIVD[3:1]};				// D60 1000
	TRIGE <= ~&{~CLKDIVD[4:3], CLKDIVD[2:1]};			// E59 0011
	TRIGF <= ~&{CLKDIVD[4], ~CLKDIVD[3:2], CLKDIVD[1]};	// E50 1001
	TRIGG <= &{CLKDIVD[4], CLKDIVD[1]};					// D69 1xx1
	E54 <= &{~&{~CLKDIVD[4:3], CLKDIVD[2:1]}, ~&{~CLKDIVD[4], CLKDIVD[3], ~CLKDIVD[2:1]}};	// E55 0011 0100
	D67 = ~&{CLKDIVD[4:3], ~CLKDIVD[2], CLKDIVD[1]};	// D68 1101
	TRIGJ <= ~&{~CLKDIVD[4:2], CLKDIVD[1]};				// D74 0001
end

assign TRIGH = CLKDIV[1] ^ E54;

reg [15:0] LAT_H40;
always @(*) begin
	if (!H61A)
		LAT_H40 <= MUXD;
end

// MULB ACCs

reg [15:0] MULB_REGD;
always @(posedge SRA[0]) begin
	MULB_REGD <= MULB_OUT;
end

wire [15:0] ACCD;
assign ACCD = {RD_REG2A, RD_REG2B} + MULB_REGD;

reg [15:0] MULB_REGE;
always @(posedge CLKDIVD[0]) begin
	MULB_REGE <= MULB_OUT;
end

wire [15:0] ACCE;
assign ACCE = MUXE + {MULB_REGE[15], MULB_REGE[15:1]} + MULB_REGE[0];

// REGISTERS E

reg [15:0] REGEA;
always @(posedge SRA[11] or negedge AH95) begin
	if (!AH95)
		REGEA <= 16'd0;
	else
		REGEA <= ACCE;
end

reg [15:0] REGEB;
always @(posedge SRA[10] or negedge AH95) begin
	if (!AH95)
		REGEB <= 16'd0;
	else
		REGEB <= ACCE;
end

reg [15:0] REGEC;
always @(posedge SRA[9] or negedge AH95) begin
	if (!AH95)
		REGEC <= 16'd0;
	else
		REGEC <= ACCE;
end

reg [15:0] REGED;
always @(posedge SRA[8] or negedge AH95) begin
	if (!AH95)
		REGED <= 16'd0;
	else
		REGED <= ACCE;
end

reg [15:0] REGEE;
always @(posedge SRA[4] or negedge AH95) begin
	if (!AH95)
		REGEE <= 16'd0;
	else
		REGEE <= ACCE;
end

reg [15:0] REGEF;
always @(posedge SRA[5] or negedge AH95) begin
	if (!AH95)
		REGEF <= 16'd0;
	else
		REGEF <= ACCE;
end

reg [7:0] RAMA_LAT;
always @(*) begin
	if (!TRIGP[8])
		RAMA_LAT <= RAMA_DO;
end

reg [7:0] RAMA_REG;
always @(negedge CLKDIVD[4]) begin
	RAMA_REG <= RAMA_LAT;
end

assign {AS17, AR1, AR12, AS15} = ~AK55 ? RAMA_REG[3:0] : RAMA_REG[7:4];

// REG E MUX

assign AH116 = ~&{SRA[1:0], SRA[5:4]};

reg [15:0] MUXE;
always @(*) begin
	casex({AH116, CLKDIV[2], ~CLKDIV[1]})
    	3'b000: MUXE <= REGEA;	// A, D0
    	3'b001: MUXE <= REGEB;	// A, D1
    	3'b010: MUXE <= REGEC;	// A, D2
    	3'b011: MUXE <= REGED;	// A, D3
    	3'b1x0: MUXE <= REGEE;	// B, A
    	3'b1x1: MUXE <= REGEF;	// B, B
		default: MUXE <= 16'd0;	// Shouldn't happen
	endcase
end

// FINAL OUTPUT PISO
// AUX PISO

reg [15:0] FRDL_SR;
reg [15:0] FRDT_SR;
reg [15:0] REDL_SR;
reg [15:0] REDT_SR;
reg [31:0] AXDT_SR;
always @(negedge PIN_DTCK or negedge REG22F_D0) begin
	if (!REG22F_D0) begin
		FRDL_SR <= 16'd0;
		FRDT_SR <= 16'd0;
		REDL_SR <= 16'd0;
		REDT_SR <= 16'd0;
		AXDT_SR <= 32'd0;
	end else begin
		FRDL_SR <= S11 ? {FRDL_SR[14:0], 1'b0} : REGED;
		FRDT_SR <= S11 ? {FRDT_SR[14:0], 1'b0} : REGEB;
		REDL_SR <= S11 ? {REDL_SR[14:0], 1'b0} : REGED;
		REDT_SR <= S11 ? {REDT_SR[14:0], 1'b0} : REGEB;
		AXDT_SR <= S11 ? {AXDT_SR[30:0], 1'b0} : {REGEE, REGEF};
	end
end

assign PIN_FRDL = FRDL_SR[15];
assign PIN_FRDT = AH66 & FRDT_SR[15];
assign PIN_REDL = REDL_SR[15];
assign PIN_REDT = AH66 & REDT_SR[15];
assign PIN_AXDT = AXDT_SR[31];

endmodule
