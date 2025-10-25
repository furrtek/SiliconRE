// Konami 054539 testbench
// furrtek 2025

`include "auxin.v"

module tb();

reg PIN_AXXA;
reg AXDA_SYNC;
reg PIN_YMD;
wire [15:0] AXDMUX;

integer i, j;

auxin dut(
	PIN_AXXA,
	AXDA_SYNC,
	PIN_YMD,
	AXDMUX
);

/*always @(*) begin
	#1 CLK <= ~CLK;
end*/

reg [15:0] word;
reg [15:0] read;
reg [15:0] reread;

parameter MAX = 2 ** 13;	//2 ** 16;

initial begin
	$dumpfile("auxin.vcd");
	$dumpvars(-1, tb);

	PIN_YMD <= 1'b1;

	PIN_AXXA <= 1'b0;
	AXDA_SYNC <= 1'b0;
    #10

	for (i = 0; i < MAX; i = i + 1) begin
		//#5 word <= i;	// I2S
		#5 word <= {3'd0, i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], i[9], i[10], i[11], i[12]};	// YM
		for (j = 0; j < 16; j = j + 1) begin
			#1 PIN_AXXA <= 1'b0;
			AXDA_SYNC <= word[15];
			word <= {word[14:0], 1'b0};
			#1 PIN_AXXA <= 1'b1;
		end
		#1 PIN_AXXA <= 1'b0;
		AXDA_SYNC <= 1'b0;

		reread <= dut.AXD;
		read <= AXDMUX;
	end

	#2000 $display("OK");
	$finish;
end

endmodule
