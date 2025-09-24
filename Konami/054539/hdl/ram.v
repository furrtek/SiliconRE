module RAM #(parameter ADDR = 0, parameter DATA = 0) (
	input [ADDR-1:0] A,
	input [DATA-1:0] D,
	output reg [DATA-1:0] Q,
	input nWR
);

reg [DATA-1:0] memory[0:(2**ADDR)-1];

integer c;

initial begin
	for (c = 0; c < (2**ADDR); c = c + 1)
		memory[c] <= 0;
end

always @(*) begin
	if (!nWR)
		memory[A] <= D;
	Q <= memory[A];
end

endmodule