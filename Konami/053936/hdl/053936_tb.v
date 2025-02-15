// Konami 053936 testbench
// furrtek 2024

// 070225: Basic functions and window look ok. Pixel and line counter offset untested. Auto RAM update untested.

`include "053936.v"

module tb();

reg [15:0] D;
reg [3:0] A;
reg NUCS, NLCS, NWCS;
wire [2:0] LH;
wire [8:0] LA;
wire [12:0] X;
wire [12:0] Y;
reg HSYNC, VSYNC;
reg N16_8;
reg CLK;
reg CLK_RUN;
reg NDTACK;
wire NOB, XH, YH;

integer i, fd;

k053936 dut(
	CLK,
	D, A, N16_8,

	HSYNC, VSYNC,
	NUCS, NLCS, NWCS,
	
	NDMA,
	NDTACK,
	
	1'b0, LH, LA,

	1'b0, X, XH, Y, YH, NOB
);

task write_reg;
input [3:0] address;
input [15:0] data;
begin
    #5 D <= data;
    A <= address;

    #1 NLCS <= 1'b0;
    NUCS <= 1'b0;
    #1 NWCS <= 1'b0;

    #1 NWCS <= 1'b1;
	NLCS <= 1'b1;
    NUCS <= 1'b1;
end
endtask

task line;
	input new_VSYNC;
	begin
	    VSYNC <= new_VSYNC;
	    HSYNC <= 1'b1;
	    #60
	    HSYNC <= 1'b0;
	    $fwrite(fd, "L\n");	// Write new line marker
	    #708
	    HSYNC <= 1'b0;
	    //$display("Line %d", dut.V);
	end
endtask

always @(posedge CLK) begin
	$fwrite(fd, "%04x %04x %d\n", {X, XH}, {Y, YH}, NOB);	// Write pixel coordinates and OOB flag
end

always @(*) begin
	if (CLK_RUN)
		#1 CLK <= ~CLK;
end

initial begin
	$dumpfile("k053936.vcd");
	$dumpvars(-1, tb);

    fd = $fopen("log_video.txt", "w");

    NWCS <= 1'b1;
	NLCS <= 1'b1;
    NUCS <= 1'b1;
    HSYNC <= 1'b0;
    VSYNC <= 1'b0;
    NDTACK <= 1'b0;
    N16_8 <= 1'b0;	// 16-bit mode ?
	D <= 16'h0000;
	A <= 4'h0;
	CLK_RUN <= 1'b1;
	CLK <= 1'b0;

	#10
	// D6 must be cleared otherwise regs 2, 3, 4 and 5 can't be written to
	//write_reg(4'd7, 	16'b000000000_00000_00);	// Layer disabled
	//write_reg(4'd7, 	16'b000000000_01100_00);	// Layer enabled, no window
	write_reg(4'd7, 	16'b000000000_01000_00);	// Layer enabled, window
	//write_reg(4'd7, 	16'b000000000_01010_00);	// Layer enabled, inverted window
	//write_reg(4'd7, 	16'b000000000_11100_00);	// Layer enabled, no window, auto register update

	write_reg(4'd0, 	16'h0000);	// X start MSBs
	write_reg(4'd1, 	16'h0000);	// Y start MSBs
	write_reg(4'd2, 	16'h0000);	// X add after line
	write_reg(4'd3, 	16'h0400);	// Y add after line
	write_reg(4'd4, 	16'h0400);	// X add after pixel
	write_reg(4'd5, 	16'h0000);	// Y add after pixel
	write_reg(4'd6, 	16'b00_1_11111_00_1_11111);	// Configuration
	write_reg(4'd8, 	16'h0020);	// Window X min
	write_reg(4'd9, 	16'h0080);	// Window X max
	write_reg(4'd10, 	16'h0005);	// Window Y min
	write_reg(4'd11, 	16'h0111);	// Window Y max
	write_reg(4'd12, 	16'h0000);	// Pixel counter start
	write_reg(4'd13, 	16'h0000);	// Line counter start
	write_reg(4'd14, 	16'h0000);	// RAM offset

	// 111111	No OOB, full 16384 range
	// 101111	OOB when MSBs are 10 or 01 (in -8192~-4097 or 4096~8191)
	// 100111	OOB when MSBs are 1x0 or 0x1 (in -8192~-2049 or 2048~8191)
	// 100011	OOB when MSBs are 1xx0 or 0xx1 (in -8192~-1025 or 1024~8191)
	// 100001	OOB when MSBs are 1xxx0 or 0xxx1 (in -8192~-513 or 512~8191)
	// 100000	OOB when MSBs are 1xxxx0 or 0xxxx1 (in -8192~-257 or 256~8191)
	// Top mask bit set = consider position as signed

	// 111111	No OOB, full 16384 range
	// 011111	OOB when MSB is 1 (8192+)
	// 001111	OOB when MSB is 1, or MSB-1 is 1 (4096+)
	// 000111	OOB when MSB is 1, or MSB-1 is 1, or MSB-2 is 1 (2048+)
	// 000011	OOB when MSB is 1, or MSB-1 is 1, or MSB-2 is 1, or MSB-3 is 1 (1024+)
	// 000001	OOB when MSB is 1, or MSB-1 is 1, or MSB-2 is 1, or MSB-3 is 1, or MSB-4 is 1 (512+)
	// 000000	OOB when MSB is 1, or MSB-1 is 1, or MSB-2 is 1, or MSB-3 is 1, or MSB-4 is 1, or MSB-5 is 1 (256+)

	line(0);
	line(0);
	line(0);
	line(1);	// VSYNC
	line(1);
	line(1);
	line(0);
	line(0);
	line(0);

    for (i = 0; i < 100; i = i + 1) begin
	    $display("Line %d", i);
		line(0);
    end

	$display("OK");
	$finish;
end

endmodule
