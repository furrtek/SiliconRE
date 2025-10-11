// Konami 054539
// furrtek 2025

`include "DEC2.v"
`include "DEC3.v"
`include "REG8.v"
`include "RAM.v"
`include "ROM.v"
`include "startstop.v"

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

	output [23:0] PIN_RA,
	input [7:0] PIN_RD_IN,
	output [7:0] PIN_RD_OUT,
	output reg PIN_TIM
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

// TIMER

reg [7:0] TIMER_CNT = 0;
always @(posedge CLKDIVD[6]) begin
	if (!Y4) begin
		TIMER_CNT <= REG227;
	end else begin
		TIMER_CNT <= TIMER_CNT + 1'b1;
	end
end

assign TIMER_TC = (TIMER_CNT == 8'hFF);
assign Y4 = ~|{~REG22F[5], TIMER_TC};

always @(posedge CLKDIVD[6] or negedge REG22F[5]) begin
	if (!REG22F[5]) begin
		PIN_TIM <= 1'b1;
	end else begin
		PIN_TIM <= TIMER_TC ^ PIN_TIM;
	end                                                                                                    
end

// POST address counter

reg [16:0] ADDRCNT;
always @(posedge nACCESS22D or negedge REG22F[4]) begin
	if (!REG22F[4])
		ADDRCNT <= 17'h00000;
	else
        ADDRCNT <= ADDRCNT + 1'b1;
end

// CPU DATA

reg [7:0] IRAM_OUT_REG;
always @(posedge IRAM_INT) begin
	IRAM_OUT_REG <= PIN_AB[0] ? RAM_B_DOUT : RAM_A_DOUT;
end

assign PIN_DB_OUT = PIN_AB09 ? PIN_AB[0] ? PIN_RD_IN : CH_ACTIVE : IRAM_OUT_REG;
assign PIN_DB_DIR = PIN_NCS | PIN_NRD;


// EXT RAM ADDRESS

// DEBUG: Assumes T127 = 0 (no test mode, not in POST mode)
assign PIN_RA = CLKDIVD[8] ? 24'bzzzzzzzz_zzzzzzzz_zzzzzzzz : ADDB;	// TODO

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

// REG227
reg [7:0] REG227;
always @(*) begin
	REG227 <= PIN_DB_IN;
end

// REG22F
reg [7:0] REG22F;
always @(*) begin
	if (!nRES) begin
		REG22F[7] <= 1'b0;
	end else begin
		if (!nWR22F)
			REG22F[7] <= PIN_DB_IN[7];	// Reg 22F bit 7: Disable internal RAM internal updates
	end
end
always @(posedge nWR22F) begin
	REG22F[1:0] <= PIN_DB_IN[1:0];
	REG22F[5:4] <= PIN_DB_IN[5:4];
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

reg E51;
always @(posedge CLKDIVD[0])
	E51 <= (CLKDIVD[4] ^ CLKDIVD[2]) | CLKDIV[3];

// MULA

reg [7:0] MULA_A_LATA;
reg [7:0] MULA_A_LATB;

always @(*) begin
	if (K50) {MULA_A_LATB, MULA_A_LATA} <= {MUX_B, MUX_A};
end

wire [7:0] MULA_A;	// Test not implemented
assign MULA_A = TRIGE ? MULA_A_LATB : MULA_A_LATA;

reg [15:0] MULA_B_LATA;
reg [15:0] MULA_B_LATB;
reg [14:0] MULA_B_LATC;
reg [14:0] MULA_B_LATD;

always @(*) begin
	if (TRIGF) begin
		MULA_B_LATA <= ADDD[30:15];
		MULA_B_LATC <= {1'b0, ADDD[14:0]};
	end
end

always @(*) begin
	if (D9) begin
		MULA_B_LATD <= {1'b0, ADDD[14:0]};
	end
end

always @(*) begin
	if (TRIGF) MULA_B_LATC <= ADDD[30:15];
end

wire [15:0] MULA_B;	// Test not implemented
assign MULA_B = TRIGH ?
					E51 ? {1'b0, MULA_B_LATD} : {1'b0, MULA_B_LATC} :
					E51 ? MULA_B_LATB : MULA_B_LATA;	// MULA_B_LATB = {D58, D57, E35... A55, A57, A53}

wire [31:0] MULA_OUT_RAW;
assign MULA_OUT_RAW = {8'd0, MULA_A} * MULA_B;

wire [23:0] MULA_OUT;
assign MULA_OUT = MULA_OUT_RAW[23:0];	// Intermediate MULA_OUT_RAW maybe not needed

// ROMA

wire [8:0] ROMA_A;
assign ROMA_A = CLKDIV;

wire [6:0] ROMA_D;
ROM #(9, 7, "ROMA.mem") ROMA(
	CLK,
	ROMA_A,
	ROMA_D
);

// INTERNAL RAM

assign N43 = ~&{CLKDIVD[1], ~CLKDIVD[0]};

wire [3:0] P59;
DEC2 DEC2_P59(
	{CLKDIVD[1], ~CLKDIVD[0]},
	P59
);

wire [3:0] P61;
DEC2 DEC2_P61(
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

// RAM A DIN
wire [7:0] RAM_A_DIN;
assign RAM_A_DIN = IRAM_INT ? RAM_A_DIN_INT : PIN_DB_IN;

reg [7:0] RAM_A_DIN_INT;
always @(posedge CLK) begin	// negedge ?
	RAM_A_DIN_INT <= RAM_A_DIN_MUXA;
end

wire [7:0] RAM_A_DIN_MUXA;
assign RAM_B_DIN_MUXA = S122 ? RAM_A_DIN_MUXC : RAM_A_DIN_MUXB;

wire [7:0] RAM_A_DIN_MUXB;
assign RAM_A_DIN_MUXB = CLKDIV[1] ? ADDA[31:24] : RAM_A_DIN_MUXD;

wire [7:0] RAM_A_DIN_MUXD;
assign RAM_A_DIN_MUXD = CLKDIV[2] ?
							(~CLKDIV[0]) ? 8'bzzzzzzzz : ADDA[39:32] :	// TODO
							(~CLKDIV[0]) ? ADDA[15:8] : 8'bzzzzzzzz;	// TODO

wire [7:0] RAM_A_DIN_MUXC;
assign RAM_A_DIN_MUXC = H69 ?
							H70 ? 8'bzzzzzzzz : 8'bzzzzzzzz :	// TODO
							H70 ? 8'bzzzzzzzz : 8'bzzzzzzzz;	// TODO

// RAM B DIN
wire [7:0] RAM_B_DIN;
assign RAM_B_DIN = IRAM_INT ? RAM_B_DIN_INT : PIN_DB_IN;

reg [7:0] RAM_B_DIN_INT;
always @(posedge CLK) begin	// negedge ?
	RAM_B_DIN_INT <= RAM_B_DIN_MUXA;
end

wire [7:0] RAM_B_DIN_MUXA;
assign RAM_B_DIN_MUXA = S122 ? RAM_B_DIN_MUXC : RAM_B_DIN_MUXB;

wire [7:0] RAM_B_DIN_MUXB;
assign RAM_B_DIN_MUXB = CLKDIV[1] ? ADDA[23:16] : RAM_B_DIN_MUXD;

wire [7:0] RAM_B_DIN_MUXD;
assign RAM_B_DIN_MUXD = CLKDIV[2] ?
							(~CLKDIV[0]) ? 8'bzzzzzzzz : 8'bzzzzzzzz :	// TODO
							(~CLKDIV[0]) ? ADDA[7:0] : 8'bzzzzzzzz;		// TODO

wire [7:0] RAM_B_DIN_MUXC;
assign RAM_B_DIN_MUXC = H69 ?
							H70 ? 8'bzzzzzzzz : 8'bzzzzzzzz :	// TODO
							H70 ? 8'bzzzzzzzz : 8'bzzzzzzzz;	// TODO

// IRAM_INT=1: RAM fed by internal data
// IRAM_INT=0: RAM fed by CPU data

assign R79 = PIN_AB09 | PIN_NCS;
assign R86 = ~|{R79, PIN_NWR};
assign CPU_IRAM = (R86 | ~|{R79, PIN_NRD});
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
always @(posedge CLK or negedge R86) begin
	if (!R86)
		CPU_IRAM_WR <= 1'b0;
	else
		CPU_IRAM_WR <= ~|{P72, N43, P67};
end

reg P72;
always @(posedge CPU_IRAM_WR or negedge R86) begin
	if (!R86)
		P72 <= 1'b0;
	else
		P72 <= 1'b1;
end

// ADPCM STEP

reg [15:0] STEP;
always @(*) begin
	case(DTYPE[2:1])
    	2'd0: STEP[10:0] <= {RD_REG[2:0], RD_REG2[7:0]};
		2'd1: STEP[10:0] <= {DPCM_STEP[2:0], 8'd0};
		2'd2: STEP[10:0] <= {DPCM_STEP[6:0], 4'd0};
		3'd3: STEP[10:0] <= {{4{DPCM_STEP[7]}}, DPCM_STEP[6:0]};
	endcase
end
always @(*) begin
	case(DTYPE[2:1])
		2'd0: STEP[15:11] <= RD_REG[7:3];
		3'd1: STEP[15:11] <= DPCM_STEP[7:3];
    	2'd2, 2'd3: STEP[15:11] <= {5{DPCM_STEP[7]}};
	endcase
end



// Stop marker detect
assign Z26 = ~&{DTYPE[2:1]};
assign V34B = ~|{{5{~DTYPE[2]}} & {STEP[14:11], STEP[9]}, {2{Z26}} & {STEP[10], STEP[8]}, ~STEP[15]};
assign V38A = ~&{|{STEP[7] & Z26, STEP[6:0]}, V34B};

// START / STOP



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

genvar i;
generate
	for (i = 0; i < 8; i = i + 1) begin
		startstop #(.chnum(i)) SSCH(
			.nRES(nRES),
			.CLK(CLK),			// Main CLK
			.DB_IN(PIN_DB_IN),
			.nODDWR(nWR201),	// Odd channel config register write
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

assign INT_IRAM_WR = ~|{REG22F[7], ~P87};	// P86

// CPU-triggered IRAM writes must fall on slots where ROMA_D == xF (CPU access slot)
// IRAM_INT high = slot is internal access, IRAM_INT low = slot is CPU access, matches CPU access slots with RAM address OK

assign N45 = CPU_IRAM_WR & PIN_AB[0];		// Odd write
assign P75A = ~|{~CPU_IRAM_WR, PIN_AB[0]};	// Even write

assign RAM_A_WR = CLK | ~(IRAM_INT ? INT_IRAM_WR : N45);
assign RAM_B_WR = CLK | ~(IRAM_INT ? INT_IRAM_WR : P75A);

reg [6:0] RAM_A;
always @(posedge CLK) begin
	RAM_A <= N43 ? ROMA_D : PIN_AB[7:1];
end

// Sample data read

assign M26 = ~MUX_ACTIVE;	// Test not implemented

reg [7:0] RD_REG;
always @(posedge ~CLKDIVD[2] or negedge M26) begin
	if (!M26)
		RD_REG <= 8'd0;
	else
		RD_REG <= PIN_RD_IN;
end

reg [7:0] RD_REG2;
always @(posedge ~CLKDIVD[2] or negedge DTYPE[0]) begin		// Test not implemented
	if (!DTYPE[0])
		RD_REG2 <= 8'd0;
	else
		RD_REG2 <= RD_REG;
end

// DPCM step decode

// T132: Nibble select
//assign T132 = REVERSE ^ ADDA_LAT_B[0];
assign T132 = 0;
//assign T133 = ~(ADDA[16] ^ ADDA_LAT_B[0]);
assign T133 = 0;

wire [3:0] DEC_IN;
assign DEC_IN = T133 ? 3'b111 : T132 ? {RD_REG[7:4]} : {RD_REG[3:0]};

wire [7:0] N37_X;
DEC3 N37(
	~DEC_IN[2:0],
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
assign ADDB = REVERSE + OFFS + ADDB_B;

reg [23:0] ADDB_B;
always @(*) begin
	if (!N155)
		ADDB_B[15:0] <= {MUX_A, MUX_B};
end
always @(*) begin
	if (!N153A)
		ADDB_B[23:16] <= MUX_B;
end

assign N155 = ~&{~(LOOPFLAG ? N149 : N145), ~&{N149, N145}};
assign N153A = ~&{~(LOOPFLAG ? N152 : N146), ~&{N152, N146}};
assign N152 = V128;


assign PIN_DTAC = R83 & ~CPU_REGS;

wire [7:0] RAM_A_DOUT;
wire [7:0] RAM_B_DOUT;

RAM #(7, 8) RAMA(
	RAM_A,
	RAM_A_DIN,
	RAM_A_DOUT,
	RAM_A_WR
);

RAM #(7, 8) RAMB(
	RAM_A,
	RAM_B_DIN,
	RAM_B_DOUT,
	RAM_B_WR
);

// MUX A / MUX B
// When test mode is disabled, these are just RAM_A/B_DOUT
wire [7:0] MUX_A;
wire [7:0] MUX_B;

assign MUX_A = RAM_A_DOUT;
assign MUX_B = RAM_B_DOUT;

assign R89 = R88 & LOOPFLAG;


// ADDER A (phase accumulation ?)
reg [39:0] ADDA_LAT_B;	// Should be current accumulator value read, modified, stored in IRAM

always @(*) begin
	if (!R88) begin
		ADDA_LAT_B[15:0] <= 16'h0000;
	end else begin
		if (!N147)
			ADDA_LAT_B[15:0] <= {MUX_A, MUX_B};
	end
end

always @(*) begin
	if (!R89) begin
		ADDA_LAT_B[31:16] <= 16'h0000;
	end else begin
		if (!N151)
			ADDA_LAT_B[31:16] <= {MUX_A, MUX_B};
	end
end

always @(*) begin
	if (!R89) begin
		ADDA_LAT_B[39:32] <= 8'h00;
	end else begin
		if (!V128)
			ADDA_LAT_B[39:32] <= MUX_A;
	end
end

reg [23:0] ADDA_LAT_A;	// Should be delta value read from IRAM

always @(*) begin
	if (!MUX_ACTIVE) begin
		ADDA_LAT_A[15:0] <= 16'h0000;
	end else begin
		if (!J72)
			ADDA_LAT_A[15:0] <= {MUX_A, MUX_B};
	end
end

always @(*) begin
	if (!MUX_ACTIVE) begin
		ADDA_LAT_A[23:16] <= 8'h00;
	end else begin
		if (!K49)
			ADDA_LAT_A[23:16] <= MUX_B;
	end
end


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
always @(posedge ~PIN_DTCK) begin
	PIN_WDCK <= SR_WDCK[2];
	SR_S1 <= {SR_S1[1:0], SR_H3[2]};
end

assign PIN_ADDA = 0;	// DEBUG
assign PIN_LRCK = PIN_ADDA ? ~SR_S1[2] : SR_S1[0];

// TRIGGERS

reg [5:0] TRIGDEC;
always @(*) begin
	case({J70, CLKDIVD[2:0]})
		4'b1_000: TRIGDEC <= 6'b111110;	// J63
		4'b1_001: TRIGDEC <= 6'b111101;	// K49
		4'b1_010: TRIGDEC <= 6'b111011;	// J64

		4'b1_100: TRIGDEC <= 6'b110111;	// J62
		4'b1_101: TRIGDEC <= 6'b101111;	// K50
		4'b1_110: TRIGDEC <= 6'b011111;	// J65
		default: TRIGDEC <= 6'b111111;
	endcase
end

assign J72 = TRIGDEC[0];
assign K49 = TRIGDEC[1];
assign J64 = TRIGDEC[2];
assign L9 = TRIGDEC[3];
assign K50 = TRIGDEC[4];
assign B74 = TRIGDEC[5];

reg [5:0] TRIGDECB;
always @(*) begin
	case({F118, CLKDIVD[2:0]})
		4'b1_000: TRIGDECB <= 6'b111110;	// N149
		4'b1_001: TRIGDECB <= 6'b111101;	// N152
		4'b1_010: TRIGDECB <= 6'b111011;	// N145

		4'b1_100: TRIGDECB <= 6'b110111;	// N146
		4'b1_101: TRIGDECB <= 6'b101111;	// M93
		4'b1_110: TRIGDECB <= 6'b011111;	// N144
		default: TRIGDECB <= 6'b111111;
	endcase
end

assign N149 = TRIGDECB[0];
assign V128 = TRIGDECB[1];
assign N145 = TRIGDECB[2];
assign N146 = TRIGDECB[3];
assign N151 = TRIGDECB[4];
assign N147 = TRIGDECB[5];

reg [2:0] TRIGDECC;
always @(*) begin
	case({H57, CLKDIVD[2:0]})
		4'b1_000: TRIGDECC <= 3'b110;	// A119
		4'b1_001: TRIGDECC <= 3'b101;	// A122
		4'b1_010: TRIGDECC <= 3'b011;	// A117
		default: TRIGDECC <= 3'b111;
	endcase
end

assign A117B = TRIGDECC[0];
assign B77 = TRIGDECC[1];
assign B98 = TRIGDECC[2];

assign H61A = ~&{H61B, CLKDIVD[2:0] == 3'b010};

assign AB166 = ~&{~CLKDIV[4:1]};
reg [13:0] SR_A;
always @(posedge CLKDIVD[0]) begin
	SR_A <= {SR_A[12:0], AB166};
end

// The gaps between these decoded triggers match the CPU access slots OK
reg TRIGA, TRIGB, TRIGC, TRIGD, TRIGE, TRIGF, TRIGG, TRIGJ, E54, D67;
always @(posedge CLKDIVD[0]) begin
	TRIGA <= ~&{~CLKDIVD[4:1]};	// D72 0000
	TRIGB <= ~&{~CLKDIVD[4], CLKDIVD[3], ~CLKDIVD[2], CLKDIVD[1]};	// D75 0101
	TRIGC <= ~&{~CLKDIVD[4:3], CLKDIVD[2], ~CLKDIVD[1]};	// E63 0010
	TRIGD <= ~&{CLKDIVD[4], ~CLKDIVD[3:1]};		// D60 1000
	TRIGE <= ~&{~CLKDIVD[4:3], CLKDIVD[2:1]};	// E59 0011
	TRIGF <= ~&{CLKDIVD[4], ~CLKDIVD[3:2], CLKDIVD[1]};	// E50 1001
	TRIGG <= &{CLKDIVD[4], CLKDIVD[1]};			// D69 1xx1
	E54 <= &{~&{~CLKDIVD[4:3], CLKDIVD[2:1]}, ~&{~CLKDIVD[4], CLKDIVD[3], ~CLKDIVD[2:1]}};	// E55 0011 0100
	D67 = ~&{CLKDIVD[4:3], ~CLKDIVD[2], CLKDIVD[1]};	// D68 1101
	TRIGJ <= ~&{~CLKDIVD[4:2], CLKDIVD[1]};		// D74 0001
end

assign TRIGH = CLKDIV[1] ^ E54;

assign AA117 = ~&{H57, ~CLKDIV[2], CLKDIV[1], ~CLKDIV[0]};
assign A122 = ~&{H57, ~CLKDIV[2], ~CLKDIV[1], CLKDIV[0]};
assign A119 = ~&{H57, ~CLKDIV[2], ~CLKDIV[1], ~CLKDIV[0]};

reg [3:0] H58;
always @(*) begin
	case(CLKDIVD[4:3])
    	2'd0: H58 <= 4'b1110;
    	2'd1: H58 <= 4'b1101;
    	2'd2: H58 <= 4'b1011;
    	2'd3: H58 <= 4'b0111;
	endcase
end

assign F118 = ~|{CLK, H58[0]};
assign J70 = ~|{CLK, H58[1]};
assign H57 = ~|{CLK, H58[2]};
assign H61B = ~|{CLK, H58[3]};

assign H61A = ~&{H61B, CLKDIVD[2:0] == 3'b010};

endmodule
