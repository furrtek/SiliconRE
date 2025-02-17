// Implementation du gate array Thomson EFGJ03L
// Basé sur l'étude du silicium
// Dernière maj 30/09/22
// 2022 Sean Gonsalves

// Etat actuel:
// E, nE, Q, PIN_DVALID, H4, H2, H1, PIN_nINILT, PIN_nSUPLT ont l'air ok
// PIN_nRAS, PIN_SYNLT ont des soucis

module EFGJ03L(
	input PIN_H16,		// 16MHz
	input PIN_SYCL,		// Resets - Devrait etre PIN_57 (POR)
	input PIN_1,		// Activation ?
	input PIN_58,		// Resets - Devrait etre SYCL !
	input PIN_36,		// Selection ?
	output E, nE, Q,	// Horloges CPU 1MHz
	output PIN_FORME,	// Selection DRAM point / couleur
	output PIN_DVALID,
	output PIN_SYNLT,	// Synchro video composite
	output PIN_POINT,	// Dot clock 8MHz
	output PIN_nINILT,	// Selection zone 0 = active / 1 = cadre
	output PIN_nSUPLT,	// Forçage sortie video noire (blanking)
	output PIN_nITLP,	// Generation interruption light pen
	input PIN_nCSCOL,
	input PIN_nCSPT,
	input PIN_nCSEXT,
	output PIN_nCASCOL,
	output PIN_nCASPT,
	output PIN_nCASEXT,
	output PIN_43,		// 8MHz
	output PIN_nRAS,	// Controle DRAM
	input PIN_RW,       // CPU R/W
	input PIN_nCKLP,	// Impulsion light pen
	input [15:0] PIN_A,	// Bus addresse CPU
	input [1:0] D_IN, 	// Bus donnees CPU
	output [7:0] PIN_D_OUT,	// Bus donnees CPU
	output [7:0] PIN_MA	// Adresse DRAM multiplexée
);

// TL[5:0]: Compteur H 6 bits (0~3F, 64 octets par ligne)
// T[13:3]: Compteur de groupe de 8 octets 11 bits (inc par TL2)
// H4: 4MHz, H2: 2MHz, H1: 1MHz
// INITN = 1 sur la hauteur active
// INILN = 1 sur la largeur active
// 320 points * 200 lignes actifs
// 512 points * 312 lignes au total

reg [7:0] D_OUT;

// Sorties actives quand PIN_RW == DECODE == 1
assign PIN_D_OUT = (PIN_RW & DECODE) ? D_OUT : 8'bzzzzzzzz;

// Mux bus données lecture CPU
// Addr[1:0]
// 00: A7E4 {T37A, T31A, V28,  V25,  V22,  V19,  T14A, T10A}	T12   T11   T10 T9  T8  T7 T6 T5
// 01: A7E5 {T37B, T31B, T28B, T25B, T22B, T19B, T14B, T10B}	T4    T3    TL2 TL1 TL0 H1 H2 H4
// 10: A7E6 {T38A, T32,  0,    0,    0,    0,    0,    0}		LT3   INILN x   x   x   x  x  x
// 11: A7E7 {Q32,  T38B, 0,    0,    0,    0,    Q15A, 1}		INITN x     x   x   x   x  x  x

reg [12:3] TREG;
reg [2:0] TLREG;
reg [2:0] HREG;
reg T38A, T38B, T32;

always @(*) begin
	case(PIN_A[1:0])
    	2'd0: D_OUT <= TREG[12:5];							// A7E4
    	2'd1: D_OUT <= {TREG[4:3], TLREG, HREG};			// A7E5
    	2'd2: D_OUT <= {T38A, T32, 6'b00_0000};				// A7E6
    	2'd3: D_OUT <= {Q32,  T38B, 4'b0000, Q15A, 1'b1};	// A7E7
	endcase
end

// Registres pour bloquer les valeurs des compteurs sur impulsion du light pen
always @(posedge Q8B) begin		// S6 = Q8B
	T38A <= TL[3];	// "LT3"
	T32 <= J38; 	// "INILN"
	T38B <= Q32;	// "INITN" latched

	TREG <= T[12:3];
	TLREG <= TL[2:0];
	HREG <= {H1, H2, H4};
end

assign C36 = ~&{PIN_nCSCOL, ~PIN_A[13]};	// C36 = B30

assign B31 = ~&{~PIN_A[13], ~PIN_nCSCOL};
assign B32 = ~&{~PIN_A[13], ~PIN_nCSPT, ~PIN_FORME};
assign B33 = ~&{PIN_A[13], ~PIN_nCSPT};
assign B34 = ~&{PIN_FORME, ~PIN_nCSPT};
assign PIN_nCASCOL = ~&{C28B, ~&{B32, H1, B31}};	// Driver de sortie inverseur, D15 = H1 ?
assign PIN_nCASPT = ~&{C28B, ~&{B33, H1, B34}};		// Driver de sortie inverseur, D15 = H1 ?
assign PIN_nCASEXT = ~&{~PIN_nCSEXT, H1, C28B};		// Driver de sortie inverseur, D15 = H1 ?

assign right_col = D25 ? T[7:0] : {2'b00, T[12:7]};
assign left_col = D25 ? {PIN_A[14], C36, PIN_A[12:7]} : PIN_A[7:0];
assign PIN_MA = ~H1 ? right_col : left_col;	// D16 = ~H1

assign E10 = ~&{U16, H4, H2};			// D6 = U16 ?
assign E9 = ~&{~H4, ~H2} & E10;
assign E11 = ~&{~U16, ~H4, ~H2} & E10;	// D7 = ~U16 ?

assign DECODE = PIN_A[15:2] == 14'b1110_0111_1110_01;	// A7E4~A7E7 (E7E4~E7E7 avec un inverseur sur A[14])

assign R13 = ~&{DECODE, ~PIN_RW, H1};	// D15 = H1 ?
assign R15 = ~&{PIN_A[0], PIN_A[1], nPIN_FORME};	// A24B = nPIN_FORME
assign R12A = ~|{PIN_A[1], R13};
assign R14A = ~|{R15, R13};

reg Q15A, Q13B;

// A7E7 ?
always @(posedge R14A or negedge nPIN_SYCL) begin
	if (!nPIN_SYCL)
		Q15A <= 1'b1;
	else
		Q15A <= ~D_IN[1];	// Driver d'entrée non-inverseur
end

// Ecriture dans A7E4 ou A7E5
always @(posedge R12A or negedge nPIN_SYCL) begin
	if (!nPIN_SYCL)
		Q13B <= 1'b0;
	else
		Q13B <= D_IN[0];	// Driver d'entrée non-inverseur
end

assign R7B = ~&{~PIN_A[0], DECODE, PIN_A[1], H1};	// D15 = H1 ?
assign P7 = ~&{nPIN_SYCL, R7B, ~PIN_1, Q8B};
assign Q8B = ~&{Q10B, P7};

// Plein de signaux décodés depuis les compteurs de ligne et de trame
/*assign N28 = ~&{T[6], ~T[9], T[7], ~T[8]};	// M29 = ~T[9] ?, M26 = ~T[8] ?
assign N37 = ~&{~T[11], T[12], T[9], ~T[10]};	// M36 = ~T[11] ?, M33 = ~T[10] ?
assign N34 = ~&{T[10], T[12], T[11], ~T[13]};	// M42 = ~T[13] ?
assign N31 = ~&{T[13], ~T[10], ~T[12], ~T[11]};	// M33 = ~T[10] ?, M39 = ~T[12] ?, M36 = ~T[11] ?
assign N12 = ~&{T[4], T[3], T[5]};
assign N13B = ~&{T[4], ~T[5]};		// M16 = ~T[5] ?
assign N14 = ~&{~T[5], T[4]};		// M16 = ~T[5] ? Same as N13B ?!
assign N15 = ~&{T[5], ~T[4]};		// M13 = ~T[4] ?
assign N16 = ~&{T[4], T[5]};
assign N18 = ~&{T[8], T[9], T[7], T[6]};
assign N19 = ~&{T[6], ~T[9], T[7], T[8]};	// M29 = ~T[9] ?
assign N21 = ~&{~T[6], T[9], ~T[8], T[7]};	// M20 = ~T[6] ?, M26 = ~T[8] ?
assign N22 = ~&{T[9], ~T[7], ~T[8], T[6]};	// M26 = ~T[8] ?, M23 = ~T[7] ?
assign N24 = ~&{~T[6], T[7], T[9], T[8]};	// M20 = ~T[6] ?
assign N25 = ~&{~T[6], T[8], T[9], ~T[7]};	// M20 = ~T[6] ?, M23 = ~T[7] ?
assign N27 = ~&{T[8], T[6], ~T[7], T[9]};	// M23 = ~T[7] ?
assign N33 = ~&{T[13], ~T[12], ~T[11], T[10]};	// M39 = ~T[12] ?, M36 = ~T[11] ?
assign N36 = ~&{T[11], ~T[10], ~T[12], T[13]};	// M33 = ~T[10] ?, M39 = ~T[12] ?
*/
assign N12 = ~(T[5:3] == 3'b111);
assign N13B = ~(T[5:4] == 2'b01); 	// Erreur ?
assign N14 = ~(T[5:4] == 2'b01); 	// Erreur ?
assign N15 = ~(T[5:4] == 2'b10);
assign N16 = ~(T[5:4] == 2'b11);
assign N28 = ~(T[9:6] == 4'b0011);
assign N19 = ~(T[9:6] == 4'b0111);
assign N22 = ~(T[9:6] == 4'b1001);
assign N21 = ~(T[9:6] == 4'b1010);
assign N25 = ~(T[9:6] == 4'b1100);
assign N27 = ~(T[9:6] == 4'b1101);
assign N24 = ~(T[9:6] == 4'b1110);
assign N18 = ~(T[9:6] == 4'b1111);
assign N37 = ~(T[12:9] == 4'b1001);
assign N34 = ~(T[13:10] == 4'b0111);
assign N31 = ~(T[13:10] == 4'b1000);
assign N33 = ~(T[13:10] == 4'b1001);
assign N36 = ~(T[13:10] == 4'b1010);


assign Q19 = ~&{T[4], ~|{T[5], N33, N19}};	// ~(T[13:4] == 1001011101)
assign Q22 = ~&{T[4], ~|{M31, N33, N22}};	// ~(T[13:4] == 10011001x1 M31)
assign Q21 = ~&{T[4], ~|{N21, ~T[5], N31}};	// ~(T[13:4] == 1000101011)
assign Q20 = ~&{T[3], ~|{N13B, N36, N22}};	// ~(T[13:3] == 10101001011)
assign Q25 = ~&{T[3], ~|{N14, N33, N25}};	// ~(T[13:3] == 10011100011)
assign Q26 = ~&{T[3], ~|{N31, N15, N25}};	// ~(T[13:3] == 10001100101)
assign Q24 = ~&{T[5], ~|{N24, N31}};     	// ~(T[13:5] == 100011101)
assign Q27 = ~&{T[6], ~|{N33, ~&{T[9], T[7], ~T[8]}}};	// ~(T[13:6] == 10011011)

assign P38 = ~&{H38A, Q38, PIN_58};

//assign J24 = ~&{TL[2], TL[1]};
assign J24 = ~(TL[2:1] == 2'b11);
//assign J22 = ~&{TL[0], ~TL[1], ~TL[2]};	// H23 = ~TL[1] ?, H26 = ~TL[2] ?
assign J22 = ~(TL[2:0] == 3'b001);
//assign J20 = ~&{TL[1], TL[2], ~TL[0]};	// G20B = TL[0] ?
assign J20 = ~(TL[2:0] == 3'b110);
assign J33 = ~&{TL[5:3]};
//assign J32 = ~&{TL[3], TL[5], ~TL[4]};	// H33 = ~TL[4] ?
assign J32 = ~(TL[5:3] == 3'b101);
//assign J29 = ~&{TL[4], TL[5], ~TL[3]};	// H29 = ~TL[3] ?
assign J29 = ~(TL[5:3] == 3'b110);
assign J27 = ~&{TL[2:0]};

assign J25 = ~|{TL[2], J29};	// TL[5:2] == 4'b1100
assign J21 = ~|{J24, J32};		// TL[5:1] == 5'b10111
assign J28 = ~|{J27, J32};		// TL[5:0] == 6'b101001
assign J26 = ~|{J29, ~TL[2]};	// TL[5:0] == 6'b101111

assign J13 = ~|{PIN_36 ? ~&{~TL[2], TL[1]} : J22, J33};	// H26 = ~TL[2] ?

assign N6 = ~&{~|{N34, N18}, ~|{J20, N12}};

assign R21 = PIN_36 ? Q22 : Q21;
assign R19 = PIN_36 ? Q20 : Q19;
assign R24 = PIN_36 ? Q25 : Q24;
assign R26 = PIN_36 ? Q27 : Q26;
assign J18 = PIN_36 ? J28 : J25;
assign J17 = PIN_36 ? J16 : G18A;

// Bascule S-R
assign Q23 = ~&{R23, R21};
assign R23 = ~&{PIN_58, R19, Q23};

// Bascule S-R
assign Q28 = ~&{R26, R28};
assign R28 = ~&{PIN_58, R24, Q28};

// Bascule S-R avec EN
// F16: Enable
// J17: /Set
// J18: /Reset
// H15: /Q
assign H16 = ~&{~G15, J18};	// F16 = ~G15
assign J16 = ~&{~G15, J26};	// F16 = ~G15
assign H15 = ~&{J15, H16};
assign J15 = ~&{PIN_58, J17, H15};

// Bascule S-R avec EN
// D24: Enable
// G38B: /Set
// J36: /Reset
// J38: Q
assign J37 = ~&{D24, G38B};
assign H37 = ~&{D24, ~J32};	// J36 = ~J32
assign H38A = ~&{H37, J38};
assign J38 = ~&{H38A, J37, PIN_58};

// Bascule S-R avec EN
// F16: Enable
// J13: /Set
// J21: /Reset
// J11: Q
assign J12 = ~&{~G15, J13};	// F16 = ~G15
assign H12 = ~&{~G15, J21};	// F16 = ~G15
assign H11 = ~&{J11, H12};
assign J11 = ~&{H11, J12, PIN_58};

// Bascule S-R avec EN
// D24: Enable
// Q38: /Set
// P35: /Reset
// Q32: Q
assign Q33 = ~&{D24, Q38};
assign P33 = ~&{D24, P35};
assign P32 = ~&{Q32, P33};
assign Q32 = ~&{PIN_58, Q33, P32};

reg H4, H2, U16, H1, U24, U34, U36, Q10B, D25, C28B;

assign sH16 = ~nPIN_H16;

always @(posedge sH16 or negedge nPIN_SYCL) begin
	if (!nPIN_SYCL) begin
		H4 <= 1'b0;
		H2 <= 1'b0;
		U16 <= 1'b0;
		H1 <= 1'b0;
		U24 <= 1'b0;
		U34 <= 1'b0;
		U36 <= 1'b0;
		Q10B <= 1'b0;
		D25 <= 1'b0;
		C28B <= 1'b0;
	end else begin
		D25 <= E11;
	
		Q10B <= PIN_nCKLP;

    	U16 <= ~U16;	// 8MHz

    	if (U16)
			H4 <= ~H4;	// 4MHz

    	if (U16 & H4)
			H2 <= ~H2;	// 2MHz

    	if (H2 & U16 & H4)
			H1 <= ~H1;	// 1MHz

    	if (~H2 & U16 & H4)
			U24 <= ~U24;	// 1MHz, phase differente
			
		if (~(H2 & (H4 | U16)))	// Erreur ?
			U36 <= ~U36;
			
		U34 <= &{~U16, H2, H4, ~H1};	// E17
		
		C28B <= E9;
	end
end

assign F14 = H38A | ~H1;	// D16 = ~H1

reg G18A, G38B;
reg [5:0] TL;

assign M43 = PIN_58 & ~&{H38A, Q38, PIN_58};


assign G15 = ~H1;	// D16;

// Compteur synchrone
assign H24 = TL[1] & TL[0];	// G20B = TL[0] ?
assign H27 = TL[2] & H24;	// G23B = TL[2] ?
assign H31 = TL[3] & H27; 	// G29B = TL[3] ?
assign H34 = TL[4] & H31; 	// G33B = TL[4] ?

always @(posedge G15 or negedge PIN_58) begin
	if (!PIN_58) begin
		G18A <= 1'b1;
		G38B <= 1'b0;
		TL[5:0] <= 6'd0;
	end else begin
		G18A <= ~J26;
		G38B <= ~|{J33, J27};

		TL[0] <= ~TL[0];	// 500kHz ?

		if (TL[0])	// U85	G20B = TL[0] ?
			TL[1] <= ~TL[1];	// 250kHz ?

		if (H24)	// U87
			TL[2] <= ~TL[2];	// 125kHz ?

		if (H27)	// U89
			TL[3] <= ~TL[3];	// 62.5kHz ?

		if (H31)	// U91
			TL[4] <= ~TL[4];	// 31.25kHz ?

		if (H34)	// U93
			TL[5] <= ~TL[5];	// 15.625kHz ?
	end
end

reg U64;
always @(posedge F14 or negedge PIN_58) begin
	if (!PIN_58)
		U64 <= 1'b0;
	else
		U64 <= N6;
end

reg [13:3] T;

// Compteur synchrone
assign M11 = T[3] & H27;
assign M14 = T[4] & M11;
assign M18 = T[5] & M14;
assign M21 = T[6] & M18;
assign M24 = T[7] & M21;
assign M27 = T[8] & M24;
assign M31 = T[9] & M27;
assign M34 = T[10] & M31;
assign M37 = T[11] & M34;
assign M40 = T[12] & M37;

always @(posedge F14 or negedge M43) begin
	if (!M43) begin
		T <= 11'd0;
	end else begin
		if (H27)	// U67
			T[3] <= ~T[3];

		if (M11)	// U62
			T[4] <= ~T[4];

		if (M14)	// U69
			T[5] <= ~T[5];

		if (M18)	// U65
			T[6] <= ~T[6];

		if (M21)	// U79
			T[7] <= ~T[7];

		if (M24)	// U75
			T[8] <= ~T[8];

		if (M27)	// U71
			T[9] <= ~T[9];

		if (M31)	// U81
			T[10] <= ~T[10];

		if (M34)	// U77
			T[11] <= ~T[11];

		if (M37)	// U73
			T[12] <= ~T[12];

		if (M40)	// U40
			T[13] <= ~T[13];
	end
end

//assign N27 = ~&{T[8], T[6], ~T[7], T[9]};	// M23 = ~T[7]
assign N27 = ~(T[9:6] == 4'b1101);

assign D24 = U34;
assign Q37 = ~&{PIN_36 ? ~|{N28, N37} : ~&{N36, N28, N16}, G38B};
assign Q38 = ~&{P38, Q37};
assign P35 = ~|{N27, N34};

// Drivers de sortie inverseurs
assign PIN_43 = U16;		// ~U16
assign nE = ~H1;			// H1
assign E = H1;				// ~H1
assign Q = U24;				// ~U24
assign PIN_nRAS = ~U36;		// U36
assign PIN_DVALID = ~U34;	// U34

assign PIN_nSUPLT = R23 & J11;		// Driver de sortie inverseur
assign PIN_nINILT = ~(Q32 & ~H38A);	// Driver de sortie inverseur
assign PIN_SYNLT = ~(H15 ^ Q28);    // Driver de sortie inverseur
assign PIN_59 = U64;				// Driver de sortie inverseur
assign PIN_nITLP = ~(Q8B & Q13B);	// Driver de sortie inverseur

assign nPIN_FORME = ~PIN_FORME;		// Driver d'entrée inverseur
assign nPIN_SYCL = ~PIN_SYCL;		// Driver d'entrée inverseur
assign nPIN_H16 = ~PIN_H16;     	// Driver d'entrée inverseur
assign PIN_POINT = ~U16;     		// Driver d'entrée inverseur

endmodule
