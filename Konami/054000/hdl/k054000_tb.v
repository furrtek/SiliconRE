// Konami 054000 testbench
// furrtek 2022

`include "k054000.v"

module tb();

reg [7:0] D;
wire [7:0] D_bidir;
reg [5:1] A;
reg P20, P22, P26, P27;

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
    	$display("FAILED test %d", number);
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

	write_reg(6'h9, 8'hFF);
	check(14, 1);
	write_reg(6'hD, 8'hFF);
	check(15, 0);
	write_reg(6'h19, 8'hFF);
	check(16, 1);
	write_reg(6'hF, 8'hFF);
	check(17, 0);

	write_reg(6'hD, 8'h0);
	check(18, 1);
	write_reg(6'h1D, 8'hFF);
	check(19, 0);
	write_reg(6'hF, 8'h0);
	check(20, 1);
	write_reg(6'h1F, 8'hFF);
	check(21, 0);

	/*wait(dout[3:0] == 0);
	@(negedge clk);
	wait(dout[3:0] == 0);   */

    $display("All tests passed :)");

	$finish;
end

endmodule
