// Rawrecord testbench
// Actually not I2S: data isn't shifted one bit related to WS
// See rawrecord.v header for details
// furrtek 2025

`timescale 1ps/1ps
`include "rawrecord.v"
`include "uart.v"
`include "pll_nop.v"

module tb();

reg nreset;
reg clk;
wire [3:0] KEY;
wire [35:0] GPIO_0;
wire [7:0] LEDG;

rawrecord UUT(
    .KEY(KEY),
	.GPIO_0(GPIO_0),
	.LEDG()
);

assign KEY[0] = nreset;

initial begin
	$dumpfile("top.vcd");
	$dumpvars(-1, tb);
end

always @(*)
	#15625 clk <= ~clk;	// 32MHz

integer i, j;

reg [15:0] word;
reg [15:0] read;

//reg [9:0] IIS_clk_div;
reg IIS_SCK_tb;
reg IIS_WS_tb;
reg IIS_SD_tb;

assign GPIO_0[0] = IIS_SCK_tb;
assign GPIO_0[1] = IIS_WS_tb;
assign GPIO_0[2] = IIS_SD_tb;

assign UUT.pll_out = clk;

/*assign IIS_clk_en = (IIS_clk_div == 10'd0);

always @(posedge clk) begin
	// 16M / 48k =~ 333
	if (IIS_clk_div == 10'd333)
		IIS_clk_div <= 10'd0;
	else
        IIS_clk_div <= IIS_clk_div + 1'b1;
end*/

// 32M / 48k / 2 / 16 = 10.4

initial begin
	clk <= 1'b0;
	nreset <= 1'b0;
	#100000 nreset <= 1'b1;

	//IIS_clk_div <= 10'd0;
	IIS_SCK_tb <= 1'b0;
	UUT.prev_channel <= 1'b1;
	IIS_WS_tb <= 1'b1;
	IIS_SD_tb <= 1'b0;
    #100000
	UUT.rst_delay <= 24'd0;	// Can't wait that long

	for (i = 0; i < 16; i = i + 1) begin
		#1 word <= {i[3], 12'd0, i[2:0]};	// I2S

		for (j = 0; j < 16; j = j + 1) begin
			#325520 IIS_SCK_tb <= 1'b0;	// 48kHz * 2 * 16
			if (j == 0)
				IIS_WS_tb <= ~IIS_WS_tb;
			IIS_SD_tb <= word[15];
			word <= {word[14:0], 1'b0};
			#325520 IIS_SCK_tb <= 1'b1;
		end
		//#150 IIS_SCK_tb <= 1'b0;
		//IIS_SD_tb <= 1'b0;

		//reread <= dut.AXD;
		//read <= AXDMUX;
	end

	#20000000 $display("OK");
	$finish;
end

endmodule
