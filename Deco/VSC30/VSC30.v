// DECO VSC30
// RE and HDL by furrtek 05/2022
// Chip provided by Caius

// VNOOOOOOOOOOOOOOOOOO
// |""""""""""""""""""|
//  )   DECO VSC30    |
// |__________________|
// IIIIIIIIIINNOOOONIIG

module VSC30(
	input PIN1,	// /RESET

	input PIN2,	// Shift clock
	input PIN3,	// Delay in
	input PIN4,	// Delay in
	input PIN5,	// Shift in
	input PIN6,	// Shift in
	input PIN7,	// Shift grab
	input PIN8,	// Shift in
	input PIN9,	// Shift output reverse
	input PIN10,	// Shift output reverse

	output PIN13, PIN14, PIN15, PIN16,	// Shift out

	input PIN18,	// V count flip
	input PIN19,	// V count clock

	output PIN21, PIN22, PIN23, PIN24, PIN25, PIN26, PIN27, PIN28,	// V count

	output PIN29, PIN30, PIN31, PIN32,	// Shift out
	output PIN33, PIN34, PIN35, PIN36,	// Shift out

	output reg PIN37,	// Delay out
	output reg PIN38	// Delay out
);

assign PIN2_INV = ~PIN2;
assign RES = ~PIN1;

reg [7:0] SR1;
reg [7:0] SR2;

reg [3:0] SR3;
reg [3:0] SR4;
reg [3:0] SR5;
always @(posedge PIN2_INV or posedge RES) begin
	if (RES) begin
    	SR1 <= 8'h00;
    	SR2 <= 8'h00;
    	SR3 <= 4'h0;
    	SR4 <= 4'h0;
    	SR5 <= 4'h0;
	end else begin
		SR1 <= {SR1[6:0], PIN3};
		SR2 <= {SR2[6:0], PIN4};
	
		SR3 <= {SR3[2:0], PIN8};
		SR4 <= {SR4[2:0], PIN5};
		SR5 <= {SR5[2:0], PIN6};
	end
end

always @(posedge PIN2 or posedge RES) begin
	if (RES) begin
		PIN38 <= 1'b0;
		PIN37 <= 1'b0;
	end else begin
		PIN38 <= SR1[7];
		PIN37 <= SR2[7];
	end
end

reg [3:0] SR3_REG;
reg [3:0] SR4_REG;
reg [3:0] SR5_REG;
always @(posedge PIN7 or posedge RES) begin
	if (RES) begin
		SR3_REG <= 4'h0;
		SR4_REG <= 4'h0;
		SR5_REG <= 4'h0;
	end else begin
		SR3_REG <= SR3;
		SR4_REG <= SR4;
		SR5_REG <= SR5;
	end
end

assign SEL = PIN9 ^ PIN10;

assign PIN29 = SEL ? SR3_REG[0] : SR3_REG[3];
assign PIN30 = SEL ? SR3_REG[1] : SR3_REG[2];
assign PIN31 = SEL ? SR3_REG[2] : SR3_REG[1];
assign PIN32 = SEL ? SR3_REG[3] : SR3_REG[0];

assign PIN13 = SEL ? SR5_REG[3] : SR5_REG[0];
assign PIN14 = SEL ? SR5_REG[2] : SR5_REG[1];
assign PIN15 = SEL ? SR5_REG[1] : SR5_REG[2];
assign PIN16 = SEL ? SR5_REG[0] : SR5_REG[3];

assign PIN33 = SEL ? SR4_REG[0] : SR4_REG[3];
assign PIN34 = SEL ? SR4_REG[1] : SR4_REG[2];
assign PIN35 = SEL ? SR4_REG[2] : SR4_REG[1];
assign PIN36 = SEL ? SR4_REG[3] : SR4_REG[0];

// Counter
// This can be simplified a lot, see notes on schematic sheet.

reg [7:0] CNT_REG;
reg L14;

assign B9 = &{CNT_REG[3:0]};
assign M5 = ~&{CNT_REG[6:4]};
assign M8 = ~&{B9, CNT_REG[7]};
assign M7 = ~|{M5 | M8};
assign D4 = ~M7;
assign B21 = D4 & PIN1;

assign D5 = ~|{D4, RES};
assign D9 = ~|{RES, D5};

assign C28 = ~&{~&{~CNT_REG[0], D4}, ~&{~B21, D9, CNT_REG[0]}};
assign D8 = ~&{~&{CNT_REG[0], B21, ~CNT_REG[1]}, ~&{~&{B21, CNT_REG[0]}, D9, CNT_REG[1]}};
assign B25 = ~&{~&{B21, CNT_REG[1], CNT_REG[0], ~CNT_REG[2]}, ~&{~&{B21, CNT_REG[0], CNT_REG[1]}, D9, CNT_REG[2]}};
assign D13 = |{&{D9, ~&{CNT_REG[2:0]}, CNT_REG[3]}, ~|{~&{~CNT_REG[3], B21, CNT_REG[0]}, ~&{CNT_REG[2:1]}}, D5};

assign M2 = ~&{CNT_REG[6:5]} | ~&{J15, CNT_REG[4], ~CNT_REG[7]};

assign J15 = &{PIN1, D4, B9};

assign L9 = ~|{D4, RES};
assign L12 = ~|{RES, L9};

assign N16 = ~&{~&{~CNT_REG[4], J15}, ~&{~J15, L12, CNT_REG[4]}};
assign R15 = ~&{~&{L9, ~L14}, ~&{~CNT_REG[5], J15, CNT_REG[4]}, ~&{CNT_REG[5], ~&{CNT_REG[4], J15}, L12}};
assign P23 = ~&{~&{~L14, L9}, ~&{CNT_REG[5:4], J15, ~CNT_REG[6]}, ~&{L12, ~&{J15, CNT_REG[5:4]}, CNT_REG[6]}};
assign N7 = ~&{~&{L9, ~L14}, M2, ~&{CNT_REG[7], ~&{J15, CNT_REG[6:4]}, L12}};

always @(posedge ~PIN19 or posedge RES) begin
	if (RES) begin
		CNT_REG <= 8'h08;
		L14 <= 1'b0;
	end else begin
		CNT_REG[0] <= C28;
		CNT_REG[1] <= D8;
		CNT_REG[2] <= B25;
		CNT_REG[3] <= D13;

		CNT_REG[4] <= N16;
		CNT_REG[5] <= R15;
		CNT_REG[6] <= P23;
		CNT_REG[7] <= N7;
		
		if (M7)
			L14 <= ~L14;
	end
end

assign {PIN21, PIN22, PIN23, PIN24, PIN25, PIN26, PIN27, PIN28} = {8{PIN18}} ^ CNT_REG;

endmodule
