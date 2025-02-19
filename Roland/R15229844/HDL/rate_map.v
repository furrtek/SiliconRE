module RATEMAP(
	input [7:0] REG_RATE,
	output [14:0] RATE_TR
);

// Translates the 8-bit rate range to a 15-bit range made of 3 linear parts
// (1st quarter, 2nd quarter, 2nd half)

// REG_RATE	RATE_TR
// 00~3F		7FFF~7FC0  -1
// 40~7F		7FBF~7BCF  -10
// 80~FF		7BFF~3C7F  -80

// There's a glitch between the 2nd and 3rd parts, between REG_RATE 7F (output 7BCF) and 80 (output 7BFF)
// It would disappear if RATE_TR[6] was forced low after the 2nd section (REG_RATE[7] high)
// Is it a RE error, or does the chip behave like that ?

assign K99 = ~|{&{~REG_RATE[7], REG_RATE[6], REG_RATE[2]}, REG_RATE[7]};
assign K78 = REG_RATE[3] ? K99 : ~K99;

assign K77 = ~|{K99, ~REG_RATE[3]};
assign K82 = REG_RATE[4] ? ~K77 : K77;

assign K84 = ~|{~K77, ~REG_RATE[4]};
assign J89 = REG_RATE[5] ? ~K84 : K84;

assign J88 = ~|{~K84, ~REG_RATE[5]};
assign J85 = REG_RATE[6] ? ~J88 : J88;

assign J74 = ~|{~J88, ~REG_RATE[6]};

assign G103 = ~&{~G104, REG_RATE[2]};

assign G101 = ~|{~G104 & G103, G103 & REG_RATE[2]};

assign G104 = &{~REG_RATE[7], REG_RATE[6]};	// High during 2nd part
assign K101 = ~|{REG_RATE[7:6]};			// High during 1st part

assign RATE_TR[14] = ~&{REG_RATE[7], J74};
assign RATE_TR[13] = ~&{REG_RATE[7], J85};
assign RATE_TR[12] = ~&{REG_RATE[7], J89};
assign RATE_TR[11] = ~&{REG_RATE[7], K82};
assign RATE_TR[10] = ~|{J88 & G104, K78 & REG_RATE[7]};
assign RATE_TR[9] = ~|{J89 & G104, G101 & REG_RATE[7]};
assign RATE_TR[8] = ~|{K82 & G104, REG_RATE[1] & REG_RATE[7]};
assign RATE_TR[7] = ~|{K78 & G104, REG_RATE[0] & REG_RATE[7]};

//assign RATE_TR[6] = REG_RATE[7] ? 1'b0 : ~&{~J91, G101};
assign RATE_TR[6] = ~&{G104, G101};
assign RATE_TR[5] = ~|{J89 & K101, REG_RATE[1] & G104};
assign RATE_TR[4] = ~|{K82 & K101, REG_RATE[0] & G104};
assign RATE_TR[3] = ~&{K101, K78};
assign RATE_TR[2] = ~&{K101, G101};
assign RATE_TR[1] = ~&{K101, REG_RATE[1]};
assign RATE_TR[0] = ~&{K101, REG_RATE[0]};

endmodule
