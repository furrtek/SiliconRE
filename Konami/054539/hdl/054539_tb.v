// Konami 054539 testbench
// furrtek 2025

// OK: Check that CH0 frac counter works given pitch value
// OK: Check that sample ROM access address is correct
// OK: ROM control signals

// For CH0 (beginning of pulse group), # = 1 clk:
// DTCK ######______######___
// ROCS #######___#####___###
// ROOE ######____####____###
// ROBS ##____####____#######

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
reg PIN_ADDA;
reg PIN_ALRA;
reg PIN_AXDA;
reg PIN_USE2;
reg PIN_DLY;
reg PIN_YMD;

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
	.PIN_AXDT(PIN_AXDT),

	.PIN_RACS(PIN_RACS),
	.PIN_RAWP(PIN_RAWP),
	.PIN_RAOE(PIN_RAOE),

	.PIN_ROCS(PIN_ROCS),
	.PIN_ROOE(PIN_ROOE)
);

wire [7:0] EXTRAM_OUT;
RAM #(8, 8) extram(
	.A(PIN_RA[7:0]),
	.D(PIN_RD_OUT),
	.Q(EXTRAM_OUT),
	.nWR(PIN_RAWP)
);

// ROM data fixed to 0x15 + A DEBUG
wire [7:0] ROM_Q = 8'h15 + PIN_RA[7:0];

assign PIN_RD_IN = (PIN_RACS | PIN_RAOE) ? (PIN_ROCS | PIN_ROOE) ? 8'h00 : ROM_Q : EXTRAM_OUT;	// 00 should be zzzzzzzz but avoids having Xs in IRAM in simulation

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

task read_reg;
input [9:0] address;
begin
    #5 {PIN_AB09, PIN_AB} <= {address[9], address[7:0]};

    #1 NCS <= 1'b0;
    #2 NRD <= 1'b0;
    #15 NRD <= 1'b1;
    #1 NCS <= 1'b1;
end
endtask

always @(*) begin
	#1 CLK <= ~CLK;
end

initial begin
	$dumpfile("k054539.vcd");
	$dumpvars(-1, tb);

	PIN_YMD <= 1'b0;
	PIN_RRMD <= 1'b0;
	PIN_ADDA <= 1'b0;
	PIN_DLY <= 1'b1;
	PIN_USE2 <= 1'b1;
	PIN_DB_IN <= 8'd0;
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

	// Enable ROM readout
	#10	write_reg(10'h22f, 8'b00010000);
	#10	write_reg(10'h22e, 8'h00);	// ROM bank 0

	#20	read_reg(10'h22d);

	// Disable ROM readout, enable PCM
	#10	write_reg(10'h22f, 8'b00000001);

	// Internal RAM write test
	#10	write_reg(10'h50, 8'h11);
	#6	write_reg(10'h51, 8'h22);

	// Set up timer, enable timer and PCM
	#20	write_reg(10'h227, 8'hFC);
	#20	write_reg(10'h22F, 8'b00100001);

	// LFO A
	#20	write_reg(10'h21B, 8'h10);
	#20	write_reg(10'h21C, 8'h15);

	// LFO B
	#20	write_reg(10'h222, 8'h06);
	#20	write_reg(10'h223, 8'h13);

	// Set up channel 0
	#100
	#20 write_reg(10'h0, 8'h87);	// Pitch LSB
	#20 write_reg(10'h1, 8'hA9);	// Pitch mid
	#20 write_reg(10'h2, 8'h00);	// Pitch MSB
	#20 write_reg(10'h3, 8'h00);	// Volume (max)
	#20 write_reg(10'h4, 8'h00);	// Reverb volume (max)
	#20 write_reg(10'h5, 8'h10);	// Pan (center)
	#20 write_reg(10'h6, 8'h00);	// Reverb delay LSB
	#20 write_reg(10'h7, 8'h00);	// Reverb delay MSB
	#20 write_reg(10'h8, 8'h00);	// Loop LSB
	#20 write_reg(10'h9, 8'h00);	// Loop mid
	#20 write_reg(10'hA, 8'h00);	// Loop MSB
	#20 write_reg(10'hB, 8'h00);
	#20 write_reg(10'hC, 8'h00);	// Start LSB
	#20 write_reg(10'hD, 8'h00);	// Start mid
	#20 write_reg(10'hE, 8'h00);	// Start MSB

	#20 write_reg(10'h200, 8'h00);	// Type 0, no reverse
	#20 write_reg(10'h201, 8'h00);	// No loop
	#20 write_reg(10'h214, 8'h01);	// Key on CH0

	#5000 $display("OK");
	$finish;
end

endmodule
