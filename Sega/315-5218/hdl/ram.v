`timescale 1ns/1ns

module ram(
	input [9:0] ADDR,
	inout [7:0] DATA,
	input nOE,
	input nWE
);

	reg [7:0] RAMDATA[0:1024];
	wire [7:0] DATA_OUT;
	
	integer k;
	initial begin
		//Clean init to 0
		for (k = 0; k < 1024; k = k + 1)
			 RAMDATA[k] = 0;
        #1 RAMDATA[1] <= 30;
        RAMDATA[3] <= 2;
        // RAMDATA[128] <= 1;
	end

	assign #1 DATA_OUT = RAMDATA[ADDR];
	assign DATA = (!nOE) ? DATA_OUT : 8'bzzzzzzzz;

	always @(nWE)
		if (!nWE)
			#1 RAMDATA[ADDR] <= DATA;
	
	// DEBUG begin
	always @(nWE or nOE)
		if (!nWE && !nOE)
			$display("ERROR: SRAML: nOE and nWE are both active !");

	//always @(negedge nWE)
	//	$display("Wrote %H to RAM %H", DATA, ADDR);
	// DEBUG end

endmodule
