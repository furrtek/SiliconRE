module NANDLATCH(
	input nSET,
	input nRES,
	output reg OUT
);

always @(*) begin
	case({nSET, nRES})
    	2'b00: OUT <= 1'b1;	// Set has priority
    	2'b01: OUT <= 1'b1;	// Normal set
    	2'b10: OUT <= 1'b0;	// Reset
    	2'b11: OUT <= OUT;	// Latch
	endcase
end

endmodule
