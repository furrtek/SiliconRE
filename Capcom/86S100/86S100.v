// Capcom 86S100 logic def
// Sean 'furrtek' Gonsalves 2020
// GPLV2 - See LICENSE

// Untested !
// Fits in a Altera EPM7032

module CAPCOM_86S100(
	input MODE,
	input CLK,
	input LOAD,
	input PIN4,
	input PIN5,
	input nEN,
	output PIN7, PIN8, PIN9, PIN10,
	input [7:0] BUS2,	// 11~19
	input [7:0] BUS1	// 20~27
);

reg [3:0] REG2H;	// BERNIE, BRUCE, BRADLEY, BILL
reg [3:0] REG1H;	// ELI, EVAN, ETHAN, EARL
reg [3:0] REG2L;	// DIANE, DAREN, DORIAN, DANNY
reg [3:0] REG1L;	// FELIX, FREDDY, FLORA, FRITZ
wire SEL_A, SEL_B, SEL_C;

wire HFLIP = PIN4 ^ PIN5;

always @(posedge CLK)
begin
	REG2H <= LOAD ? BUS2[7:4] : (HFLIP ? {1'b0, REG2H[3:1]} : {REG2H[2:0], MODE & REG2L[3]});
	REG2L <= LOAD ? BUS2[3:0] : (HFLIP ? {MODE & REG2H[0], REG2L[3:1]} : {REG2L[2:0], 1'b0});
	REG1H <= LOAD ? BUS1[7:4] : (HFLIP ? {1'b0, REG1H[3:1]} : {REG1H[2:0], MODE & REG1L[3]});
	REG1L <= LOAD ? BUS1[3:0] : (HFLIP ? {MODE & REG1H[0], REG1L[3:1]} : {REG1L[2:0], 1'b0});
end

assign {SEL_A, SEL_B, SEL_C} = MODE ? {REG1L[0], REG2H[3], REG2L[0]} : {REG1H[0], REG1L[3], REG1L[0]};

assign {PIN10, PIN9, PIN8, PIN7} = nEN ? 
	4'b0000 : HFLIP ?
		{SEL_A, SEL_C, REG2L[0], REG2H[0]} : {REG1H[3], SEL_B, REG2L[3], REG2H[3]};
		
endmodule
