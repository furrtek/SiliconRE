// NEC uPD65005-195 testbench

`timescale 1ns/1ns
`include "uPD65005-195.v"

module joypad(
	input [7:0] inputs,		// RS21LDRU
	input clr, sel,
	output [3:0] d
);

assign d = clr ? 4'b0000 : sel ? inputs[3:0] : inputs[7:4];

endmodule

module tb();

reg [7:0] inputs [1:5];
wire P_CLR [1:5];
wire P_SEL [1:5];
wire [3:0] PD [1:5];
reg CLR, SEL;
wire [3:0] D_OUT;

uPD65005_195 UUT(
	CLR, SEL,
	D_OUT,
	PD[1], P_CLR[1], P_SEL[1],
	PD[2], P_CLR[2], P_SEL[2],
	PD[3], P_CLR[3], P_SEL[3],
	PD[4], P_CLR[4], P_SEL[4],
	PD[5], P_CLR[5], P_SEL[5]
);

joypad JP1(inputs[1], P_CLR[1], P_SEL[1], PD[1]);
joypad JP2(inputs[2], P_CLR[2], P_SEL[2], PD[2]);
joypad JP3(inputs[3], P_CLR[3], P_SEL[3], PD[3]);
joypad JP4(inputs[4], P_CLR[4], P_SEL[4], PD[4]);
joypad JP5(inputs[5], P_CLR[5], P_SEL[5], PD[5]);

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    CLR <= 1'b0;
    SEL <= 1'b1;                // RS21LDRU
    inputs[1] <= 8'b11100111;	// ---1L---
    inputs[2] <= 8'b11011011;	// --2--D--
    inputs[3] <= 8'b10111101;	// -S----R-
    inputs[4] <= 8'b01111110; 	// R------U
    inputs[5] <= 8'b01101100; 	// R--1--RU

    #10 CLR <= 1'b1;
    #10 CLR <= 1'b0;

    // Read JP1 LDRU
    #10 if (D_OUT != 4'b0111) $display("JP1 test 1 failed");
    SEL <= 1'b0;
    // Read JP1 RS21
    #10 if (D_OUT != 4'b1110) $display("JP1 test 2 failed");

    SEL <= 1'b1;
    // Read JP2 LDRU
    #10 if (D_OUT != 4'b1011) $display("JP2 test 1 failed");
    SEL <= 1'b0;
    // Read JP2 RS21
    #10 if (D_OUT != 4'b1101) $display("JP2 test 2 failed");

    SEL <= 1'b1;
    // Read JP3 LDRU
    #10 if (D_OUT != 4'b1101) $display("JP3 test 1 failed");
    SEL <= 1'b0;
    // Read JP3 RS21
    #10 if (D_OUT != 4'b1011) $display("JP3 test 2 failed");

    SEL <= 1'b1;
    // Read JP4 LDRU
    #10 if (D_OUT != 4'b1110) $display("JP4 test 1 failed");
    SEL <= 1'b0;
    // Read JP4 RS21
    #10 if (D_OUT != 4'b0111) $display("JP4 test 2 failed");

    SEL <= 1'b1;
    // Read JP5 LDRU
    #10 if (D_OUT != 4'b1100) $display("JP5 test 1 failed");
    SEL <= 1'b0;
    // Read JP5 RS21
    #10 if (D_OUT != 4'b0110) $display("JP5 test 2 failed");

    #50

	$finish;
end

endmodule
