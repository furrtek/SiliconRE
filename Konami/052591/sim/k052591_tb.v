// Konami 052591 PMC
// 2023 furrtek
// Testbench

`timescale 1ns/1ns
`include "k052591.v"

module tb();

reg pin_M12;
reg pin_RST;
reg pin_CS;
reg pin_NRD;
reg pin_START;
reg pin_BK;
reg PIN21;
reg [12:0] pin_AB;
wire [7:0] pin_DB;
reg [7:0] DB_wr;
wire [12:0] pin_EA;
wire [7:0] pin_ED;
wire pin_OUT0;

k052591 dut(
	pin_M12,
	pin_RST,

	pin_CS,
	pin_NRD,
	pin_START,
	pin_BK,
	pin_OUT0,

	pin_AB,
	pin_DB,

	pin_EA,
	pin_ED,
	pin_ERCS,
	pin_EROE,
	pin_ERWE,
	
	PIN21
);

assign pin_DB = DB_wr;
assign pin_ED = ~|{pin_ERCS, pin_EROE} ? ED_out : 8'bzzzzzzzz;

always #1 if (init_done) pin_M12 <= ~pin_M12;

initial begin
	$dumpfile("tb.vcd");
	$dumpvars(-1, tb);
end

task program_write;
	input [7:0] byte;
	begin
		#2 pin_NRD <= 1'b1;
		pin_AB <= 13'h0;
		pin_BK <= 1'b0;
		DB_wr <= byte;
		#4 pin_CS <= 1'b0;
		#4 pin_CS <= 1'b1;
	end
endtask

task extram_write;
	input [12:0] address;
	input [7:0] byte;
	begin
		#2 pin_NRD <= 1'b1;
		pin_AB <= address;
		pin_BK <= 1'b1;
		DB_wr <= byte;
		#4 pin_CS <= 1'b0;
		#4 pin_CS <= 1'b1;
	end
endtask

integer f_prg, r, b;
reg [7:0] byte;
reg [7:0] ED_out;
reg [7:0] extram [0:8191];
reg init_done;

always @(*) begin
	if (~|{pin_ERCS, pin_ERWE})
		extram[pin_EA] <= pin_ED;
	ED_out <= extram[pin_EA];
end

initial begin
	init_done <= 1'b0;
	for (b = 0; b < 62; b = b + 1)
		dut.iram[b] <= 36'h00000;
		
	#100
	init_done <= 1'b1;

	pin_M12 <= 1'b0;
	pin_RST <= 1'b0;
	pin_CS <= 1'b1;
	pin_NRD <= 1'b0;
	pin_START <= 1'b0;
	pin_BK <= 1'b0;
	PIN21 <= 1'b0;
	pin_AB <= 13'h0;

	#10 pin_RST <= 1'b1;

	// Clear RESET_PC, allows iram_a auto-increment
	#2 pin_NRD <= 1'b1;
	pin_AB <= 13'h200;
	pin_BK <= 1'b0;
	DB_wr <= 8'h00;
	#4 pin_CS <= 1'b0;
	#4 pin_CS <= 1'b1;

	$display("Loading program to iram");
	f_prg = $fopen("thunderxa.bin", "rb");
	for (b = 0; b < 320; b = b + 1) begin
	r = $fread(byte, f_prg);
		program_write(byte);
	end

	#50
	// Set RESET_PC, set initial PC to 1
	#2 pin_NRD <= 1'b1;
	pin_AB <= 13'h200;
	pin_BK <= 1'b0;
	DB_wr <= 8'h81;
	#4 pin_CS <= 1'b0;
	#4 pin_CS <= 1'b1;

	$display("Loading data to extram");
	f_prg = $fopen("extram.bin", "rb");
	for (b = 0; b < 8192; b = b + 1) begin
	r = $fread(byte, f_prg);
		extram_write(b, byte);
	end

	#50
	pin_START <= 1'b1;
	
	// Wait for program done
	@(negedge pin_OUT0)

	#100 $finish;
end

endmodule
