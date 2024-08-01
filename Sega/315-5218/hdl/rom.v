`timescale 1ns/1ns

module rom(
	input [15:0] ADDR,
	output [7:0] DATA,
	input nOE
);

	reg [7:0] ROMDATA[0:65535];
	wire [7:0] DATA_OUT;

	integer k;
	initial begin
		//Clean init to 0 since the speed-patched system ROM skips SRAM init
		//for (k = 0; k < 32767; k = k + 1)
		//	 RAMDATA[k] = 0;
		$readmemh("sharrier.txt", ROMDATA);
	end

	assign #1 DATA_OUT = ROMDATA[ADDR];
	assign DATA = (!nOE) ? DATA_OUT : 8'bzzzzzzzz;

endmodule
