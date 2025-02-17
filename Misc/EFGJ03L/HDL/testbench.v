`timescale 1ps/1ps

module testbench(
);

reg PIN_H16, PIN_SYCL, PIN_58;
wire [7:0] PIN_D_OUT;

EFGJ03L UUT(
	.PIN_H16(PIN_H16),
	.PIN_SYCL(PIN_SYCL),
	.E(E), .nE(nE), .Q(Q), .PIN_43(PIN_43), .PIN_nRAS(PIN_nRAS),
	.PIN_1(PIN_1),			// Activation ?
	.PIN_58(PIN_58),		// Resets
	.PIN_36(PIN_36),		// Selection ?
	.PIN_nCSCOL(PIN_nCSCOL),
	.PIN_nCSPT(PIN_nCSPT),
	.PIN_nCSEXT(PIN_nCSEXT),
	.PIN_RW(PIN_RW),
	.PIN_nCKLP(PIN_nCKLP),
	.PIN_A({PIN_A[15], ~PIN_A[14], PIN_A[13:0]}),
	.D_IN(2'b01),
	.PIN_D_OUT(PIN_D_OUT)
);

assign PIN_1 = 1'b0;
assign PIN_36 = 1'b1;
assign PIN_nCSCOL = 1'b1;
assign PIN_nCSPT = 1'b1;
assign PIN_nCSEXT = 1'b1;
reg PIN_nCKLP;

/*reg [2:0] cnt;	// S/R test

// D24: Enable, active high
// G38B: set
// J32: reset
assign PIN_58 = 1'b1;
assign J37 = ~&{D24, G38B};
assign H37 = ~&{~J32, D24};
assign H38A = ~&{H37, J38};
assign J38 = ~&{H38A, J37, PIN_58};

assign {D24, J32, G38B} = cnt;

// D24: Enable, active high
// G38B: set
// J32: reset
assign PIN_58 = 1'b1;
assign J37 = ~&{D24, G38B};
assign H37 = ~&{~J32, D24};
assign H38A = ~&{H37, J38};
assign J38 = ~&{H38A, J37, PIN_58};

always@(*)
    #1000 cnt <= cnt + 1'b1;*/

reg [15:0] PIN_A;
reg PIN_RW;

initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, testbench);
    
    // S/R test
    //cnt <= 3'd0;

	PIN_RW <= 1'b1;
	PIN_A <= 16'h0000;
	PIN_H16 <= 1'b0;
	PIN_SYCL <= 1'b1;
	PIN_58 <= 1'b0;
	PIN_nCKLP = 1'b1;

	#100000
	PIN_SYCL <= 1'b0;
	PIN_58 <= 1'b1;

	#1000000
	PIN_nCKLP = 1'b0;
	#1000000
	PIN_nCKLP = 1'b1;

	#1000000
	PIN_A <= 16'hA7E5;
	#1000000
	PIN_A <= 16'hA7E6;

	#1000000
	PIN_nCKLP = 1'b0;
	#1000000
	PIN_nCKLP = 1'b1;

	#1000000
	PIN_A <= 16'hA7E5;

	#1000000
	PIN_A <= 16'hA7E4;
	#1000000
	PIN_RW <= 1'b0;
	#1000000
	PIN_RW <= 1'b1;

	#1000000
	PIN_nCKLP = 1'b0;
	#1000000
	PIN_nCKLP = 1'b1;

	#1000000
	PIN_A <= 16'hA7E6;

	#21000000000
	$finish;
end

always@(*)
	#31250 PIN_H16 <= ~PIN_H16;	// 16MHz

endmodule
