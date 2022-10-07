// Konami 051316 testbench

`timescale 1ns/1ns
`include "k051316.v"
`include "k051316_ram.v"

module tb(
	);

reg M12, M6;
wire [23:0] CA;
wire [7:0] D;
reg [10:0] A;
reg [7:0] DOUT;
reg RW, IOCS, VRCS;
reg VSCN, HSCN, VRC, HRC;

assign D = RW ? 8'bzzzzzzzz : DOUT;

k051316 UUT(
	M12, M6,
	IOCS, VRCS,
	RW,
	A,
	D,
	VSCN, HSCN, VRC, HRC,
	CA,
	OBLK
);

task setreg;
	input [3:0] addr;
	input [7:0] data;
	begin
		A <= {7'd0, addr};
		DOUT <= data;
		#100
		IOCS <= 1'b0;
		RW <= 1'b0;
		#100
		IOCS <= 1'b1;
		RW <= 1'b1;
		#100
		RW <= 1'b1;
	end
endtask

task setram;
	input [10:0] addr;
	input [7:0] data;
	begin
		A <= addr;
		DOUT <= data;
		#100
		VRCS <= 1'b0;
		RW <= 1'b0;
		#100
		VRCS <= 1'b1;
		RW <= 1'b1;
		#100
		RW <= 1'b1;
	end
endtask

task line;
	input new_VRC;
	begin
	    HSCN <= 1'b0;	// H-blank
	    #500
	    $fwrite(fd, "L\n");
	    VRC <= new_VRC;
	    HRC <= 1'b1;	// H-sync
	    #100
	    HRC <= 1'b0;	// H-sync
	    #100
	    HSCN <= 1'b1;	// H-blank
	    #7000
	    HSCN <= 1'b1;	// H-blank
	end
endtask

always @(posedge M6) begin
	if (HSCN & VSCN)
		$fwrite(fd, "%06x %d\n", CA, OBLK);
end

integer i, fd;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    fd = $fopen("log_video.txt", "w");

    M12 <= 1'b0;
    M6 <= 1'b0;

	DOUT <= 8'd0;
    A <= 11'd0;
    IOCS <= 1'b1;
    VRCS <= 1'b1;
    RW <= 1'b1;

    HSCN <= 1'b0;	// H-blank active low
    HRC <= 1'b0;	// H-sync active high
    VSCN <= 1'b0;	// V-blank active low
    VRC <= 1'b0;	// V-sync active high

    #100

    // Set up registers
    setreg(14, 8'h05);	// Disable ROM reading mode, enable tile y flipping

    setreg(0, 8'h00);	// X start
    setreg(1, 8'h00);
    setreg(2, 8'h08);	// X inc pixel: (0x0800 = 1 pixel)
    setreg(3, 8'h00);
    setreg(4, 8'h01);	// X inc line: (0x0800 = 1 line)
    setreg(5, 8'h00);

    setreg(6, 8'h00);	// Y start
    setreg(7, 8'h00);
    setreg(8, 8'hFE);	// Y inc pixel: (0x0800 = 1 pixel)
    setreg(9, 8'hFF);
    setreg(10, 8'h08);	// Y inc line: (0x0800 = 1 line)
    setreg(11, 8'h00);
    
    // Fill VRAM with tiles 0-1023
    for (i = 0; i < 32*32; i = i + 1) begin
    	setram(i, i[7:0]);
    	setram(i + 1024, i[15:8] + 8'h80);	// Set flip y bit for all tiles
    end

    #100

    VSCN <= 1'b0;	// V-blank start
    #100

	line(0);
	line(0);
	line(0);
	line(1);
	line(1);
	line(1);
	line(0);
	line(0);
	line(0);

    #100
    VSCN <= 1'b1;	// V-blank end

	#100
    for (i = 0; i < 200; i = i + 1) begin
		line(0);
    end

	$finish;
end

always @(*)
    #5 M12 <= ~M12;

always @(negedge M12)
	M6 <= ~M6;

endmodule
