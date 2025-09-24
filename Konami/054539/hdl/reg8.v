// Latch-based register

module REG8(
	input nE,
	input [7:0] din,
	output reg [7:0] data
);

initial begin
	data <= 8'd0;
end

always @(*) begin
	if (!nE)
		data <= din;
end

endmodule