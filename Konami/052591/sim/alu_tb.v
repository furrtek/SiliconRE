// Konami 052591 ALU testbench
// 2023 furrtek
// For simulation only

module tb();

reg [15:0] A;
reg [15:0] B;

alu dut(
	A, B
);

initial begin
	for (B = 16'h7FFA; B < 16'h8002; B = B + 1) begin
		for (A = 16'h0000; A < 16'h0010; A = A + 1)
			#1 $display("%d %d %d %d === %d %d", A, B, dut.bus_xnor, dut.alu, dut.Y8, dut.T10);
		$display("");
	end

	#100 $finish;
end

endmodule

module alu(
	input [15:0] A,
	input [15:0] B
);

wire [15:0] alu_or;
wire [15:0] alu_and;
wire [15:0] alu_xnor1;
wire [15:0] alu_xnor2;
wire [15:0] bus_xnor;
wire [15:0] alu;			// ALU result

// ALU

assign alu_or = A | B;
assign alu_and = A & B;
assign alu_xnor1 = ~(alu_or ^ alu_and);
//assign alu_xnor2 = ~(alu_xnor1 ^ {16{~ir[5]}});
//assign alu = ~(alu_xnor2 ^ bus_xnor);
assign alu = ~(alu_xnor1 ^ bus_xnor);

assign Y8 = ~&{AA22, ~&{AH22, &{alu_or[15:12]}}};
assign T10 = (Y8 ^ ~&{~&{AH22, Y12}, Z13, AA9, AB10});
//assign N45 = alu[15] ^ T10;

/*assign L59 = ir[33] | ~ir[32];
reg N68;
always @(posedge clk)
	N68 <= ~|{L59, alu[15]};
assign AD60 = ir[3] | N68;*/

assign AH99 = ~&{alu_or[3:0]};
assign AH41 = ~&{alu_or[7:4]};
assign AG10 = ~&{alu_or[11:8]};

assign AJ88 = &{~alu_and[3], ~&{alu_or[3], alu_and[2]}, ~&{alu_or[3:2], alu_and[1]}, ~&{alu_or[3:1], alu_and[0]}};
assign AH29 = &{~alu_and[7], ~&{alu_or[7], alu_and[6]}, ~&{alu_or[7:6], alu_and[5]}, ~&{alu_or[7:5], alu_and[4]}};
assign AG12 = &{~alu_and[11], ~&{alu_or[11], alu_and[10]}, ~&{alu_or[11:10], alu_and[9]}, ~&{alu_or[11:9], alu_and[8]}};
assign AA22 = &{~alu_and[15], ~&{alu_or[15], alu_and[14]}, ~&{alu_or[15:14], alu_and[13]}, ~&{alu_or[15:13], alu_and[12]}};

assign AH22 = &{~&{AG12, AH29, AJ88, ~M53}, ~&{AH99, AG12, AH29, AJ88}, ~&{AH41, AG12, AH29}, ~&{AG10, AG12}};
assign AJ24 = &{~&{AH29, AJ88, ~M53}, ~&{AH99, AH29, AJ88}, ~&{AH41, AH29}};
assign AH25 = &{~&{AJ88, ~M53}, ~&{AJ88, AH99}};
assign M53 = 1'b0;	//~&{~&{AD60, ~L59}, ~&{~ir[15] & ir[34], L59}};

assign AH84 = 1'b1;
assign AF43 = AH84;
assign AB22 = AH84;
assign AD31 = AH84;

assign Y12 = &{alu_or[14:12], AB22};
assign Z13 = ~&{alu_or[14:13], alu_and[12], AB22};
assign AA9 = ~&{alu_or[14], alu_and[13], AB22};
assign AB10 = ~&{alu_and[14], AB22};

// Four 4-bit blocks for arithmetic

assign bus_xnor[15] = ~&{~&{AH22, Y12}, Z13, AA9, AB10};
assign bus_xnor[14] = ~&{   ~&{alu_or[13:12], AH22, AB22}, ~&{alu_or[13], alu_and[12], AB22}, ~&{alu_and[13], AB22}};
assign bus_xnor[13] = ~&{   ~&{alu_or[12], AH22, AB22}, ~&{alu_and[12], AB22}};
assign bus_xnor[12] = &{AH22, AB22};

assign bus_xnor[11] = ~&{~&{AJ24, &{alu_or[10:8], AD31}}, ~&{alu_or[10:9], alu_and[8], AD31}, ~&{alu_or[10], alu_and[9], AD31}, ~&{alu_and[10], AD31}};
assign bus_xnor[10] = ~&{  ~&{alu_or[9:8], AJ24, AD31}, ~&{alu_or[9], alu_and[8], AD31},  ~&{alu_and[9], AD31}};
assign bus_xnor[9] =  ~&{~&{alu_or[8], AJ24, AD31}, ~&{alu_and[8], AD31}};
assign bus_xnor[8] =  &{AJ24, AD31};

assign bus_xnor[7] = ~&{~&{AH25, &{alu_or[6:4], AF43}}, ~&{alu_or[6:5], alu_and[4], AF43}, ~&{alu_or[6], alu_and[5], AF43}, ~&{alu_and[6], AF43}};
assign bus_xnor[6] = ~&{ ~&{alu_or[5:4], AH25, AF43},~&{alu_or[5], alu_and[4], AF43}, ~&{alu_and[5], AF43}};
assign bus_xnor[5] = ~&{  ~&{alu_or[4], AH25, AF43},~&{alu_and[4], AF43}};
assign bus_xnor[4] = &{AH25, AF43};

assign bus_xnor[3] = ~&{~&{M53, &{alu_or[2:0], AH84}}, ~&{alu_or[2:1], alu_and[0], AH84}, ~&{alu_or[2], alu_and[1], AH84}, ~&{alu_and[2], AH84}};
assign bus_xnor[2] = ~&{~&{alu_or[1:0], M53, AH84}, ~&{alu_or[1], alu_and[0], AH84}, ~&{alu_and[1], AH84}};
assign bus_xnor[1] = ~&{ ~&{alu_or[0], M53, AH84}, ~&{alu_and[0], AH84}};
assign bus_xnor[0] = &{M53, AH84};

endmodule
