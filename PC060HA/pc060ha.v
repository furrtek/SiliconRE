// Taito PC060HA logic def
// Sean 'furrtek' Gonsalves 2019
// GPLV2 - See LICENSE

// THIS IS UNTESTED !
// Fits in a Lattice LC4128ZE

module top(
	input nIC,
	output nROUT,

	input SCLK,
	input nSCS, nSRD, nSWR,
	input SA0,
	inout [3:0] SD,

	input MCLK,
	input nMCS, nMRD, nMWR,
	input MA0,
	inout [3:0] MD,

	input nPG,
	input IN0, IN1,
	output nNMI,
	output reg AMP,
	output PIN17
);

reg A10_nQ;
reg H2_Q;
reg SA0_LATCH, MA0_LATCH;
reg L8_Q, M5_Q, H5_Q;
reg E4_Q;
reg G8_Q, K9_Q, H9_Q, J10_Q;
reg F11_Q, C14_Q, B11_Q;
reg A3_Q;
reg M14_Q, G11_Q, L14_Q, H10_Q;

assign nRESET_BUF = ~nIC;

// A6
wire nRESET = A10_nQ & nRESET_BUF;
assign nROUT = nRESET;

// A10
always @(posedge MASTER_WR4 or negedge nRESET_BUF)
begin
	if (!nRESET_BUF)
		A10_nQ <= 1'b1;
	else
		A10_nQ <= ~MD[0];
end

// G1
always @(posedge SLAVE_WR4 or negedge nROUT)
begin
	if (!nROUT)
		AMP <= 1'b0;
	else
		AMP <= SD[0];
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
assign nNMI = H2_Q & NMI_REQ;

// Flags
// M14
always @(posedge M11 or negedge G9)
begin
	if (!G9)
		M14_Q <= 1'b0;
	else
		M14_Q <= 1'b1;
end
// G11
always @(posedge C15 or negedge M14_Q)
begin
	if (!M14_Q)
		G11_Q <= 1'b0;
	else
		G11_Q <= 1'b1;
end
wire G9 = ~|{~nRESET, G11_Q};

// L14
always @(posedge J9 or negedge G10)
begin
	if (!G10)
		L14_Q <= 1'b0;
	else
		L14_Q <= 1'b1;
end
// H10
always @(posedge B16 or negedge L14_Q)
begin
	if (!L14_Q)
		H10_Q <= 1'b0;
	else
		H10_Q <= 1'b1;
end
wire G10 = ~|{~nRESET, H10_Q};

// H8
wire NMI_REQ = ~G8_Q & ~H9_Q;

// G8
always @(posedge B14 or negedge G6)
begin
	if (!G6)
		G8_Q <= 1'b0;
	else
		G8_Q <= 1'b1;
end
// K9
always @(posedge L11 or negedge G8_Q)
begin
	if (!G8_Q)
		K9_Q <= 1'b0;
	else
		K9_Q <= 1'b1;
end
wire G6 = ~|{~nRESET, K9_Q};

// H9
always @(posedge B15 or negedge G7)
begin
	if (!G7)
		H9_Q <= 1'b0;
	else
		H9_Q <= 1'b1;
end
// J10
always @(posedge L10 or negedge H9_Q)
begin
	if (!H9_Q)
		J10_Q <= 1'b0;
	else
		J10_Q <= 1'b1;
end
wire G7 = ~|{~nRESET, J10_Q};

always @(negedge nSCS)
	SA0_LATCH <= SA0;

wire J15 = ~|{SA0_LATCH, nSWR, nSCS};
wire SLAVE_RWR = ~(SA0_LATCH | G5);
wire SLAVE_DWR = ~|{~SA0_LATCH, nSWR, nSCS};
wire SLAVE_DRD = ~|{~SA0_LATCH, nSRD, nSCS};
wire SLAVE_RD4 = ~&{SLAVE_DRD, SSA2, ~SSA1, ~SSA0};
wire SLAVE_RD5 = ~&{SLAVE_DRD, SSA2, ~SSA1, SSA0};
wire SLAVE_WR4 = ~&{SLAVE_DWR, SSA2, ~SSA1, ~SSA0};
wire SLAVE_WR5 = ~&{SLAVE_DWR, SSA2, ~SSA1, SSA0};
wire SLAVE_WR6 = ~&{SLAVE_DWR, SSA2, SSA1, ~SSA0};

always @(negedge nMCS)
	MA0_LATCH <= MA0;

wire A22 = ~|{MA0_LATCH, nMWR, nMCS};
wire MASTER_RWR = ~(MA0_LATCH | A7);
wire MASTER_DWR = ~|{~MA0_LATCH, nMWR, nMCS};
wire MASTER_DRD = ~|{~MA0_LATCH, nMRD, nMCS};
wire MASTER_RD4 = ~&{MASTER_DRD, MSA2, ~MSA1, ~MSA0};
wire MASTER_WR4 = ~&{MASTER_DWR, MSA2, ~MSA1, ~MSA0};

// Slave register index stuff
// K5, L6
wire L6 = (~L8_Q & ~SLAVE_RWR) | (SLAVE_RWR & SD[0]);
// L8
always @(posedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		L8_Q <= 1'b0;
	else
		L8_Q <= L6;
end
wire SSA0 = L8_Q;

// K7, M6
wire M6 = (~M5_Q & ~SLAVE_RWR & L8_Q) | (SLAVE_RWR & SD[1]) | (~SLAVE_RWR & ~L8_Q & M5_Q);
// M5
always @(posedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		M5_Q <= 1'b0;
	else
		M5_Q <= M6;
end
wire SSA1 = M5_Q;

// J6, G3
wire G3 = (~H5_Q & L7 & ~SLAVE_RWR) | (SLAVE_RWR & SD[2]) | (~SLAVE_RWR & K6 & H5_Q);
// H5
always @(posedge SCNT_TICK or negedge nRESET)
begin
	if (!nRESET)
		H5_Q <= 1'b0;
	else
		H5_Q <= G3;
end
wire SSA2 = H5_Q;

wire L7 = L8_Q & M5_Q;
wire K6 = ~&{L8_Q, M5_Q};


wire RESET_BUF = nIC;



// Master register index stuff
// E8, F10
wire F10 = (~F11_Q & ~MASTER_RWR) | (MASTER_RWR & MD[0]);
// F11
always @(posedge MCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		F11_Q <= 1'b0;
	else
		F11_Q <= F10;
end
wire MSA0 = F11_Q;

// E7, C12
wire C12 = (~C14_Q & ~MASTER_RWR & F11_Q) | (MASTER_RWR & MD[1]) | (~MASTER_RWR & ~F11_Q & C14_Q);
// C14
always @(posedge SCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		C14_Q <= 1'b0;
	else
		C14_Q <= C12;
end
wire MSA1 = C14_Q;

// D9, B10
wire B10 = (~B11_Q & D8 & ~MASTER_RWR) | (MASTER_RWR & MD[2]) | (~MASTER_RWR & D10 & B11_Q);
// B11
always @(posedge SCNT_TICK or negedge RESET_BUF)
begin
	if (!RESET_BUF)
		B11_Q <= 1'b0;
	else
		B11_Q <= B10;
end
wire MSA2 = B11_Q;

wire D8 = F11_Q & C14_Q;
wire D10 = ~&{F11_Q, C14_Q};





wire G5 = ~|{E4_Q, J15};
wire SCNT_TICK = ~G5;

// E4
always @(posedge SCLK or negedge nRESET)
begin
	if (!nRESET)
		E4_Q <= 1'b0;
	else
		E4_Q <= E3;
end

wire E3 = ~|{SLAVE_MEMRD, SLAVE_MEMWR};

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


wire A7 = ~|{A3_Q, A22};
wire MCNT_TICK = ~A7;

// A3
always @(posedge MCLK or negedge nRESET_BUF)
begin
	if (!nRESET_BUF)
		A3_Q <= 1'b0;
	else
		A3_Q <= C5;
end

wire C5 = ~|{MASTER_MEMRD, MASTER_MEMWR};

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


wire [3:0] FLAGS = {L14_Q, M14_Q, G8_Q, H9_Q};

// Slave-to-master
reg [3:0] STM0;
reg [3:0] STM1;
reg [3:0] STM2;
reg [3:0] STM3;

wire SLAVE_W0 = ~&{SLAVE_MEMWR, ~SSA1, ~SSA0};
wire SLAVE_W1 = ~&{SLAVE_MEMWR, ~SSA1, SSA0};
wire SLAVE_W2 = ~&{SLAVE_MEMWR, SSA1, ~SSA0};
wire SLAVE_W3 = ~&{SLAVE_MEMWR, SSA1, SSA0};

always @(negedge SLAVE_W0)
	STM0 <= SD;
always @(negedge SLAVE_W1)
	STM1 <= SD;
always @(negedge SLAVE_W2)
	STM2 <= SD;
always @(negedge SLAVE_W3)
	STM3 <= SD;

wire MASTER_R0 = MASTER_MEMRD & ~MSA1 & ~MSA0;
wire MASTER_R1 = SLAVE_MEMRD & ~MSA1 & MSA0;
wire MASTER_R2 = SLAVE_MEMRD & MSA1 & ~MSA0;
wire MASTER_R3 = SLAVE_MEMRD & MSA1 & MSA0;

wire [3:0] STM_READ = MASTER_R0 ? STM0 :
			MASTER_R1 ? STM1 :
			MASTER_R2 ? STM2 :
			MASTER_R3 ? STM3 :
			4'd0;

wire A21 = nMCS | nMRD;

wire [3:0] MD_MUX = (~MASTER_RD4) ? FLAGS :
			MASTER_MEMRD ? STM_READ :
			A21 ? 4'd0 : 4'd0; 	// ???
assign MD = A21 ? 4'bzzzz : MD_MUX;

// Master-to-slave
reg [3:0] MTS0;
reg [3:0] MTS1;
reg [3:0] MTS2;
reg [3:0] MTS3;

wire MASTER_W0 = ~&{MASTER_MEMWR, ~MSA1, ~MSA0};
wire MASTER_W1 = ~&{MASTER_MEMWR, ~MSA1, MSA0};
wire MASTER_W2 = ~&{MASTER_MEMWR, MSA1, ~MSA0};
wire MASTER_W3 = ~&{MASTER_MEMWR, MSA1, MSA0};

always @(negedge MASTER_W0)
	MTS0 <= MD;
always @(negedge MASTER_W1)
	MTS1 <= MD;
always @(negedge MASTER_W2)
	MTS2 <= MD;
always @(negedge MASTER_W3)
	MTS3 <= MD;

wire SLAVE_R0 = SLAVE_MEMRD & ~SSA1 & ~SSA0;
wire SLAVE_R1 = SLAVE_MEMRD & ~SSA1 & SSA0;
wire SLAVE_R2 = SLAVE_MEMRD & SSA1 & ~SSA0;
wire SLAVE_R3 = SLAVE_MEMRD & SSA1 & SSA0;

wire [3:0] MTS_READ = SLAVE_R0 ? MTS0 :
			SLAVE_R1 ? MTS1 :
			SLAVE_R2 ? MTS2 :
			SLAVE_R3 ? MTS3 :
			4'd0;

wire M19 = nSCS | nSRD;

wire [3:0] SD_MUX = (~SLAVE_RD5) ? {2'b00, IN1, IN0} :
			(~SLAVE_RD4) ? FLAGS :
			MASTER_MEMRD ? MTS_READ :
			M19 ? 4'd0 : 4'd0; 	// ???
assign SD = M19 ? 4'bzzzz : SD_MUX;

endmodule

