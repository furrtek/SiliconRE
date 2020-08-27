module tb(
);

	wire [16:0] SA;
	reg [3:0] AB;
	reg CLK, NRES, NRCS, DACS, NRD;
	reg [7:0] DB;
	wire [6:0] ASD;
	wire [6:0] BSD;
	reg [7:0] RAM;

	wire [7:0] DB_2 = DB;
	wire [7:0] RAM_2 = RAM;
	
	k007232 UUT(
		CLK,
		NRES,
		NRCS, DACS, NRD,
		AB,
		NO, NE,
		DB_2, RAM_2,
		SA,
		ASD, BSD,
		CK2M, SOEV
	);

	initial begin
		CLK <= 0;
		NRCS <= 1;
		DACS <= 1;
		NRD <= 0;
		NRES <= 0;
		AB <= 4'b0000;
		
		#10 NRES <= 1;
		
		// Test SOEV
		#10 AB <= 4'b1101;	// Reg 12
		DACS <= 0;
		#10 DACS <= 1;
		
		// Set up Channel 1
		#10 AB <= 4'b0001;	// Reg 0
		DB <= 8'b11111000;
		DACS <= 0;
		#10 DACS <= 1;
		
		AB <= 4'b0000;	// Reg 1
		DB <= 8'b00001111;
		DACS <= 0;
		#10 DACS <= 1;
		
		#10 AB <= 4'b0011;	// Reg 2
		DB <= 8'b00000000;
		DACS <= 0;
		#10 DACS <= 1;
		#10 AB <= 4'b0010;	// Reg 3
		DB <= 8'b00000000;
		DACS <= 0;
		#10 DACS <= 1;
		#10 AB <= 4'b0101;	// Reg 4
		DB <= 8'b00000000;
		DACS <= 0;
		#10 DACS <= 1;
		
		#10 AB <= 4'b1100;	// Reg 13
		DB <= 8'b00000001;
		DACS <= 0;
		#10 DACS <= 1;
		
		#10 AB <= 4'b0100;	// Reg 5
		DB <= 8'b00000000;
		DACS <= 0;
		#10 DACS <= 1;
	end

	always
		#4 CLK <= ~CLK;
	
	always @(*) begin
		case(SA)
			17'h00000: RAM <= 8'h01;
			17'h00001: RAM <= 8'h23;
			17'h00002: RAM <= 8'h45;
			17'h00003: RAM <= 8'h67;
			17'h00004: RAM <= 8'h76;
			17'h00005: RAM <= 8'h54;
			17'h00006: RAM <= 8'h32;
			17'h00007: RAM <= 8'h10;
			17'h00008: RAM <= 8'h00;
			default: RAM <= 8'hFF;
		endcase
	end
	
endmodule
