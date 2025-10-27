// Two to four one-hot decoder

module DEC2(
	input [1:0] in, 	// {B, A}
	output reg [3:0] out
);

always @(*) begin
	case(in)
    	2'd0: out <= 4'b1110;
    	2'd1: out <= 4'b1101;
    	2'd2: out <= 4'b1011;
    	2'd3: out <= 4'b0111;
	endcase
end

endmodule