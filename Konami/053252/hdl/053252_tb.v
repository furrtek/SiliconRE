// Konami 053252 testbench
// furrtek 2025

`include "053252.v"

module tb();

reg PIN_RESET;
reg PIN_CLK;
wire PIN_CLK1, PIN_CLK2, PIN_CLK3, PIN_CLK4;

reg [2:0] PIN_SEL;
reg [3:0] PIN_AB;
reg [7:0] PIN_DB_IN;
wire [7:0] PIN_DB_OUT;
reg PIN_CCS;
reg PIN_RW;
reg PIN_HLD1;
reg PIN_VLD1;

integer i;

k053252 dut(
	PIN_RESET,
	PIN_CLK,
	PIN_SEL,
	PIN_CCS,
	PIN_RW,
	PIN_AB,
	PIN_DB_IN,
	PIN_HLD1,
	PIN_VLD1,

	PIN_DB_OUT,
	PIN_CLK1,
	PIN_CLK2,
	PIN_CLK3,
	PIN_CLK4,
	PIN_PE,
    PIN_PQ,
    PIN_CRES,
    PIN_NHLD,
    PIN_NHSY,
    PIN_NVSY,
	PIN_NVLD,
	PIN_FCNT,
	PIN_INT1,
	PIN_INT2,
	PIN_NCBK,
	PIN_NCSY,
	PIN_NVBK,
	PIN_NHBS,
	PIN_NHBK
);

task write_reg;
input [3:0] address;
input [7:0] data;
begin
    #5 PIN_DB_IN <= data;
    PIN_AB <= address;

    #1 PIN_CCS <= 1'b0;
    #1 PIN_RW <= 1'b0;
    #1 PIN_RW <= 1'b1;
    #1 PIN_CCS <= 1'b1;
end
endtask

always @(*) begin
	#1 PIN_CLK <= ~PIN_CLK;
end

initial begin
	$dumpfile("k053252.vcd");
	$dumpvars(-1, tb);

    PIN_RESET <= 1'b0;
	PIN_CLK <= 1'b0;
	PIN_CCS <= 1'b1;
	PIN_RW <= 1'b1;
	PIN_SEL <= 3'b000;
	PIN_HLD1 <= 1'b1;
	PIN_VLD1 <= 1'b1;
	
	#10 PIN_RESET <= 1'b1;

    // Data from Metamorphic Force
	#10 write_reg(4'h0, 8'h01);
	#10 write_reg(4'h1, 8'h7F);
	#10 write_reg(4'h2, 8'h00);
	#10 write_reg(4'h3, 8'h11);
	#10 write_reg(4'h4, 8'h00);
	#10 write_reg(4'h5, 8'h27);
	#10 write_reg(4'h6, 8'h01);
	#10 write_reg(4'h9, 8'h07);
	#10 write_reg(4'hA, 8'h10);
	#10 write_reg(4'hB, 8'h0F);
	#10 write_reg(4'hC, 8'h74);

	#2000000
	$finish;
end

endmodule
