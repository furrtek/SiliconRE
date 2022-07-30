// Konami 054000
// furrtek 2022

`include "k054000_unit.v"

module k054000(
	inout [7:0] D,
	input [5:1] A,
	input P20,	// Control signals mode
	input P22,	// R/W
	input P26,	// CS
	input P27	// NWR
);

// These are all transparent latches
reg [7:0] REG1;
reg [7:0] REG2;
reg [7:0] REG3;
reg [7:0] REG4;
reg [7:0] REG6;
reg [7:0] REG7;

reg [7:0] REG9;
reg [7:0] REGA;
reg [7:0] REGB;
reg [7:0] REGC;
reg [7:0] REGE;
reg [7:0] REGF;

reg [7:0] REG11;
reg [7:0] REG12;
reg [7:0] REG13;
reg [7:0] REG15;
reg [7:0] REG16;
reg [7:0] REG17;

assign L74A = P27 | ~P26;
assign {WREN, RDEN} = P20 ? {L74A, ~P26} : {P22, P22};

always @(*) begin
	if (!WREN) begin
		case(A[5:1])
			5'h1: REG1 <= D;
			5'h2: REG2 <= D;
			5'h3: REG3 <= D;
			5'h4: REG4 <= D;
			5'h6: REG6 <= D;
			5'h7: REG7 <= D;
	
			5'h9: REG9 <= D;
			5'hA: REGA <= D;
			5'hB: REGB <= D;
			5'hC: REGC <= D;
			5'hE: REGE <= D;
			5'hF: REGF <= D;
	
			5'h11: REG11 <= D;
			5'h12: REG12 <= D;
			5'h13: REG13 <= D;
			5'h15: REG15 <= D;
			5'h16: REG16 <= D;
			5'h17: REG17 <= D;
			default: begin
				$display("Write to unmapped register !");
			end
		endcase
	end
end

k054000_unit UNIT_X(
	.VAL_A({REG1, REG2, REG3}),
	.VAL_E(REG4),
	.VAL_B({REG15, REG16, REG17}),
	.VAL_C(REGE),
	.VAL_D(REG6),
	.RESULT(RESULT_X)
);

k054000_unit UNIT_Y(
	.VAL_A({REG9, REGA, REGB}),
	.VAL_E(REGC),
	.VAL_B({REG11, REG12, REG13}),
	.VAL_C(REGF),
	.VAL_D(REG7),
	.RESULT(RESULT_Y)
);

assign DOUT = RESULT_Y | RESULT_X;

assign D0DIR = (A[5:4] != 2'd3) | RDEN;
assign D[0] = D0DIR ? 1'bz : DOUT;
assign D[7:1] = 7'bzzzz_zzz;

endmodule
