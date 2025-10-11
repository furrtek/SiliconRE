module startstop #(parameter chnum=0) (
	input nRES,
	input CLK,		// Main CLK
	input [7:0] DB_IN,
	input nODDWR,	// Odd channel config register write
	input nKONWR,	// Key ON register write, common
	input nKOFFWR,	// Key OFF register write, common
	input V38A,		// Common to all channels
	input M4,		// Pulses from M5 decoder
	input W17,		// Common to all channels
	output reg CH_ACTIVE,
	output reg nCH_LOOP,
	output reg nODDREG_D4,
	output reg nODDREG_D5,
	output W15,
	output reg W26
);

// For one channel, signal and cell names based on CH0 circuit

always @(posedge CLK or negedge nRES) begin
	if (!nRES)
		W26 <= 1'b0;
	else
		W26 <= &{W9, V23, W23};
end

reg W16;
always @(posedge CLK or negedge nRES) begin
	if (!nRES)
		W16 <= 1'b0;
	else
		W16 <= W22B;
end

assign V23 = ~&{DB_IN[chnum], ~nKOFFWR};
assign W20 = W16 & V23;

reg W21;
always @(posedge nKONWR or negedge W20) begin
	if (!W20)
		W21 <= 1'b0;
	else
		W21 <= DB_IN[chnum] | W21;	// W22A
end

assign W22B = ~&{W21, ~W17};
assign W10 = ~&{W26, W17};
assign W9 = ~&{W22B, W10};

reg V15;
always @(posedge CLK or negedge nRES) begin
	if (!nRES)
		CH_ACTIVE <= 1'b0;
	else
		CH_ACTIVE <= &{W9 | CH_ACTIVE, V23, W23};	// V16A
end

reg nODDREG_D2;
always @(*) begin
	if (!nODDWR) begin
		nODDREG_D2 <= ~DB_IN[2];
		nODDREG_D4 <= ~DB_IN[4];
		nODDREG_D5 <= ~DB_IN[5];
	end
end

always @(posedge nODDWR) begin
	nCH_LOOP <= ~DB_IN[0];
end

reg W15;
always @(posedge M4 or negedge W16) begin
	if (!W16)
		W15 <= 1'b1;
	else
		W15 <= V38A;
end

assign W13 = W16 & ~nCH_LOOP;

reg W14;
always @(posedge W15 or negedge W13) begin
	if (!W13)
		W14 <= 1'b0;
	else
		W14 <= 1'b1;
end

assign W23 = W21 | nCH_LOOP | ~&{~W15, ~&{~W14, nODDREG_D2}};

endmodule
