// Konami 054000
// furrtek 2022

module k054000_unit(
	input [23:0] VAL_A,
	input [23:0] VAL_B,
	input [7:0] VAL_C,
	input [7:0] VAL_D,
	input [7:0] VAL_E,
	output RESULT
);

wire [23:0] SUM1;
wire [23:0] SUM2;
assign SUM1 = VAL_A + {{16{VAL_E[7]}}, VAL_E};	// Sign-extend VAL_E 
assign SUM2 = SUM1 + ~VAL_B + 1;

assign ONES = ~&{SUM2[22:10]};
assign ZEROES = |{SUM2[22:9]};
assign MSB_CHECK = SUM2[23] ? ONES : ZEROES;

assign MSB = SUM2[23];

// Not exactly a 2's complement conversion ? LSB goes through
wire [8:0] PROCESSED;
wire [8:0] FLIP;
wire [8:1] ANDS;
assign FLIP = SUM2[8:0] ^ {9{MSB}};
assign ANDS[8] = (FLIP[7] & ANDS[7]);
assign ANDS[7] = (FLIP[6] & ANDS[6]);
assign ANDS[6] = (FLIP[5] & ANDS[5]);
assign ANDS[5] = (FLIP[4] & ANDS[4]);
assign ANDS[4] = (FLIP[3] & ANDS[3]);
assign ANDS[3] = (FLIP[2] & ANDS[2]);
assign ANDS[2] = (FLIP[1] & ANDS[1]);
assign ANDS[1] = (FLIP[0] & MSB);

assign PROCESSED[8] = FLIP[8] ^ ANDS[8];
assign PROCESSED[7] = FLIP[7] ^ ANDS[7];
assign PROCESSED[6] = FLIP[6] ^ ANDS[6];
assign PROCESSED[5] = FLIP[5] ^ ANDS[5];
assign PROCESSED[4] = FLIP[4] ^ ANDS[4];
assign PROCESSED[3] = FLIP[3] ^ ANDS[3];
assign PROCESSED[2] = FLIP[2] ^ ANDS[2];
assign PROCESSED[1] = FLIP[1] ^ ANDS[1];
assign PROCESSED[0] = FLIP[0] ^ MSB;

wire [8:0] SUM3;
assign SUM3 = VAL_C + VAL_D;
assign M86B = ~(~SUM3[0] & PROCESSED[0]);
assign M84B = M86B & (PROCESSED[8:1] == SUM3[8:1]);
assign LSB_CHECK = ~(M84B | (PROCESSED[8:1] < SUM3[8:1]));

assign RESULT = MSB_CHECK | LSB_CHECK;

endmodule
