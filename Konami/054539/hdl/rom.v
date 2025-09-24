module ROM #(parameter ADDR = 0, parameter DATA = 0, parameter FILE = "") (
	input CLK,
	input [ADDR-1:0] A,
	output reg [DATA-1:0] Q
);

reg [DATA-1:0] memory[0:(2**ADDR)-1];

initial begin
	$readmemh(FILE, memory);
end

// Polarity ?
always @(posedge CLK) begin
	Q <= memory[A];
end

endmodule