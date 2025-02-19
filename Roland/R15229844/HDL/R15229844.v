// Roland R15229844

`include "nandlatch.v"
`include "rate_map.v"

module R15229844(
	input PIN_CLK_IN,
	input PIN_nRESET,

	input [15:0] PIN_IO_in,
	output [15:0] PIN_IO_out,

	output [7:0] PIN_DRAM_A,
	input [3:0] PIN_DRAM_D_in,
	output reg [3:0] PIN_DRAM_D_out,
	output reg PIN_nDRAM_RAS,
	output PIN_nDRAM_CAS, PIN_nDRAM_WE,

	input [7:0] PIN_VD_in,
	output [7:0] PIN_VD_out,
	input PIN_DPTH, PIN_RATE, PIN_DELY,

	input PIN_K64, PIN_LONG,
	input PIN_nINIT, PIN_DIO, PIN_OE, PIN_SYNC,
	input PIN_CPU, PIN_COMP,
	output reg PIN_GETA,
	//output PIN_TST0,	// Not implemented
	output reg PIN_MUTE,
	output reg PIN_SH0, PIN_SH1
);

	// PIN_OE sets the direction of PIN_IO pins
	// PIN_CPU sets the direction of PIN_VD pins

	assign CLK_IN_INV = ~PIN_CLK_IN;

	assign D74 = ~|{E95, D78_Q};
	assign B73 = D74 & B82_Q;
	assign B80 = B73 & C89_Q;

	reg B82_Q, C89_Q, D78_Q;
	reg [1:0] sync_sr;
	reg CLKDIV2, CLKDIV4, CLKDIV8, CLKDIV16;
	always @(posedge CLK_IN_INV) begin
		sync_sr <= {sync_sr[0], PIN_SYNC};

		B82_Q <= ~|{B73, ~|{D74, B82_Q}, CLK_IN_SYNC};	// What do these do ?
		C89_Q <= ~|{B80, ~|{B73, C89_Q}, CLK_IN_SYNC};
		D78_Q <= ~|{D78_Q ? ~E95 : ~B80, CLK_IN_SYNC};

		CLKDIV2 <= ~|{CLKDIV2, CLK_IN_SYNC};
		CLKDIV4 <= ~|{~CLKDIV4 & ~CLKDIV2, D100, CLK_IN_SYNC};
		CLKDIV8 <= ~|{~|{D100, CLKDIV8}, D101, CLK_IN_SYNC};
		CLKDIV16 <= ~|{~|{D101, CLKDIV16}, D101 & CLKDIV16, CLK_IN_SYNC};
	end
	
	assign D100 = ~|{~CLKDIV4, ~CLKDIV2};	// == CLKDIV2 & CLKDIV4
	assign D101 = D100 & CLKDIV8;

	// PIN_SYNC falling edge detector
	assign CLK_IN_SYNC = ~&{PIN_nRESET, ~&{sync_sr[1], ~sync_sr[0]}};
	
	// Low one period every 15 periods
	assign E95 = ~&{CLKDIV16, CLKDIV8, CLKDIV4, CLKDIV2};

	reg [3:0] SUBSTEP;
	always @(*) begin
		case({CLKDIV4, CLKDIV2})
			2'd0: SUBSTEP <= 4'b0001;
			2'd1: SUBSTEP <= 4'b0010;
			2'd2: SUBSTEP <= 4'b0100;
			2'd3: SUBSTEP <= 4'b1000;
		endcase
	end

	// General timing shift register
	assign D69 = ~|{~|{~D78_Q, E95}, CLK_IN_SYNC};
	assign #1 D64 = D69;	// BD3 cell, delay matters

	reg [19:0] SR;	// L63, B95, C61, C95, E61
	assign D92_NQ = ~CLKDIV4;
	always @(posedge D92_NQ or negedge PIN_nRESET) begin
		if (!PIN_nRESET) begin
			SR <= 20'h00000;
		end else begin
		    SR <= {SR[18:1], ~SR[0], D64};	// Shift left
		end
	end

	reg S106_Q;
	assign nSR15 = ~SR[15];
	always @(posedge nSR15 or negedge PIN_nRESET) begin
		if (!PIN_nRESET)
			S106_Q <= 1'b0;
		else
			S106_Q <= S113_Q;
	end
	
	// The state sequence of pins SH0 and SH1 is fixed
	assign L51 = ~&{SUBSTEP[3], SR[19], PIN_CLK_IN};
	assign H55 = ~&{SUBSTEP[1], SR[18], PIN_CLK_IN};

	assign K2 = ~&{SUBSTEP[3], SR[17], PIN_CLK_IN};
	assign K4 = ~&{SUBSTEP[1], SR[16], PIN_CLK_IN};

	always @(*) begin
		casex({D78_Q, H55, L51})	// H57
			3'b0xx: PIN_SH0 <= 1'b0;
			3'b100: PIN_SH0 <= 1'bz;
			3'b101: PIN_SH0 <= 1'b1;
			3'b110: PIN_SH0 <= 1'b0;
			3'b111: PIN_SH0 <= PIN_SH0;
		endcase
	
		casex({D78_Q, K4, K2})		// J40
			3'b0xx: PIN_SH1 <= 1'b0;
			3'b100: PIN_SH1 <= 1'bz;
			3'b101: PIN_SH1 <= 1'b1;
			3'b110: PIN_SH1 <= 1'b0;
			3'b111: PIN_SH1 <= PIN_SH1;
		endcase
	end
	
	// DRAM control signals

	assign H80 = ~|{SR[1], SR[5], SR[9], SR[13], SR[17]};
	
	assign G62 = ~|{SR[2], SR[10]};
	assign F94 = ~|{SR[6], SR[14]};
	assign L47 = ~&{G62, F94, ~SR[18]};
	assign nL47 = ~L47;
	
	always @(posedge nL47 or negedge H80 or negedge SR[0]) begin
		if (!H80)
			PIN_nDRAM_RAS <= 1'b0;
		else if (!SR[0])
			PIN_nDRAM_RAS <= 1'b1;
		else
			PIN_nDRAM_RAS <= 1'b1;
	end
	
	assign PIN_nDRAM_CAS = ~&{PIN_CLK_IN, L47};

	assign PIN_nDRAM_WE = ~SR[18];	// This also defines the DRAM_D pins directions


	// Counters

	reg [15:0] RAMP;
	always @(posedge SR[16] or negedge PIN_nRESET) begin
		if (!PIN_nRESET) begin
			RAMP <= 16'd0;
			PIN_MUTE <= 1'b1;
		end else begin
			RAMP <= RAMP + 1'b1;
			if (RAMP == 16'hFFFF)
				PIN_MUTE <= 1'b0;
		end
	end

	assign R71 = ~&{adder_d_out[7], ~RAMP[0], ~K4};

	reg [17:0] COUNTER;
	always @(posedge R71 or negedge nCLEAR) begin
		if (!nCLEAR)
			COUNTER <= 18'h00000;
		else
			COUNTER <= COUNTER + 1'b1;
	end

	assign L113 = ~RAMP[6];

	reg [13:0] COUNTERB;
	always @(posedge L113 or negedge nCLEAR) begin
		if (!nCLEAR)
			COUNTERB <= 14'd0;
		else
			COUNTERB <= COUNTERB + 1'b1;
	end
	


	assign RAMPn9_8 = ~|{RAMP[9:8]};
	assign RAMP9_n8 = ~|{~RAMP[9], RAMP[8]};
	assign L107 = |{PIN_CPU, ~SR[15]};
	
	assign W108 = ~&{~|{S106_Q, ~RAMPn9_8}, L107, PIN_RATE};
	assign WR_REG_RATE = W108 & ~&{PIN_RATE, PIN_CPU};
	
	assign X102 = ~&{~|{S106_Q, ~RAMP[8]}, L107, PIN_DELY};
	assign WR_REG_DELAY = X102 & ~&{PIN_DELY, PIN_CPU};
	
	assign W106 = ~&{~|{S106_Q, ~RAMP9_n8}, L107, PIN_DPTH};
	assign WR_REG_DEPTH = W106 & ~&{PIN_DPTH, PIN_CPU};
	
	reg [7:0] REG_RATE;
	reg [7:0] REG_DELAY;
	reg [7:0] REG_DEPTH;
	reg [15:0] latches_pre;
	
	always @(*) begin
		if (!WR_REG_RATE)
			REG_RATE <= PIN_CPU ? PIN_VD_in : RAMP[7:0];
		else
			REG_RATE <= REG_RATE;
	
		if (!WR_REG_DELAY)
			REG_DELAY <= PIN_CPU ? PIN_VD_in : RAMP[7:0];
		else
			REG_DELAY <= REG_DELAY;
	
		if (!WR_REG_DEPTH)
			REG_DEPTH <= PIN_CPU ? PIN_VD_in : RAMP[7:0];
		else
			REG_DEPTH <= REG_DEPTH;
	
	
		if (!(M8 & P14))
			latches_pre <= COUNTER[17:2];
		else
			latches_pre <= latches_pre;
	end

	assign nN91_QD = ~RAMP[7];
	always @(posedge nN91_QD or negedge PIN_nRESET or negedge P120) begin
		if (!PIN_nRESET)
			PIN_GETA <= 1'b0;
		else if (!P120)
			PIN_GETA <= 1'b1;
		else
			PIN_GETA <= 1'b0;
	end
	
	assign W110 = &{X102, W106, W108};
	reg S113_Q;
	always @(posedge nN91_QD or negedge W110 or negedge PIN_nRESET) begin
		if (!W110)
			S113_Q <= 1'b1;
		else if (!PIN_nRESET)
			S113_Q <= 1'b0;
		else
			S113_Q <= 1'b0;
	end
	

	wire [7:0] reg_rate_gate = ~&{{8{RAMPn9_8}}, REG_RATE};
	wire [7:0] reg_delay_gate = ~&{{8{RAMP[8]}}, REG_DELAY};
	wire [7:0] reg_depth_gate = ~&{{8{RAMP9_n8}}, REG_DEPTH};
	wire [7:0] reg_mux = ~&{reg_rate_gate, reg_delay_gate, reg_depth_gate};

	// Magnitude comparator ?
	assign W95 = ~&{~RAMP[0], reg_mux[0]};
	assign W92 = ~|{reg_mux[1] & ~RAMP[1], ~|{W95, ~|{~RAMP[1], reg_mux[1]}}};
	assign W97 = ~|{reg_mux[2] & ~RAMP[2], ~|{W92, ~|{~RAMP[2], reg_mux[2]}}};
	assign W102 = ~|{reg_mux[3] & ~RAMP[3], ~|{W97, ~|{~RAMP[3], reg_mux[3]}}};
	assign T104 = ~|{reg_mux[4] & ~RAMP[4], ~|{W102, ~|{~RAMP[4], reg_mux[4]}}};
	assign T110 = ~|{reg_mux[5] & ~RAMP[5], ~|{T104, ~|{~RAMP[5], reg_mux[5]}}};
	assign T114 = ~|{reg_mux[6] & ~RAMP[6], ~|{T110, ~|{~RAMP[6], reg_mux[6]}}};
	assign T117 = ~|{reg_mux[7] & ~RAMP[7], ~|{T114, ~|{~RAMP[7], reg_mux[7]}}};
	assign P120 = ~&{T117, SR[17]};

	assign PIN_VD_out = RAMP[7:0];

	// DRAM row/column address mux
	assign PIN_DRAM_A = ~(L47 ? {adder_c_out[13], adder_c_out[11:8], CLKDIV4, CLKDIV2, adder_c_out[12]} : {adder_c_out[7:0]});
	

	always @(*) begin
		// DRAM data out mux
		case({CLKDIV4, CLKDIV2})
			2'd0: PIN_DRAM_D_out <= ~latches_nor[15:12];// top top;
			2'd1: PIN_DRAM_D_out <= ~latches_nor[11:8];	// top bot;
			2'd2: PIN_DRAM_D_out <= ~latches_nor[7:4];	// bot top;
			2'd3: PIN_DRAM_D_out <= ~latches_nor[3:0];	// bot bot;
		endcase
	end
	
	assign D2 = PIN_COMP & PIN_DIO;
	assign D9 = &{PIN_COMP, ~PIN_DIO, SUBSTEP[3], PIN_CLK_IN};
	
	reg [15:0] mux_in;
	always @(*) begin
		casex({D9, D2})
			2'b00: mux_in <= 16'hFFFF;
			2'b01: mux_in <= ~PIN_IO_in;
			2'b10: mux_in <= ~mux_in_pre;
			2'b11: mux_in <= 16'bxxxxxxxx_xxxxxxxx;	// Shouldn't happen
		endcase
	end
	
	wire [15:0] mux_in_pre = {
		~SR[0], SR[1], SR[2], SR[3],
		SR[4], SR[5], SR[6], SR[7],
		SR[8], SR[9], SR[10], SR[11],
		SR[12], SR[13], SR[14], SR[15]};

	assign L100 = ~SR[19] & PIN_nRESET;

	wire [15:0] latches;
	NANDLATCH latch0(mux_in[0], L100, latches[0]);
	NANDLATCH latch1(mux_in[1], L100, latches[1]);
	NANDLATCH latch2(mux_in[2], L100, latches[2]);
	NANDLATCH latch3(mux_in[3], L100, latches[3]);
	NANDLATCH latch4(mux_in[4], L100, latches[4]);
	NANDLATCH latch5(mux_in[5], L100, latches[5]);
	NANDLATCH latch6(mux_in[6], L100, latches[6]);
	NANDLATCH latch7(mux_in[7], L100, latches[7]);
	NANDLATCH latch8(mux_in[8], L100, latches[8]);
	NANDLATCH latch9(mux_in[9], L100, latches[9]);
	NANDLATCH latch10(mux_in[10], L100, latches[10]);
	NANDLATCH latch11(mux_in[11], L100, latches[11]);
	NANDLATCH latch12(mux_in[12], L100, latches[12]);
	NANDLATCH latch13(mux_in[13], L100, latches[13]);
	NANDLATCH latch14(mux_in[14], L100, latches[14]);
	NANDLATCH latch15(mux_in[15], L100, latches[15]);

	wire [15:0] latches_nor = ~(latches | mux_in_pre);
	
	
	// 8-bit adder D
	wire [7:0] adder_d_out = W28 + {1'b0, REG_DEPTH[7:1]} + {1'b0, ADDD_REG[7:1]};
	
	assign W28 = ADDD_REG[0] & REG_DEPTH[0];
	assign W27 = ~|{~|{REG_DEPTH[0], ADDD_REG[0]}, W28};
	
	reg [7:0] ADDD_REG;
	always @(posedge R70 or negedge nCLEAR) begin
		if (!nCLEAR)
			ADDD_REG <= 8'd0;
		else
			ADDD_REG <= {adder_d_out[6:0], W27};
	end
	
	assign P14 = PIN_nINIT & PIN_nRESET;
	assign nCLEAR = P14 & M13;

	assign R70 = ~&{~RAMP[0], ~K4};

	assign X36 = ~&{~PIN_LONG, REG_DELAY[0]};
	assign X39 = ~^{adder_a_gated[5], X36};
	assign X41 = adder_a_gated[5] | X36;

	// 14-bit adder C
	wire [13:0] adder_c_out = B82_Q + ~RAMP[13:0] + (D78_Q ? 14'h0000 : ~{adder_b_out, X39, adder_a_gated[4:2]});

	// 11-bit adder B
	wire [10:0] adder_b_out = X41 + {1'b0, mux_b} + {1'b0, adder_a_gated[15:6]};

	reg [9:0] mux_b;
	always @(*) begin
		casex({PIN_LONG, PIN_K64})
        	2'b0x: mux_b <= {3'b111, ~REG_DELAY[7:1]};
        	2'b10: mux_b <= {~REG_DELAY[7:0], 2'b11};
        	2'b11: mux_b <= {2'b11, ~REG_DELAY[7:0]};
		endcase
	end

	wire [15:0] gated_a = N3 ? latches_pre : 16'h0000;
	wire [15:0] muxed_b = {16{N3}} ^ {COUNTER[17:2]};

	// 17-bit adder A
	wire [16:0] adder_a_out = N3 + {1'b0, gated_a} + {1'b0, muxed_b};
	wire [15:0] adder_a_gated = P43 ? ~adder_a_out : 16'hFFFF;

	assign N29 = ~&{~adder_a_out[16], N3, ~C89_Q};
	assign P43 = ~&{~adder_a_out[16], N3, C89_Q};
	assign P8 = ~|{N3, ~P43};
	assign P5 = ~|{~N3, ~P43};

	assign N3 = ~|{~N7_Q & P8, ~&{~N7_Q, ~C89_Q} & ~C89_Q};
	
	assign M13 = ~&{SR[18], M9_Q};
	reg N7_Q;
	always @(posedge M13 or negedge P14) begin
		if (!P14)
			N7_Q <= 1'b0;
		else
			N7_Q <= ~N7_Q;
	end
	
	reg M43_Q, M9_Q;
	
	assign M8 = ~&{~&{H61, ~M43_Q}, SUBSTEP[2] & SR[17]};
	assign M3 = ~|{S29 & ~|{N3, F94}, SR[6] & ~N29};
	assign S29 = ~&{&{adder_b_out[9:8]} | ~PIN_K64, adder_b_out[10]};
	
	always @(*) begin
		casex({PIN_nRESET, M3, ~SR[19]})
			3'b0xx: M43_Q <= 1'b0;
			3'b100: M43_Q <= 1'bz;
			3'b101: M43_Q <= 1'b1;
			3'b110: M43_Q <= 1'b0;
			3'b111: M43_Q <= M43_Q;
		endcase
	
		casex({PIN_nRESET, M8, ~SR[19]})
			3'b0xx: M9_Q <= 1'b0;
			3'b100: M9_Q <= 1'bz;
			3'b101: M9_Q <= 1'b1;
			3'b110: M9_Q <= 1'b0;
			3'b111: M9_Q <= M9_Q;
		endcase
	end
	
	
	// Converts 8-bit REG_RATE to 15-bit RATE_TR
	wire [14:0] RATE_TR;

	RATEMAP RM(
		REG_RATE,
		RATE_TR
	);

	// Magnitude comparator ?
	assign G105 = ~&{RATE_TR[0], ~L113};
	assign F93 = ~|{G105, ~|{RATE_TR[1], COUNTERB[0]}};
	assign E90 = ~|{~|{COUNTERB[0] & RATE_TR[1], F93}, ~|{RATE_TR[2], COUNTERB[1]}};
	assign E91 = ~|{~|{COUNTERB[1] & RATE_TR[2], E90}, ~|{RATE_TR[3], COUNTERB[2]}};
	assign G119 = ~|{~|{COUNTERB[2] & RATE_TR[3], E91}, ~|{RATE_TR[4], COUNTERB[3]}};
	assign G115 = ~|{~|{COUNTERB[3] & RATE_TR[4], G119}, ~|{RATE_TR[5], COUNTERB[4]}};
	
	assign G111 = ~|{~|{COUNTERB[4] & RATE_TR[5], G115}, ~|{RATE_TR[6], COUNTERB[5]}};
	assign G107 = ~|{~|{COUNTERB[5] & RATE_TR[6], G111}, ~|{RATE_TR[7], COUNTERB[6]}};
	assign G77 = ~|{~|{COUNTERB[6] & RATE_TR[7], G107}, ~|{RATE_TR[8], COUNTERB[7]}};
	assign F73 = ~|{~|{COUNTERB[7] & RATE_TR[8], G77}, ~|{RATE_TR[9], COUNTERB[8]}};
	
	assign F78 = ~|{~|{COUNTERB[8] & RATE_TR[9], F73}, ~|{RATE_TR[10], COUNTERB[9]}};
	assign F86 = ~|{~|{COUNTERB[9] & RATE_TR[10], F78}, ~|{RATE_TR[11], COUNTERB[10]}};
	assign F82 = ~|{~|{COUNTERB[10] & RATE_TR[11], F86}, ~|{RATE_TR[12], COUNTERB[11]}};
	assign F72 = ~|{~|{COUNTERB[11] & RATE_TR[12], F82}, ~|{RATE_TR[13], COUNTERB[12]}};
	
	assign H64 = ~|{~|{COUNTERB[12] & RATE_TR[13], F72}, ~|{RATE_TR[14], COUNTERB[13]}};
	assign H61 = ~|{COUNTERB[13] & RATE_TR[14], H64};
	

	assign PIN_IO_out = D78_Q ? ~{~out_latches[15], out_latches[14:0]} : ~latches_nor;
	
	assign H51 = ~&{SR[9] | SR[18], SUBSTEP[0], PIN_CLK_IN};
	
	reg [15:0] out_latches;
	always @(*) begin
		if (!H51)
			out_latches <= sum_e_reg;
		else
			out_latches <= out_latches;
	end
	
	// 16-bit adder E
	wire [15:0] sum_e = (sum_e_reg[0] | READ[0]) + {sum_e_reg[15], sum_e_reg[15:1]} + {READ[15], READ[15:1]};

	assign D6 = ~&{|{SR[8:7], SR[16:15]}, PIN_CLK_IN};

	reg [15:0] sum_e_reg;
	always @(posedge F94 or negedge D6) begin
		if (!D6)
			sum_e_reg <= 16'h0000;
		else
			sum_e_reg <= sum_e;
	end
	
	
	// DRAM read
	
	reg [3:0] H18;
	reg [3:0] H3;
	reg [3:0] E16;
	reg [3:0] E1;
	reg [3:0] L17;
	reg [3:0] L3;
	reg [3:0] F48;
	reg [3:0] F28;
	always @(*) begin
		if (&{~G62, SUBSTEP[0], PIN_CLK_IN})
			E16 <= PIN_DRAM_D_in;
		else
			E16 <= E16;
	
		if (&{~F94, SUBSTEP[0], PIN_CLK_IN})
			E1 <= PIN_DRAM_D_in;
		else
			E1 <= E1;

		if (&{~G62, SUBSTEP[1], PIN_CLK_IN})
			F48 <= PIN_DRAM_D_in;
		else
			F48 <= F48;
	
		if (&{~F94, SUBSTEP[1], PIN_CLK_IN})
			F28 <= PIN_DRAM_D_in;
		else
			F28 <= F28;

		if (&{~G62, SUBSTEP[2], PIN_CLK_IN})
			H18 <= PIN_DRAM_D_in;
		else
			H18 <= H18;
	
		if (&{~F94, SUBSTEP[2], PIN_CLK_IN})
			H3 <= PIN_DRAM_D_in;
		else
			H3 <= H3;
	
		if (&{~G62, SUBSTEP[3], PIN_CLK_IN})
			L17 <= PIN_DRAM_D_in;
		else
			L17 <= L17;
	
		if (&{~F94, SUBSTEP[3], PIN_CLK_IN})
			L3 <= PIN_DRAM_D_in;
		else
			L3 <= L3;
	end
	
	wire [15:0] READ = L42 ? {E16, F48, H18, L17} : {E1, F28, H3, L3};

	reg [7:0] LT;
	always @(*) begin
		if (!F94)
			LT <= {adder_a_gated[1:0], {6{P8}} ^ {COUNTER[1:0], ADDD_REG[7:4]}};
		else
			LT <= LT;
	end
	
	reg M32, M38;
	always @(*) begin
		case({~CLKDIV4, ~CLKDIV2})
			2'd0: {M32, M38} <= ~{LT[4], LT[0]};
			2'd1: {M32, M38} <= ~{LT[5], LT[1]};
			2'd2: {M32, M38} <= ~{LT[6], LT[2]};
			2'd3: {M32, M38} <= ~{LT[7], LT[3]};
		endcase
	end
	
	assign L42 = CLKDIV8 ? M32 : M38;

endmodule
