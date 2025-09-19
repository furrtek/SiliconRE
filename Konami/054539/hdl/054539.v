// Konami 054539
// furrtek 2025

module k054539(
	input NRES,
	input CLK,

	input [7:0] PIN_AB,
	input PIN_AB09,
	input [7:0] PIN_DB_IN,
	input PIN_NCS,
	input PIN_NRD,
	input PIN_NWR,
	output PIN_WAIT,

	output reg PIN_DTCK,
	output reg PIN_WDCK
);

assign nRES = NRES & R131;

assign P30 = nRES & ~&{CLKDIVTHREE, S36};

reg R131 = 0;
always @(posedge CLK) begin
	R131 <= NRES;
end

assign S36 = &{R53, R46};

reg R53 = 0, R46 = 0;
reg [6:0] CLKDIVTHREE = 0;	// 384, 192, 96, 48, 24, 12, 6
reg [8:0] CLKDIV = 0;
reg [8:0] CLKDIVD = 0;		// 512, 256, 128, 64, 32, 16, 8, 4, 2
always @(posedge CLK) begin
	R46 <= ~&{nRES, R46, ~S36};
	R53 <= &{nRES, R46 ^ R53};

	CLKDIVTHREE[0] <= &{P30, CLKDIVTHREE[0] ^ S36};								// R49
	CLKDIVTHREE[1] <= &{P30, ~(CLKDIVTHREE[1] ^ ~&{CLKDIVTHREE[0], S36})};		// R32
	CLKDIVTHREE[2] <= &{P30, ~(CLKDIVTHREE[2] ^ ~&{CLKDIVTHREE[1:0], S36})};	// R44
	CLKDIVTHREE[3] <= &{P30, ~(CLKDIVTHREE[3] ^ ~&{CLKDIVTHREE[2:0], S36})};	// M10
	CLKDIVTHREE[4] <= &{P30, ~(CLKDIVTHREE[4] ^ ~&{CLKDIVTHREE[3:0], S36})};	// P34
	CLKDIVTHREE[5] <= &{P30, ~(CLKDIVTHREE[5] ^ ~&{CLKDIVTHREE[4:0], S36})};	// P40
	CLKDIVTHREE[6] <= &{P30, ~(CLKDIVTHREE[6] ^ ~&{CLKDIVTHREE[5:0], S36})};	// P35

	CLKDIV[0] <= ~(~P30 | CLKDIV[0]);						// K62
	CLKDIV[1] <= &{P30, CLKDIV[1] ^ CLKDIV[0]};				// J76
	CLKDIV[2] <= &{P30, ~(CLKDIV[2] ^ ~&{CLKDIV[1:0]})};	// H74
	CLKDIV[3] <= &{P30, ~(CLKDIV[3] ^ ~&{CLKDIV[2:0]})};	// J82A
	CLKDIV[4] <= &{P30, ~(CLKDIV[4] ^ ~&{CLKDIV[3:0]})};	// J91
	CLKDIV[5] <= &{P30, ~(CLKDIV[5] ^ ~&{CLKDIV[4:0]})};	// J85
	CLKDIV[6] <= &{P30, ~(CLKDIV[6] ^ ~&{CLKDIV[5:0]})};	// K64
	CLKDIV[7] <= &{P30, ~(CLKDIV[7] ^ ~&{CLKDIV[6:0]})};	// K72
	CLKDIV[8] <= &{P30, ~(CLKDIV[8] ^ ~&{CLKDIV[7:0]})};	// K76

	CLKDIVD <= CLKDIV;
end

assign N43 = ~&{CLKDIVD[1], ~CLKDIVD[0]};

// DTS
reg [3:0] P59;
always @(*) begin
	case({CLKDIVD[1], ~CLKDIVD[0]})
    	2'd0: P59 <= 4'b1110;
    	2'd1: P59 <= 4'b1101;
    	2'd2: P59 <= 4'b1011;
    	2'd3: P59 <= 4'b0111;
	endcase
end

// DEBUG
reg PIN_DTS1 = 1;
reg PIN_DTS2 = 0;

reg [3:0] P61;
always @(*) begin
	case({PIN_DTS2, PIN_DTS1})
    	2'd0: P61 <= 4'b1110;
    	2'd1: P61 <= 4'b1101;
    	2'd2: P61 <= 4'b1011;
    	2'd3: P61 <= 4'b0111;
	endcase
end

assign P62 = ~|{~|{P59[0], P61[0]}, ~|{P59[1], P61[1]}, ~|{P59[2], P61[2]}, ~|{P59[3], P61[3]}};
assign P67 = (P62 | ~P69) & R83;

reg N41;
always @(posedge CLK) begin
	N41 <= N43;
end

assign N70 = ~N41;

wire [7:0] RAM_A_DIN;
wire [7:0] RAM_B_DIN;
assign RAM_A_DIN = N70 ? PIN_DB_IN : 8'bzzzzzzzz;
assign RAM_B_DIN = N70 ? PIN_DB_IN : 8'bzzzzzzzz;

// N70=~N41=0: RAM fed by internal data
// N70=~N41=1: RAM fed by CPU data

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

reg P74;
always @(posedge CLK or negedge R86) begin
	if (!R86)
		P74 <= 1'b0;
	else
		P74 <= ~|{P72, N43, P67};
end

reg P72;
always @(posedge P74 or negedge R86) begin
	if (!R86)
		P72 <= 1'b0;
	else
		P72 <= 1'b1;
end

assign P86 = 0;	// DEBUG

assign N45 = P74 & PIN_AB[0];
assign P75A = ~|{~P74, PIN_AB[0]};

assign RAM_A_WR = CLK | ~(N41 ? P86 : N45);
assign RAM_B_WR = CLK | ~(N41 ? P86 : P75A);

wire [6:0] ROMA_D = 7'h2A;

reg [6:0] RAM_A;
always @(posedge CLK) begin
	RAM_A <= (~N43) ? PIN_AB[7:1] : ROMA_D;
end

assign PIN_DTAC = &{R83, ~CPU_REGS};

always @(posedge CLK) begin
	PIN_DTCK <= CLKDIVTHREE[1];
end

reg [2:0] SR_WDCK = 0;
reg [2:0] SR_S1 = 0;
always @(posedge ~CLKDIVD[4]) begin
	SR_WDCK <= {SR_WDCK[1:0], CLKDIVTHREE[5]};
	SR_S1 <= {SR_S1[1:0], CLKDIVTHREE[6]};
end

reg [2:0] SR_S4 = 0;
always @(posedge ~PIN_DTCK) begin
	PIN_WDCK <= SR_WDCK[2];
	SR_S4 <= {SR_S4[1:0], SR_S1[2]};
end

assign PIN_ADDA = 0;	// DEBUG
assign PIN_LRCK = PIN_ADDA ? ~SR_S4[2] : SR_S4[0];

// ----------------

reg TRIGA, TRIGB, TRIGC, TRIGD, TRIGE, TRIGF, TRIGG, TRIGJ, E54, D67;
always @(posedge CLKDIV[0]) begin
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
	case({CLKDIVD[4], CLKDIVD[3]})
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
