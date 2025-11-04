// Konami 054539 LFO
// furrtek 2025

module LFO(
	input nRES,
	input [7:0] PIN_DB_IN,
	input nWR,
	input CK,
	input JKCK,
	output reg [7:0] LFO
);

always @(posedge CK or negedge nLFO_RES) begin
	if (!nLFO_RES)
		LFO <= 8'd0;
	else
		LFO <= LFO + {{7{LFO_DEC}}, 1'b1};	// Either +1 or -1
end

reg [7:0] REG21C;	// Or REG223
always @(*) begin
	if (!nWR)
		REG21C <= PIN_DB_IN;
end

reg [7:0] AL29;
always @(posedge CK or negedge nRES) begin
	if (!nRES) begin
		AL29 <= 8'd0;
	end else begin
    	AL29 <= REG21C;
	end
end

assign nLFO_RES = |{AL29};	// AM15
assign AL18 = ~|{LFO[7:0]};
assign COMP = &{~(LFO[7:0] ^ AL29)};

reg LFO_DEC;
always @(posedge JKCK or negedge nRES) begin
	if (!nRES) begin
    	LFO_DEC <= 1'b0;
	end else begin
    	case({COMP, AL18})
        	2'b00: LFO_DEC <= LFO_DEC;
        	2'b01: LFO_DEC <= 1'b0;
        	2'b10: LFO_DEC <= 1'b1;
        	2'b11: LFO_DEC <= ~LFO_DEC;
		endcase
	end
end

endmodule
