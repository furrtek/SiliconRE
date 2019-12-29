// Taito PC060HA logic def
// Sean 'furrtek' Gonsalves 2019
// GPLV2 - See LICENSE

// THIS IS UNTESTED !
// Fits in a Lattice LC4128ZE or Altera EPM7128

module top(
	input nIC,					// nRESET in
	output nROUT,				// nRESET out

	input SCLK,					// Slave clock
	input nSCS, nSRD, nSWR,	// Slave control
	input SA0,					// Slave address
	inout [3:0] SD,			// Slave data

	input MCLK,					// Master clock
	input nMCS, nMRD, nMWR,	// Master control
	input MA0,					// Master address
	inout [3:0] MD,			// Master data

	input IN0, IN1,			// GPIs for slave
	output nNMI,				// Z80 NMI trigger
	output reg AMP,			// Audio amp mute control
	input nPG,					// Unknown
	output reg PIN17			// Unknown
);

reg D1_Q;
reg A10_Q, H2_Q;
reg L8_Q, M5_Q, H5_Q;
reg F11_Q, C14_Q, B11_Q;
reg E4_Q, A3_Q;
reg G8_Q, K9_Q, H9_Q, J10_Q;
reg M14_Q, G11_Q, L14_Q, H10_Q;

reg SA0_LATCH, MA0_LATCH;

reg [3:0] MD_IN_LATCH;
reg [3:0] SD_IN_LATCH;

reg [3:0] STM0;
reg [3:0] STM1;
reg [3:0] STM2;
reg [3:0] STM3;
reg [3:0] MTS0;
reg [3:0] MTS1;
reg [3:0] MTS2;
reg [3:0] MTS3;


// Reset stuff ==================================

wire nRESET_BUF = nIC;	// A4
wire RESET_BUF = ~nIC;	// A5

// A10
always @(posedge MASTER_WR4 or negedge nRESET_BUF)
begin
	if (!nRESET_BUF)
		A10_Q <= 1'b0;
	else
		A10_Q <= MD[0];
end

// A6
wire nRESET = ~A10_Q & nRESET_BUF;
// G4, G2
wire RESET = ~nRESET;
assign nROUT = nRESET;

// Control outputs ==============================

// G2
always @(posedge SCLK or negedge D1_Q)
begin
	if (!D1_Q)
		PIN17 <= 1'b1;
	else
		PIN17 <= nPG;
end
// D1
always @(posedge SCLK or negedge nROUT)
begin
	if (!nROUT)
		D1_Q <= 1'b0;
	else
		D1_Q <= PIN17;
end


// G1
always @(posedge SLAVE_WR4 or negedge nROUT)
begin
	if (!nROUT)
		AMP <= 1'b0;
	else
		AMP <= SD_OUT[0];
end

// H1
wire H1 = nRESET & SLAVE_WR5;

// H2
always @(posedge SLAVE_WR6 or negedge H1)
begin
	if (!H1)
		H2_Q <= 1'b0;
	else
		H2_Q <= 1'b1;
end

// H3
assign nNMI = ~(H2_Q & NMI_REQ);

// Empty/full flags =============================

// M14
// M11 = SETMASTER01
always @(posedge M11 or negedge G9)
begin
	if (!G9)
		M14_Q <= 1'b0;
	else
		M14_Q <= 1'b1;
end
// G11
// C15 = RESETMASTER01
always @(posedge C15 or negedge M14_Q)
begin
	if (!M14_Q)
		G11_Q <= 1'b0;
	else
		G11_Q <= 1'b1;
end
wire G9 = ~|{RESET, G11_Q};

// L14
// J9 = SETMASTER23
always @(posedge J9 or negedge G10)
begin
	if (!G10)
		L14_Q <= 1'b0;
	else
		L14_Q <= 1'b1;
end
// H10
// B16 = RESETMASTER23
always @(posedge B16 or negedge L14_Q)
begin
	if (!L14_Q)
		H10_Q <= 1'b0;
	else
		H10_Q <= 1'b1;
end
wire G10 = ~|{RESET, H10_Q};

// G8
// B14 = SETSLAVE23
always @(posedge B14 or negedge G6)
begin
	if (!G6)
		G8_Q <= 1'b0;
	else
		G8_Q <= 1'b1;
end
// K9
// L11 = RESETSLAVE23
always @(posedge L11 or negedge G8_Q)
begin
	if (!G8_Q)
		K9_Q <= 1'b0;
	else
		K9_Q <= 1'b1;
end
wire G6 = ~|{RESET, K9_Q};

// H9
// B15 = SETSLAVE01
always @(posedge B15 or negedge G7)
begin
	if (!G7)
		H9_Q <= 1'b0;
	else
		H9_Q <= 1'b1;
end
// J10
// L10 = RESETSLAVE01
always @(posedge L10 or negedge H9_Q)
begin
	if (!H9_Q)
		J10_Q <= 1'b0;
	else
		J10_Q <= 1'b1;
end
wire G7 = ~|{RESET, J10_Q};

// H8
wire NMI_REQ = ~&{~G8_Q, ~H9_Q};

// Slave decode =================================

// M21
always @(negedge nSCS)
	SA0_LATCH <= SA0;

wire J15 = ~|{SA0_LATCH, nSWR, nSCS};
wire G5 = ~|{E4_Q, J15};
// H4
wire SCNT_TICK = ~G5;

wire SLAVE_RWR = ~(SA0_LATCH | G5);	// H6, J8
wire SLAVE_DRD = ~|{~SA0_LATCH, nSRD, nSCS};	// M20
wire SLAVE_DWR = ~|{~SA0_LATCH, nSWR, nSCS};	// M18

wire SLAVE_RD4 = ~&{SLAVE_DRD, SSA2, ~SSA1, ~SSA0};	// L5
wire SLAVE_RD5 = ~&{SLAVE_DRD, SSA2, ~SSA1, SSA0};		// L9
wire SLAVE_WR4 = ~&{SLAVE_DWR, SSA2, ~SSA1, ~SSA0};	// J3
wire SLAVE_WR5 = ~&{SLAVE_DWR, SSA2, ~SSA1, SSA0};		// J4
wire SLAVE_WR6 = ~&{SLAVE_DWR, SSA2, SSA1, ~SSA0};		// J5

wire M9 = ~&{SLAVE_DRD, ~SSA2, ~SSA1, ~SSA0};
wire L10 = ~&{SLAVE_DRD, ~SSA2, ~SSA1, SSA0};
wire L12 = ~&{SLAVE_DRD, ~SSA2, SSA1, ~SSA0};
wire L11 = ~&{SLAVE_DRD, ~SSA2, SSA1, SSA0};
wire SLAVE_MEMRD = ~&{M9, L10, L12, L11};

wire M8 = ~&{SLAVE_DWR, ~SSA2, ~SSA1, ~SSA0};
wire M11 = ~&{SLAVE_DWR, ~SSA2, ~SSA1, SSA0};
wire M10 = ~&{SLAVE_DWR, ~SSA2, SSA1, ~SSA0};
wire J9 = ~&{SLAVE_DWR, ~SSA2, SSA1, SSA0};
wire SLAVE_MEMWR = ~&{M8, M11, M10, J9};

// Slave register index =========================

wire E3 = ~|{SLAVE_MEMRD, SLAVE_MEMWR};
// E4
always @(negedge SCLK or negedge nRESET)
begin
	if (!nRESET)
		E4_Q <= 1'b0;
	else
		E4_Q <= E3;
end

// K5, L6
wire L6 = (~L8_Q & ~SLAVE_RWR) | (SLAVE_RWR & SD_OUT[0]);
// L8
always @(negedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		L8_Q <= 1'b0;
	else
		L8_Q <= L6;
end
wire SSA0 = L8_Q;	// J1

// K7, M6
wire M6 = (~M5_Q & ~SLAVE_RWR & L8_Q) | (SLAVE_RWR & SD_OUT[1]) | (~SLAVE_RWR & ~L8_Q & M5_Q);
// M5
always @(negedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		M5_Q <= 1'b0;
	else
		M5_Q <= M6;
end
// M3
wire SSA1 = M5_Q;

wire L7 = L8_Q & M5_Q;
wire K6 = ~&{L8_Q, M5_Q};

// J6, G3
wire G3 = (~H5_Q & L7 & ~SLAVE_RWR) | (SLAVE_RWR & SD_OUT[2]) | (~SLAVE_RWR & K6 & H5_Q);
// H5
always @(negedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		H5_Q <= 1'b0;
	else
		H5_Q <= G3;
end
// E6
wire SSA2 = H5_Q;

// Master decode ================================

// A23
always @(negedge nMCS)
	MA0_LATCH <= MA0;

wire A22 = ~|{MA0_LATCH, nMWR, nMCS};
wire A7 = ~|{A3_Q, A22};
// A8
wire MCNT_TICK = ~A7;

wire MASTER_RWR = ~(MA0_LATCH | A7);	// A9, F12
wire MASTER_DWR = ~|{~MA0_LATCH, nMWR, nMCS};	// A24
wire MASTER_DRD = ~|{~MA0_LATCH, nMRD, nMCS};	// A25
wire MASTER_RD4 = ~&{MASTER_DRD, MSA2, ~MSA1, ~MSA0};	// A12
wire MASTER_WR4 = ~&{MASTER_DWR, MSA2, ~MSA1, ~MSA0};	// A14

wire B17 = ~&{MASTER_DRD, ~MSA2, ~MSA1, ~MSA0};
wire C15 = ~&{MASTER_DRD, ~MSA2, ~MSA1, MSA0};
wire B13 = ~&{MASTER_DRD, ~MSA2, MSA1, ~MSA0};
wire B16 = ~&{MASTER_DRD, ~MSA2, MSA1, MSA0};
wire MASTER_MEMRD = ~&{B17, C15, B13, B16};

wire A13 = ~&{MASTER_DWR, ~MSA2, ~MSA1, ~MSA0};
wire B15 = ~&{MASTER_DWR, ~MSA2, ~MSA1, MSA0};
wire B12 = ~&{MASTER_DWR, ~MSA2, MSA1, ~MSA0};
wire B14 = ~&{MASTER_DWR, ~MSA2, MSA1, MSA0};
wire MASTER_MEMWR = ~&{A13, B15, B12, B14};

// Master register index ========================

wire C5 = ~|{MASTER_MEMRD, MASTER_MEMWR};
// A3
always @(negedge MCLK or negedge nRESET_BUF)
begin
	if (!nRESET_BUF)
		A3_Q <= 1'b0;
	else
		A3_Q <= C5;
end

// E8, F10
wire F10 = (~F11_Q & ~MASTER_RWR) | (MASTER_RWR & MD_OUT[0]);
// F11
always @(negedge MCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		F11_Q <= 1'b0;
	else
		F11_Q <= F10;
end
// D5
wire MSA0 = F11_Q;

// E7, C12
wire C12 = (~C14_Q & ~MASTER_RWR & F11_Q) | (MASTER_RWR & MD_OUT[1]) | (~MASTER_RWR & ~F11_Q & C14_Q);
// C14
always @(negedge MCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		C14_Q <= 1'b0;
	else
		C14_Q <= C12;
end
// D7
wire MSA1 = C14_Q;

wire D8 = F11_Q & C14_Q;
wire D10 = ~&{F11_Q, C14_Q};

// D9, B10
wire B10 = (~B11_Q & D8 & ~MASTER_RWR) | (MASTER_RWR & MD_OUT[2]) | (~MASTER_RWR & D10 & B11_Q);
// B11
always @(negedge MCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		B11_Q <= 1'b0;
	else
		B11_Q <= B10;
end
// B9
wire MSA2 = B11_Q;

// Data read ====================================

wire [3:0] FLAGS = {L14_Q, M14_Q, G8_Q, H9_Q};

// Slave-to-master ==============================

wire SLAVE_W0 = ~&{SLAVE_MEMWR, ~SSA1, ~SSA0};	// C3
wire SLAVE_W1 = ~&{SLAVE_MEMWR, ~SSA1, SSA0};	// D2
wire SLAVE_W2 = ~&{SLAVE_MEMWR, SSA1, ~SSA0};	// C4
wire SLAVE_W3 = ~&{SLAVE_MEMWR, SSA1, SSA0};		// C6

// C16, A18, C20, D18
always @(negedge SLAVE_W0)
	STM0 <= SD_OUT;
// E10, B20, C21, D17
always @(negedge SLAVE_W1)
	STM1 <= SD_OUT;
// C18, B19, B18, D16
always @(negedge SLAVE_W2)
	STM2 <= SD_OUT;
// D13, A20, C19, E16
always @(negedge SLAVE_W3)
	STM3 <= SD_OUT;

wire MASTER_R0 = MASTER_MEMRD & ~MSA1 & ~MSA0;	// C25
wire MASTER_R1 = MASTER_MEMRD & ~MSA1 & MSA0;	// C23
wire MASTER_R2 = MASTER_MEMRD & MSA1 & ~MSA0;	// C22
wire MASTER_R3 = MASTER_MEMRD & MSA1 & MSA0;		// C24

// D11, D14, D15, E17 
wire [3:0] STM_READ = MASTER_R0 ? STM0 :
			MASTER_R1 ? STM1 :
			MASTER_R2 ? STM2 :
			MASTER_R3 ? STM3 :
			4'b1111;	// Should never happen

wire A21 = nMCS | nMRD;
wire B21 = nMCS | nMWR;

// E9, E12, A19, B22
always @(negedge B21)
	MD_IN_LATCH <= MD;

wire [3:0] MD_OUT = (~MASTER_RD4) ? FLAGS :
			MASTER_MEMRD ? STM_READ :
			A21 ? MD_IN_LATCH :
			4'b0000;	// Should never happen

assign MD = A21 ? 4'bzzzz : MD_OUT;

// Master-to-slave ==============================

wire MASTER_W0 = ~&{MASTER_MEMWR, ~MSA1, ~MSA0};	// C7
wire MASTER_W1 = ~&{MASTER_MEMWR, ~MSA1, MSA0};		// C11
wire MASTER_W2 = ~&{MASTER_MEMWR, MSA1, ~MSA0};		// C8
wire MASTER_W3 = ~&{MASTER_MEMWR, MSA1, MSA0};		// C10

// H15, L17, H17, L21
always @(negedge MASTER_W0)
	MTS0 <= MD_OUT;
// J13, L18, H16, L19
always @(negedge MASTER_W1)
	MTS1 <= MD_OUT;
// H13, L16, G19, L20
always @(negedge MASTER_W2)
	MTS2 <= MD_OUT;
// K14, M15, J16, K15
always @(negedge MASTER_W3)
	MTS3 <= MD_OUT;

wire SLAVE_R0 = SLAVE_MEMRD & ~SSA1 & ~SSA0;	// K1
wire SLAVE_R1 = SLAVE_MEMRD & ~SSA1 & SSA0;	// K2
wire SLAVE_R2 = SLAVE_MEMRD & SSA1 & ~SSA0;	// K4
wire SLAVE_R3 = SLAVE_MEMRD & SSA1 & SSA0;	// K3

// J14, K13, J17, K17
wire [3:0] MTS_READ = SLAVE_R0 ? MTS0 :
			SLAVE_R1 ? MTS1 :
			SLAVE_R2 ? MTS2 :
			SLAVE_R3 ? MTS3 :
			4'b1111;	// Should never happen

wire M19 = nSCS | nSRD;
wire K16 = nSCS | nSWR;

// M13, L15, M16, M17
always @(negedge K16)
	SD_IN_LATCH <= SD;

wire [3:0] SD_OUT = (~SLAVE_RD5) ? {2'b00, IN1, IN0} :
			(~SLAVE_RD4) ? FLAGS :
			SLAVE_MEMRD ? MTS_READ :
			M19 ? SD_IN_LATCH :
			4'b0000;	// Should never happen

assign SD = M19 ? 4'bzzzz : SD_OUT;

endmodule

