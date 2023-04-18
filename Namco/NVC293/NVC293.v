// Namco NVC293
// furrtek 2023

module NVC293(
	input clk,
	input [5:0] din,
	output [5:0] dout,
	input [1:0] sel,
	input delay
);

wire [5:0] muxed;
reg [5:0] muxed_reg;
reg [5:0] stage [0:2];

assign muxed = (sel == 2'd0) ? din : (sel == 2'd1) ? stage[0] : (sel == 2'd2) ? stage[1] : stage[2];
assign dout = delay ? muxed_reg : muxed;

always @(posedge clk) begin
	stage[0] <= din;
	stage[1] <= stage[0];
	stage[2] <= stage[1];
	muxed_reg <= muxed;
end

endmodule
