// Toshiba GA cell YFD2
// Positive edge DFF with async clear

module YFD2(
	input CK, D, nCL,
	output reg Q,
	output nQ
);

always @(posedge CK or negedge nCL) begin
	if (!nCL)
		Q <= 1'b0;
	else
		Q <= D;
end

assign nQ = ~Q;

endmodule
