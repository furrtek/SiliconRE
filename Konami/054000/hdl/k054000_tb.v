// Konami 054000 testbench
// furrtek 2022

`include "k054000.v"

module tb();

reg [7:0] D;
wire [7:0] D_bidir;
reg [5:1] A;
reg P20, P22, P26, P27;
integer i;

k054000 dut(
	D_bidir, A,
	P20, P22, P26, P27
);

assign D_bidir = (P26 & ~P27) ? D : 8'bzzzz_zzzz;

initial begin
	$dumpfile("k054000.vcd");
	$dumpvars(-1, dut);
end

task write_reg;
input [5:0] address;
input [7:0] data;
begin
    D <= data;
    A <= address[5:1];
    #20 P26 <= 1'b1;	// CS
    #1 P27 <= 1'b0;		// NWR
    #10 P27 <= 1'b1;
    #1 P26 <= 1'b0;
end
endtask

task check;
input [7:0] number;
input value;
begin
    D <= 8'h00;
    A <= 5'h18;
    #20 P26 <= 1'b1;	// CS
    #1 P27 <= 1'b1;		// NWR
    if (D_bidir[0] != value) begin
    	$display("FAILED Thunder Cross 2 test #%d", number);
    	$finish;
    end
    #1 P26 <= 1'b0;
end
endtask

initial begin
	D = 8'h00;
	A = 5'h0;
	P20 <= 1;
	P22 <= 0;
	P26 <= 0;
	P27 <= 1;

	// Thunder Cross 2 performs these tests (see notes.txt)
	write_reg(6'h3, 8'h00);
	write_reg(6'h5, 8'h00);
	write_reg(6'h7, 8'h00);
	write_reg(6'h9, 8'h00);
	write_reg(6'hD, 8'h00);
	write_reg(6'hF, 8'h00);
	write_reg(6'h13, 8'h00);
	write_reg(6'h15, 8'h00);
	write_reg(6'h17, 8'h00);
	write_reg(6'h19, 8'h00);
	write_reg(6'h1D, 8'h00);
	write_reg(6'h1F, 8'h00);
	write_reg(6'h23, 8'h00);
	write_reg(6'h25, 8'h00);
	write_reg(6'h27, 8'h00);
	write_reg(6'h2B, 8'h00);
	write_reg(6'h2D, 8'h00);
	write_reg(6'h2F, 8'h00);
	
	check(1, 0);

	write_reg(6'h3, 8'hFF);		// 1
	check(2, 1);
	write_reg(6'h2B, 8'hFF);	// 15
	check(3, 0);
	write_reg(6'h5, 8'hFF); 	// 2
	check(4, 1);
	write_reg(6'h2D, 8'hFF);	// 16
	check(5, 0);
	write_reg(6'h7, 8'hFF);		// 3
	check(6, 1);
	write_reg(6'h2F, 8'hFF);	// 17
	check(7, 0);

	write_reg(6'h13, 8'hFF);
	check(8, 1);
	write_reg(6'h23, 8'hFF);
	check(9, 0);
	write_reg(6'h15, 8'hFF);
	check(10, 1);
	write_reg(6'h25, 8'hFF);
	check(11, 0);
	write_reg(6'h17, 8'hFF);
	check(12, 1);
	write_reg(6'h27, 8'hFF);
	check(13, 0);

	write_reg(6'h9, 8'hFF);		// 4
	check(14, 1);
	write_reg(6'hD, 8'hFF);		// 6
	check(15, 0);
	write_reg(6'h19, 8'hFF);	// C
	check(16, 1);
	write_reg(6'hF, 8'hFF);		// 7
	check(17, 0);

	write_reg(6'hD, 8'h0);		// 6
	check(18, 1);
	write_reg(6'h1D, 8'hFF);	// E
	check(19, 0);
	write_reg(6'hF, 8'h0);		// 7
	check(20, 1);
	write_reg(6'h1F, 8'hFF);	// F
	check(21, 0);

	write_reg(6'h3, 8'h00);		// 1
	write_reg(6'h5, 8'h00);		// 2
	write_reg(6'h7, 8'h00);		// 3
	write_reg(6'h9, 8'h00);		// 4
	write_reg(6'hD, 8'h00);		// 6
	write_reg(6'h1D, 8'h00);	// E
	write_reg(6'h2B, 8'h00);	// 15
	write_reg(6'h2D, 8'h00);	// 16
	//write_reg(6'h2F, 8'h00);	// 17

	for (i = 0; i < 256; i += 1) begin
		write_reg(6'h2F, i);	// 17
		// PROCESSED == i
		if (dut.UNIT_X.PROCESSED != i) begin
	    	$display("FAILED test X LSB positive i=%d", i);
	    	$finish;
		end
	end
	write_reg(6'h2F, 8'h00);	// 17

	write_reg(6'h2B, 8'h80);	// 15
	for (i = 0; i < 256; i += 1) begin
		write_reg(6'h2F, i);	// 17
		// PROCESSED == -i
		if (dut.UNIT_X.PROCESSED != -i[8:0]) begin
	    	$display("FAILED test X LSB negative i=%d", i);
	    	$finish;
		end
	end
	write_reg(6'h2F, 8'h00);	// 17

	write_reg(6'hD, 8'h56);		// 6
	write_reg(6'h1D, 8'hDE);	// E
	if (dut.UNIT_X.SUM3 != 9'h134) begin
    	$display("FAILED test X SUM3");
    	$finish;
	end
    
    // 0x123456 + 0x7B
	write_reg(6'h3, 8'h12);		// 1
	write_reg(6'h5, 8'h34);		// 2
	write_reg(6'h7, 8'h56);		// 3
	write_reg(6'h9, 8'h7B);		// 4
	if (dut.UNIT_X.SUM1 != 24'h1234D1) begin
    	$display("FAILED test X SUM1 add");
    	$finish;
	end

    // 0x123456 - 0x7D
	write_reg(6'h9, 8'h83);		// 4
	if (dut.UNIT_X.SUM1 != 24'h1233D9) begin
    	$display("FAILED test X SUM1 sub");
    	$finish;
	end

	write_reg(6'h3, 8'h12);		// 1
	write_reg(6'h5, 8'h34);		// 2
	write_reg(6'h7, 8'h56);		// 3
	write_reg(6'h9, 8'h00);		// 4
	write_reg(6'h2B, 8'h78);	// 15
	write_reg(6'h2D, 8'h9A);	// 16
	write_reg(6'h2F, 8'hBC);	// 17
	// 1 + 0x123456 + ~0x789ABC (0x876543)
	// = 0x123456 - 0x789ABC = 0x99999A
	if (dut.UNIT_X.SUM2 != 24'h99999A) begin
    	$display("FAILED test X SUM2");
    	$finish;
	end

	write_reg(6'h2B, 8'h12);	// 15
	write_reg(6'h2D, 8'h20);	// 16
	write_reg(6'h2F, 8'h00);	// 17
	// = 0x123456 - 0x123256 = 0x000200 (positive and above 0000_0000_0000_000x_xxxx_xxxx == 0x1FF == 511)
	if (!dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB positive > 511");
    	$finish;
	end

	write_reg(6'h2B, 8'h12);	// 15
	write_reg(6'h2D, 8'h34);	// 16
	write_reg(6'h2F, 8'h00);	// 17
	// = 0x123456 - 0x122000 = 0x000056 (positive and below or equal to 0000_0000_0000_000x_xxxx_xxxx == 0x1FF == 511)
	if (dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB positive < 511");
    	$finish;
	end

	write_reg(6'h2B, 8'h12);	// 15
	write_reg(6'h2D, 8'h34);	// 16
	write_reg(6'h2F, 8'h00);	// 17
	// = 0x123456 - 0x123257 = 0x0001FF (positive and below or equal to 0000_0000_0000_000x_xxxx_xxxx == 0x1FF == 511)
	if (dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB positive == 511");
    	$finish;
	end

	write_reg(6'h2B, 8'h34);	// 15
	write_reg(6'h2D, 8'h56);	// 16
	write_reg(6'h2F, 8'h00);	// 17
	// = 0x123456 - 0x345600 = 0xDDDE56 (negative and below or equal to 1111_1111_1111_11xx_xxxx_xxxx == 0xFFFC00 == -1024)
	if (!dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB negative < -1024");
    	$finish;
	end

	write_reg(6'h2B, 8'h34);	// 15
	write_reg(6'h2D, 8'h56);	// 16
	write_reg(6'h2F, 8'h00);	// 17
	// = 0x123456 - 0x123856 = 0xFFFC00 (negative and below or equal to 1111_1111_1111_11xx_xxxx_xxxx == 0xFFFC00 == -1024)
	if (!dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB negative == -1024");
    	$finish;
	end

	write_reg(6'h2B, 8'h12);	// 15
	write_reg(6'h2D, 8'h35);	// 16
	write_reg(6'h2F, 8'h97);	// 17
	// = 0x123456 - 0x123855 = 0xFFFC01 (negative and above 1111_1111_1111_11xx_xxxx_xxxx == 0xFFFC00 == -1024)
	if (dut.UNIT_X.MSB_CHECK) begin
    	$display("FAILED test X MSB negative > -1024");
    	$finish;
	end

    $display("All tests passed :)");

	$finish;
end

endmodule
