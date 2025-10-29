// Konami 054539 comparator section
// furrtek 2025

module comp(
	input nRES,
	input [7:0] PIN_DB_IN,
	input nWR,
	input CK,
	input JKCK,
	input [7:0] ACC,
	output JK_OUT,
	output OR_OUT
);

reg [7:0] REG21C;
always @(*) begin
	if (!nWR)
		REG21C <= ~PIN_DB_IN;
end

reg [7:0] AL29;
always @(posedge CK or negedge nRES) begin
	if (!nRES) begin
		AL29 <= 8'd0;
	end else begin
    	AL29 <= ~REG21C;
	end
end

assign OR_OUT = |{AL29};	// AM15
assign AL18 = ~|{ACC[7:0]};
assign COMP = ~(ACC[7:0] ^ AL29);
assign AL17 = &{COMP};

reg JK_OUT;
always @(posedge JKCK or negedge nRES) begin
	if (!nRES) begin
    	JK_OUT <= 1'b0;
	end else begin
    	case({AL17, AL18})
        	2'b00: JK_OUT <= JK_OUT;
        	2'b01: JK_OUT <= 1'b0;
        	2'b10: JK_OUT <= 1'b1;
        	2'b11: JK_OUT <= ~JK_OUT;
		endcase
	end
end

endmodule
