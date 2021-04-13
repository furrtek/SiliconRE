// Konami 007452 "VRC&DMP"
// Reverse-engineered from silicon - See schematic
// furrtek 2021

module k007452_top(
    input [2:0] AB_L,
    input [15:12] AB_H,
    input CS12, SLTS, RD, WR, CLK, RES, K8,
    input [1:0] SEL,
    inout [7:0] DB,
    output [6:1] Y,
    output OE1, OE2
);

    reg B34, A28;
    reg D35, D28, C35, C28;
    reg [3:0] P8;
    reg [15:0] acc_reg;
    wire [7:0] DB_OUT;
    wire D25;
    wire E20, H20, H2, H15;
    wire H4, H6, G20, H17;
    wire J23, H8, H10, H12, H22, H24, H26, J35;
    wire K21, K2, K23, K1, K34, K12, K4, K19;
    wire H32, E36, nC56, nB42, C54;
    wire nRES;
    wire [3:0] M50;
    wire [3:0] N49;
    wire [3:0] P50;
    wire [3:0] R46;
    wire [3:0] L3;
    wire [3:0] M4;
    wire [3:0] R29;
    wire [3:0] N29;
    wire [3:0] L42;
    wire [3:0] K62;
    wire [3:0] H71;
    wire [3:0] H58;
    wire [3:0] A59;
    wire [3:0] B60;

    assign nRES = ~RES;

    C41 Cell_A59(nF63, F70, A59);

    FDO Cell_B49(~A59[3], nB49, F70, B49, nB49);
    assign D51 = ~|{nRES, B49};

    C41 Cell_B60(~CLK, F77, B60);
    assign C53 = ~|{nRES, B60[3]};

    FDO Cell_F70(C63[3], 1'b1, D51, F70, nF70);
    FDO Cell_F77(C63[1], 1'b1, C53, F77, );
    assign A83 = ~|{~CLK, nF70};
    assign H36 = ~&{CLK, F77};

    FDO Cell_F63(~CLK, nF63, F25, F63, nF63);
    assign E74 = F63 & F70;

    FDN Cell_C56(A83, E74, RES, , nC56);
    assign C52 = ~|{nC56, E74};
    assign C51 = ~|{C52, nRES};

    FDO Cell_B42(E74, E58_CO, C51, , nB42);
    assign C54 = ~nB42;
    assign H53 = ~C54;
    
    assign G41 = ~&{A83, E74};
    assign A56 = ~&{nB42, E74};
    assign B58 = &{A56, A83};

    assign E36 = 1; // DEBUG ~|{SLTS, B22, B34, A28, D35, D28, C35, C28};

    wire H37 = |{~E36, RD};
    assign D25 = ~|{H37, AB_L[1]};
    wire D26 = ~|{H37, AB_L[2]};
    wire DB_DIR = ~|{D25, D26};
    
    assign DB = DB_DIR ? 8'bzzzz_zzzz : DB_OUT;

    T5A Cell_A44(Y[2], Y[3], Y[4], Y[3], SEL[0], ~SEL[0], SEL[1], A44);

    wire H39 = ~|{~E36, RD};
    wire H40 = ~|{SLTS, CS12, H39};
    assign OE1 = ~&{A44, H40};
    assign OE2 = ~&{~A44, H40};
    
    assign H32 = ~|{WR, ~E36};

    wire H34 = ~|{WR, SLTS, ~AB_H[12]};
    wire E34 = ~&{K8, AB_H[13]};

    reg [3:0] C63;
    always @(negedge CLK)
        C63 <= {C63[2], F25, C63[0], F23};



    T5A Cell_G35(B3, B34, A12, C14, ~B33, B33, AB_H[14], Y[1]);
    T5A Cell_F37(B17, A28, A11, C20, ~B33, B33, AB_H[14], Y[2]);
    T5A Cell_F28(C21, D35, A10, C11, ~B33, B33, AB_H[14], Y[3]);
    T5A Cell_B28(B14, D28, A9, C23, ~B33, B33, AB_H[14], Y[4]);
    T5A Cell_E29(C4, C35, A2, C8, ~B33, B33, AB_H[14], Y[5]);
    T5A Cell_A36(B6, C28, A5, C22, ~B33, B33, AB_H[14], Y[6]);

    T5A Cell_J13(1'b0, E20, K21, H10, D25, ~D25, D26, DB_OUT[0]);
    T5A Cell_J18(1'b0, H20, K2, H8, D25, ~D25, D26, DB_OUT[1]);
    T5A Cell_J8(1'b0, H2, K23, H26, D25, ~D25, D26, DB_OUT[2]);
    T5A Cell_J30(1'b0, H15, K10, H22, D25, ~D25, D26, DB_OUT[3]);
    T5A Cell_J37(1'b0, H4, K34, J35, D25, ~D25, D26, DB_OUT[4]);
    T5A Cell_J25(1'b0, H6, K12, J23, D25, ~D25, D26, DB_OUT[5]);
    T5A Cell_J2(1'b0, G20, K4, H12, D25, ~D25, D26, DB_OUT[6]);
    T5A Cell_K14(1'b0, H17, K19, H24, D25, ~D25, D26, DB_OUT[7]);


    // Address decode
    wire G26 = ~&{~AB_L[0], ~AB_L[1], ~AB_L[2], H32};    // 000
    wire F23 = ~&{AB_L[0], ~AB_L[1], ~AB_L[2], H32};     // 001
    wire G24 = ~&{~AB_L[0], AB_L[1], ~AB_L[2], H32};     // 010
    wire G22 = ~&{AB_L[0], AB_L[1], ~AB_L[2], H32};      // 011
    wire F21 = ~&{~AB_L[0], ~AB_L[1], AB_L[2], H32};     // 100
    wire F25 = ~&{AB_L[0], ~AB_L[1], AB_L[2], H32};      // 101

    wire B7 = ~&{~AB_H[15], AB_L[14], H34, ~E34};
    wire B9 = ~&{~AB_H[15], AB_L[14], E34, H34};
    wire B22 = ~&{AB_H[15], ~AB_L[14], AB_L[12], E34};
    wire B24 = ~&{AB_H[15], ~AB_L[14], H34, E34};
    wire B26 = ~&{AB_H[15], ~AB_L[14], H34, ~E34};


    // Set and reset for A28 and B34, which is which ?
    wire F33 = ~&{nRES, ~K8};
    wire A41 = ~&{nRES, K8};

    always @(posedge B24 or negedge F33 or negedge A41) begin
        if (!F33) begin
            B34 <= 1'b1;
            A28 <= 1'b1;
        end else if (!A41) begin
            B34 <= 1'b0;
            A28 <= 1'b0;
        end else begin
            B34 <= ~DB[0];
            A28 <= ~DB[1];
        end
    end

    // Bank 011
    wire B1 = ~((~DB[0]&~B26)|(B26&B3));
    wire B3 = ~(nRES | B1);
    wire B18 = ~((~DB[1]&~B26)|(B26&B17));
    wire B17 = ~(nRES | B18);
    wire B12 = ~((~DB[2]&~B26)|(B26&C21));
    wire C21 = ~(RES & B12);
    wire B15 = ~((~DB[3]&~B26)|(B26&B14));
    wire B14 = ~(RES & B15);
    wire C2 = ~((~DB[4]&~B26)|(B26&C4));
    wire C4 = ~(RES & C2);
    wire B4 = ~((~DB[5]&~B26)|(B26&B6));
    wire B6 = ~(RES & B4);

    // Bank 101
    wire A19 = ~((~DB[0]&~B9)|(B9&A12));
    wire A12 = ~(RES & A19);
    wire A17 = ~((~DB[1]&~B9)|(B9&A11));
    wire A11 = ~(RES & A17);
    wire A15 = ~((~DB[2]&~B9)|(B9&A10));
    wire A10 = ~(RES & A15);
    wire A13 = ~((~DB[3]&~B9)|(B9&A9));
    wire A9 = ~(RES & A13);
    wire A22 = ~((~DB[4]&~B9)|(B9&A2));
    wire A2 = ~(RES & A22);
    wire A3 = ~((~DB[5]&~B9)|(B9&A5));
    wire A5 = ~(RES & A3);

    // Bank 111
    wire C15 = ~((~DB[0]&~B7)|(B7&C14));
    wire C14 = ~(nRES | C15);
    wire C18 = ~((~DB[1]&~B7)|(B7&C20));
    wire C20 = ~(RES & C18);
    wire C12 = ~((~DB[2]&~B7)|(B7&C11));
    wire C11 = ~(RES & C12);
    wire C26 = ~((~DB[3]&~B7)|(B7&C23));
    wire C23 = ~(RES & C26);
    wire C9 = ~((~DB[4]&~B7)|(B7&C8));
    wire C8 = ~(RES & C9);
    wire C24 = ~((~DB[5]&~B7)|(B7&C22));
    wire C22 = ~(RES & C24);



    FS3 Cell_L3({DB[0], DB[1], DB[2], DB[3]}, M4[3], H36, F23, L3);
    FS3 Cell_M4({DB[4], DB[5], DB[6], DB[7]}, M38, H36, F23, M4);

    assign R28 = ~|{R29[0], ~L3[3]};
    assign R27 = ~|{R29[1], ~L3[3]};
    assign R26 = ~|{R29[2], ~L3[3]};
    assign R25 = ~|{R29[3], ~L3[3]};

    assign L37 = ~|{N29[0], ~L3[3]};
    assign N19 = ~|{N29[1], ~L3[3]};
    assign N18 = ~|{N29[2], ~L3[3]};
    assign N28 = ~|{N29[3], ~L3[3]};

    assign N16 = R25 & P8[0];
    assign M38 = R25 ^ P8[0];
    A1N Cell_R1(R26, P8[1], N16, R1_S, R1_CO);
    A1N Cell_R17(R27, P8[2], R1_CO, R17_S, R17_CO);
    A1N Cell_R9(R28, P8[3], R17_CO, R9_S, R9_CO);
    A1N Cell_P34(N28, P1, R9_CO, P34_S, P34_CO);
    A1N Cell_N20(N18, N1, P34_CO, N20_S, N20_CO);
    A1N Cell_N8(N19, K27, N20_CO, N8_S, N8_CO);

    always @(posedge H36 or negedge G26) begin
        if (!G26)
            P8 <= 4'b0000;
        else
            P8 <= {P34_S, R9_S, R17_S, R1_S}; //P8 <= small_adder[4:1];
    end

    FDO Cell_P1(H36, N20_S, G26, P1, );
    FDO Cell_N1(H36, N8_S, G26, N1, );
    FDO Cell_K27(H36, L37 ^ N8_CO, G26, K27, );
    
    assign M38 = R25 ^ P8[0];

    LT4 Cell_R29({DB[0], DB[1], DB[2], DB[3]}, G26, , R29);
    LT4 Cell_N29({DB[4], DB[5], DB[6], DB[7]}, G26, , N29);



    assign J23 = ~(AB_L[0] ? D42 : J77);
    assign H8 = ~(AB_L[0] ?  H42 : M42);
    assign H10 = ~(AB_L[0] ? G42 : P42);
    assign H12 = ~(AB_L[0] ? E49 : J53);
    assign H22 = ~(AB_L[0] ? G49 : J42);
    assign H24 = ~(AB_L[0] ? E42 : F56);
    assign H26 = ~(AB_L[0] ? F42 : L77);
    assign J35 = ~(AB_L[0] ? C42 : J62);

    assign K21 = ~(AB_L[0] ? P8[0] : L3[3]);
    assign K2 = ~(AB_L[0] ?  P8[1] : L3[2]);
    assign K23 = ~(AB_L[0] ? P8[2] : L3[1]);
    assign K10 = ~(AB_L[0] ? P8[3] : L3[0]);
    assign K34 = ~(AB_L[0] ? P1    : M4[3]);
    assign K12 = ~(AB_L[0] ? N1    : M4[2]);
    assign K4 = ~(AB_L[0] ?  K27   : M4[1]);
    assign K19 = ~(AB_L[0] ? 1'b0  : M4[0]);

    reg [3:0] D3;
    reg [3:0] F2;
    reg [3:0] E2;
    reg [3:0] G2;
    always @(negedge G41) begin
        D3 <= {D3[2:0], ~nB42};
        F2 <= {F2[2:0], D3[3]};
        E2 <= {E2[2:0], F2[3]};
        G2 <= {G2[2:0], E2[3]};
    end

    assign E20 = ~(AB_L[0] ? E2[0] : D3[0]);
    assign H20 = ~(AB_L[0] ? E2[1] : D3[1]);
    assign H2 = ~(AB_L[0] ?  E2[2] : D3[2]);
    assign H15 = ~(AB_L[0] ? E2[3] : D3[3]);
    assign H4 = ~(AB_L[0] ?  G2[0] : F2[0]);
    assign H6 = ~(AB_L[0] ?  G2[1] : F2[1]);
    assign G20 = ~(AB_L[0] ? G2[2] : F2[2]);
    assign H17 = ~(AB_L[0] ? G2[3] : F2[3]);

    LT4 Cell_L42({DB[0], DB[1], DB[2], DB[3]}, G22, , L42);
    LT4 Cell_K62({DB[4], DB[5], DB[6], DB[7]}, G22, , K62);
    LT4 Cell_H71({DB[0], DB[1], DB[2], DB[3]}, G24, , H71);
    LT4 Cell_H58({DB[4], DB[5], DB[6], DB[7]}, G24, , H58);

    FS3 Cell_M50(DB[3:0], 1'b0, E74, F25, M50);
    FS3 Cell_N49(DB[7:4], M50[3], E74, F25, N49);
    FS3 Cell_P50(DB[3:0], N49[3], E74, F21, P50);
    FS3 Cell_R46(DB[7:4], P50[3], E74, F21, R46);

    assign N42 = ~^{L42[3], P42};
    wire N46 = L42[3] | P42;

    A1N Cell_L60(M42, L42[2], N46, L60_S, L60_CO);
    A1N Cell_L68(L77, L42[1], L60_CO, L68_S, L68_CO);
    A1N Cell_K42(J42, L42[0], L68_CO, K42_S, K42_CO);

    A1N Cell_K53(J62, K62[3], K42_CO, K53_S, K53_CO);
    A1N Cell_K76(J77, K62[2], K53_CO, K76_S, K76_CO);
    A1N Cell_J69(J53, K62[1], K76_CO, J69_S, J69_CO);
    A1N Cell_G68(F56, K62[0], J69_CO, G68_S, G68_CO);

    A1N Cell_G60(G42, H71[3], G68_CO, G60_S, G60_CO);
    A1N Cell_G76(H42, H71[2], G60_CO, G76_S, G76_CO);
    A1N Cell_D76(F42, H71[1], G76_CO, D76_S, D76_CO);
    A1N Cell_D68(G49, H71[0], D76_CO, D68_S, D68_CO);

    A1N Cell_D60(C42, H58[3], D68_CO, D60_S, D60_CO);
    A1N Cell_E76(D42, H58[2], D60_CO, E76_S, E76_CO);
    A1N Cell_E66(E49, H58[1], E76_CO, E66_S, E66_CO);
    A1N Cell_E58(E42, H58[0], E66_CO, E58_S, E58_CO);

    always @(posedge B58 or negedge F25) begin
        if (!F25)
            acc_reg <= 16'h0000;
        else
            acc_reg <= ((~C54) ? {E49, D42, C42, G49, F42, H42, G42, F56, J53, J77, J62, J42, L77, M42, P42, R46[3]} : {E58_S, E66_S, E76_S, D60_S, D68_S, D76_S, G76_S, G60_S, G68_S, J69_S, K76_S, K53_S, K42_S, L68_S, L60_S, N42}); // Is this the right order ?
    end

    assign E42 = acc_reg[15];
    assign E49 = acc_reg[14];
    assign D42 = acc_reg[13];
    assign C42 = acc_reg[12];
    assign G49 = acc_reg[11];
    assign F42 = acc_reg[10];
    assign H42 = acc_reg[9];
    assign G42 = acc_reg[8];
    assign F56 = acc_reg[7];
    assign J53 = acc_reg[6];
    assign J77 = acc_reg[5];
    assign J62 = acc_reg[4];
    assign J42 = acc_reg[3];
    assign L77 = acc_reg[2];
    assign M42 = acc_reg[1];
    assign P42 = acc_reg[0];

    always @(posedge B24 or negedge RES) begin
        if (!RES) begin
            D35 <= 1'b1;
            D28 <= 1'b1;
            C35 <= 1'b1;
            C28 <= 1'b1;
        end else begin
            D35 <= ~DB[2];
            D28 <= ~DB[3];
            C35 <= ~DB[4];
            C28 <= ~DB[5];
        end
    end

endmodule

module FDO(
    input CLK,
    input D,
    input nR,
    output reg Q,
    output nQ
);
    always @(posedge CLK or negedge nR) begin
        if (!nR)
            Q <= 1'b0;
        else
            Q <= D;
    end
    assign nQ = ~Q;
endmodule

module FDN(
    input CLK,
    input D,
    input nS,
    output reg Q,
    output nQ
);
    always @(posedge CLK or negedge nS) begin
        if (!nS)
            Q <= 1'b1;
        else
            Q <= D;
    end
    assign nQ = ~Q;
endmodule

module C41(
    input CLK,
    input nCL,
    output reg [3:0] Q
);
    always @(posedge CLK or negedge nCL) begin
        if (!nCL)
            Q <= 4'd0;
        else
            Q <= Q + 1'b1;
    end
endmodule

module FS3(
    input [3:0] P,
    input SD,
    input CLK,
    input nL,
    output reg [3:0] Q
);
    always @(posedge CLK or negedge nL) begin
        if (!nL) begin
            Q <= P;
        end else begin
            Q <= {Q[2:0], SD};
        end
    end
endmodule

module LT4(
    input [3:0] D,
    input nG,
    output reg [3:0] P,
    output [3:0] N
);
    always @(*) begin
        if (!nG)
            P <= D;
    end
    
    assign N = ~P;
endmodule

module T5A(
    input A1, A2, B1, B2,
    input S1, S3, S5,
    output nX
);
    assign nX = ~(S5 ? S3 ? B2 : B1 : S1 ? A2 : A1);
endmodule

module A1N(
    input A, B, CI,
    output S, CO
);
    wire [1:0] adder;
    assign adder = A + B + CI;
    assign S = adder[0];
    assign CO = adder[1];
endmodule
