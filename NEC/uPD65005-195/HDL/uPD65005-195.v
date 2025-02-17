// NEC uPD65005-195 PC-Engine multitap
// Based on silicon
// 2023 Sean Gonsalves

module uPD65005_195(
	input CLR, SEL,
	output reg [3:0] D_OUT,
	input [3:0] P1_D,
	output P1_CLR, P1_SEL,
	input [3:0] P2_D,
	output P2_CLR, P2_SEL,
	input [3:0] P3_D,
	output P3_CLR, P3_SEL,
	input [3:0] P4_D,
	output P4_CLR, P4_SEL,
	input [3:0] P5_D,
	output P5_CLR, P5_SEL
);

reg E3_Q;
always @(posedge SEL or posedge CLR) begin
	if (CLR)
		E3_Q <= 1'b0;
	else
		E3_Q <= 1'b1;
end

reg F7_Q;
always @(negedge SEL or posedge CLR) begin
	if (CLR)
		F7_Q <= 1'b0;
	else
		F7_Q <= E3_Q;
end

reg [3:0] E11_Q;
always @(posedge SEL or posedge CLR) begin
	if (CLR) begin
		E11_Q <= 4'b0000;
	end else begin
		E11_Q <= {E11_Q[2:0], ~F7_Q};
	end
end

assign {P5_CLR, P4_CLR, P3_CLR, P2_CLR, P1_CLR} = {~E11_Q, E3_Q};

assign {P5_SEL, P4_SEL, P3_SEL, P2_SEL, P1_SEL} = ~({E11_Q, ~E3_Q} & {5{~SEL}});

always @(*) begin
	case({E11_Q, ~E3_Q})
    	5'b00001: D_OUT <= P1_D;
    	5'b00010: D_OUT <= P2_D;
    	5'b00100: D_OUT <= P3_D;
    	5'b01000: D_OUT <= P4_D;
    	5'b10000: D_OUT <= P5_D;
    	default: D_OUT <= 5'bx;		// Should never happen
	endcase
end

endmodule
