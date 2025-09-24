// Three to eight one-hot decoder

module DEC3(
	input [2:0] in,
	input enable,
	output reg [7:0] out
);

always @(*) begin
	case({enable, in})
    	4'b1000: out <= 8'b11111110;
    	4'b1001: out <= 8'b11111101;
    	4'b1010: out <= 8'b11111011;
    	4'b1011: out <= 8'b11110111;
    	4'b1100: out <= 8'b11101111;
    	4'b1101: out <= 8'b11011111;
    	4'b1110: out <= 8'b10111111;
    	4'b1111: out <= 8'b01111111;
    	default: out <= 8'b11111111;
	endcase
end

endmodule