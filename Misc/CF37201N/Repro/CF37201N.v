module CF37201N(
	output [7:0] DRAM_Az,	// 
	output PLUSONE,		// 5 pixel pair write offset
	output [4:0] PALz,
	input BLK,
	input H0, nH0,
	input [7:0] DATA,
	input [1:0] A,
	input CS,
	input F,		// 33 frame toggle
	output S,		// 19 pixel pair data invert
	output reg XF, YF,	// 34, 35 H and V flips
	input nnH0,		// 36
	input nPL,
	input nLINE,		// 38
	input PACC,
	output reg PINT
);

assign DRAM_Az = BLK ? DRAM_A : 8'bzzzzzzzz;
assign PALz = PAL_en ? PAL : 5'bzzzzz;

reg PAL_en;
always @(posedge H0) begin
	PAL_en <= ~BLK;
end

// DRAM address is FYYYYYYYYXXXXXXX
// F: Frame parity
// X,Y: Pixel position
// Each location (byte) represents two pixels
// Why are there two buffers (frame parity) if blitting is only possible during blanking ?
// Is it something to do with buffer clearing ?
// Color 7 is behind BG ?
wire [7:0] DRAM_A;
assign DRAM_A = nnH0 ? {F, C1[7:1]} : {C1[0], C2};
assign S = ~((C45A & D40A) | (~C45A & ~D40A));	// 0 if {C45A, D40A} == 11 or 00, actually just an XOR

assign PLUSONE = &{REG1B[0] & BLK & nH0};

always @(*) begin
	if (!nPL)
		{YF, XF} <= ~REG2[7:6];
end

// Function makes sense but cell is weird, might be wrong
// A B C OUT
// x 0 x  0
// 0 1 R  1
// 0 1 x out-1
// 1 x x  0

assign nACK = PACC & ~REG2[5];

// Trigger interrupt if enabled (REG2[5] low) on nPL rising
// Ack with PACC low, or disabling (REG2[5] high)
always @(posedge nPL or negedge nACK) begin
	if (!nACK)
		PINT <= 1'b1;
	else
		PINT <= 1'b0;
end

assign C30A = ~&{~nH0, BLK};
assign CLK1 = nLINE & C30A;
assign CLK2 = C30A;

// Y line counter
reg [7:0] C1;
always @(posedge CLK1 or negedge nPL) begin
	if (!nPL)
		C1 <= REG0;
	else
		C1 <= C1 + 1'b1;
end

// X pixel pair counter
reg [6:0] C2;
assign LINE = ~nLINE;
always @(posedge CLK2 or negedge LINE) begin
	if (!nPL)
		C2 <= REG1B[7:1];
	else
		C2 <= C2 + 1'b1;
end

reg [7:0] REG0;
reg [7:0] REG1;
reg [7:0] REG1B;
reg [7:0] REG2;
always @(*) begin
	case({CS, A})
		3'b000: REG0 <= DATA;
		3'b001: REG1 <= DATA;
		3'b010: REG2 <= DATA;
		default:;
	endcase

	if (!nPL)
		REG1B <= REG1;
end

reg [4:0] PAL;
reg D40A, C45A;
always @(posedge nPL) begin
	PAL <= REG2[4:0];
	D40A <= REG1B[0];
	C45A <= REG2[6];
end

endmodule