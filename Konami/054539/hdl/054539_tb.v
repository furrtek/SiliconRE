// Konami 054539 testbench
// furrtek 2025

`include "054539.v"

module tb();

reg CLK;
reg NRES;
reg [7:0] PIN_AB;
reg PIN_AB09;
reg [7:0] PIN_DB_IN;
wire [7:0] PIN_DB_OUT;
reg NCS;
reg NRD;
reg NWR;
reg PIN_DTS1;
reg PIN_DTS2;
wire [23:0] PIN_RA;
wire [7:0] PIN_RD_IN;
wire [7:0] PIN_RD_OUT;
reg PIN_RRMD;
reg PIN_ALRA;
reg PIN_AXDA;
reg PIN_USE2;

integer i;

k054539 dut(
	.NRES(NRES),
	.CLK(CLK),
	.PIN_AB(PIN_AB),
	.PIN_AB09(PIN_AB09),
	.PIN_DB_IN(PIN_DB_IN),
	.PIN_DB_OUT(PIN_DB_OUT),
	.PIN_NCS(NCS),
	.PIN_NRD(NRD),
	.PIN_NWR(NWR),
	.PIN_WAIT(PIN_WAIT),
	.PIN_DTCK(PIN_DTCK),
	.PIN_WDCK(PIN_WDCK),
	.PIN_DTS1(PIN_DTS1),
	.PIN_DTS2(PIN_DTS2),
	.PIN_RA(PIN_RA),
	.PIN_RD_IN(PIN_RD_IN),
	.PIN_RD_OUT(PIN_RD_OUT),
	.PIN_TIM(PIN_TIM),
	.PIN_RRMD(PIN_RRMD),
	.PIN_DLY(PIN_DLY),
	.PIN_AXDA(PIN_AXDA),
	.PIN_ALRA(PIN_ALRA),
	.PIN_USE2(PIN_USE2),
	.PIN_YMD(PIN_YMD),
	.PIN_AXXA(PIN_AXXA),
	.PIN_AXWA(PIN_AXWA),
	.PIN_ADDA(PIN_ADDA),
	.PIN_FRDL(PIN_FRDL),
	.PIN_FRDT(PIN_FRDT),
	.PIN_REDL(PIN_REDL),
	.PIN_REDT(PIN_REDT),
	.PIN_AXDT(PIN_AXDT)
);

task write_reg;
input [9:0] address;
input [7:0] data;
begin
    #5 PIN_DB_IN <= data;
    {PIN_AB09, PIN_AB} <= {address[9], address[7:0]};

    #1 NCS <= 1'b0;
    #2 NWR <= 1'b0;
    #15 NWR <= 1'b1;
    #1 NCS <= 1'b1;
end
endtask

always @(*) begin
	#1 CLK <= ~CLK;
end

initial begin
	$dumpfile("k054539.vcd");
	$dumpvars(-1, tb);

	PIN_DTS1 <= 1'b1;
	PIN_DTS2 <= 1'b0;
	NCS <= 1'b1;
	NRD <= 1'b1;
	NWR <= 1'b1;
	CLK <= 1'b0;
    NRES <= 1'b0;
	PIN_AB09 <= 1'b0;
	PIN_AB <= 8'd0;
    #10 NRES <= 1'b1;

	#10	write_reg(10'h50, 8'h11);
	#8	write_reg(10'h51, 8'h22);
	#20	write_reg(10'h210, 8'h55);

	#2000 $display("OK");
	$finish;
end

endmodule
