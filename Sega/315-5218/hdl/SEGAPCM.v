// Sega 315-5218 "SegaPCM" discrete version from Space Harrier
// For simulation
// 2022 furrtek

module SEGAPCM(
	input CLK,             // 16M
	input nRESET,
	input nSRD, nSWR, nSCS,
	output nWAIT,
	output LGT, RGT,
	output [11:0] RSD,     // Audio output
	input [10:0] A,        // CPU address
	inout [7:0] D,         // CPU data
	output [9:0] AB,       // RAM address
	inout [15:0] DB,       // RAM data
	output reg [15:0] GA,  // ROM address
	input [7:0] GD,        // ROM data
	output nSOE,
	output [1:0] nWE,
	output nGL
);
    reg EQL;
    
    initial
        EQL <= 0;

    wire [2:0] SY;
    wire [6:0] WA;
    wire [15:0] DOUT;

    reg [1:0] CLKDIV;
    always @(posedge CLK or negedge nRESET) begin
        if (!nRESET)
            CLKDIV <= 2'd0;
        else
            CLKDIV <= CLKDIV + 1'b1;
    end
    assign CLK_8M = CLKDIV[0];
    assign CLK_n8M = ~CLK_8M;
    assign CLK_n4M = CLKDIV[1];
    
	// GLCPU low = CPU access slot

    // SRAM stuff
    assign S6E_4 = nSCS | A[0] | nSWR | CLK_n4M;	// Active low, CPU write even (LOW RAM)
    assign S6E_5 = nSCS | ~A[0] | nSWR | CLK_n4M;	// Active low, CPU write odd (HIGH RAM)

    assign {nWE, AB} = GLCPU ? {nWW, nWW, 3'b000, WA} : {S6E_5, S6E_4, A[10:1]};

    assign S6E_12 = nSCS | A[0] | GLCPU;
    assign S6E_11 = nSCS | ~A[0] | GLCPU;

    assign DOUT = S6E_12 ? S6E_11 ? 8'bzzzzzzzz : DB[15:8] : DB[7:0];
    assign D = nSRD ? 8'bzzzzzzzz : DOUT;

    wire [7:0] DIN;
    assign DIN = (S6E_11 & S6E_12) ? 8'bzzzzzzzz : D[7:0];
    assign DB[7:0] = nSRD & ~S6E_12 ? DIN : 8'bzzzzzzzz;
    assign DB[15:8] = nSRD & ~S6E_11 ? DIN : 8'bzzzzzzzz;
    
    assign nWAIT = ~WA[1] | nSCS;
    
    // DEBUG
    wire [3:0] CHANNEL = WA[5:2];

    // Sequencing
    reg [3:0] COUNTERL;     // 4F
    reg [3:0] COUNTERH;     // 4H

    always @(posedge CLK_n4M or negedge nRESET) begin
        if (!nRESET) begin
            {COUNTERH, COUNTERL} <= 8'h00;
        end else begin
            if (COUNTERL == 4'hF) begin
                COUNTERL <= 4'h8;
                if (COUNTERH == 4'hF)
                    COUNTERH <= 4'h0;	// COUNTERH <= 4'h8; ?
                else
                    COUNTERH <= COUNTERH + 1'b1;
            end else begin
                COUNTERL <= COUNTERL + 1'b1;
            end
        end
    end

    assign SY = COUNTERL[2:0];
    assign WA[5:2] = COUNTERH;
    assign CCY = (COUNTERH == 4'hF);    // On last channel

    // 6D SR
    reg [7:0] SR_6D;
    always @(posedge CLK_n4M) begin
        if (PAL_OUT9) begin
            SR_6D <= {SR_6D[6:0], 1'b1};
        end else begin
            SR_6D <= {DB[2], ADD_H[8], 1'b0, {2{DB[1]}}, DB[2], DB[3], DB[4]};
        end
    end
    assign ACY = SR_6D[7];

    // PAL equations
    assign WA[0] = ~((SY == 3'b011) | (SY == 3'b100) | (SY == 3'b101) | ((SY == 3'b111) & ACY & ~CLK_n4M));
    assign WA[1] = ~(((SY == 3'b110) & ~EQL) |
    				((SY == 3'b110) & ~ACY) |
                    ((SY == 3'b110) & CCY & EQL & ACY & ~CLK_n4M & CLK_n8M));
    assign WA[6] = (SY == 3'b001) | (SY == 3'b010) | (SY == 3'b011) | (SY == 3'b101) |
                    ((SY == 3'b110) & EQL & ACY & ~CLK_n4M) |
                    ((SY == 3'b110) & EQL & ACY & CLK_n4M & CLK_n8M) |
                    ((SY == 3'b111) & WA[6]); // Combinational loop :O
    assign nWW = ~(((SY == 3'b010) & ~ACY & ~CLK_n4M) |
                    ((SY == 3'b101) & ~CLK_n4M) |
                    ((SY == 3'b111) & ~ACY & ~CLK_n4M & WA[6]));
    assign DLLL = ~((SY == 3'b001) |
                    (SY == 3'b011) |
                    ((SY == 3'b100) & EQL) |
                    ((SY == 3'b110) & EQL & ACY));
    assign OGL = ((SY == 3'b011) & ACY) |
                    ((SY == 3'b110) & EQL & ACY);
    assign GLCPU = ~((SY == 3'b111) & ~WA[6]);
    assign LRLATCH = ((SY == 3'b110) & CCY & CLK_n4M & ~CLK_n8M) |
                    ((SY == 3'b110) & CCY & ~CLK_n4M & CLK_n8M);
    assign LRCLR = ~((SY == 3'b111) & CCY);
    assign PAL_OUT9 = ~((SY == 3'b001) | ((SY == 3'b001) & ~ACY));

    reg [7:0] REG_5C;
    always @(posedge WA[6])
        REG_5C <= DB[7:0];
        
    assign EQ = (REG_5C == DB[15:8]) & ADD_L[8];
    
    always @(posedge SY[2])     // Initial state ?
        if (EQ) EQL <= ~EQL;

    reg [7:0] DELTA;   // REG_3C
    always @(posedge WA[6] or negedge WA[0]) begin
        if (!WA[0])
            DELTA <= 8'h00;
        else
            DELTA <= DB[15:8];
    end

    wire [8:0] ADD_L;
    wire [8:0] ADD_H;

    assign ADD_L = DB[7:0] + OGL;
    assign ADD_H = ADD_L[8] + DB[15:8] + DELTA;

    reg [15:0] REG_W;   // 2CD, 4CD
    always @(posedge DLLL)
        REG_W <= {ADD_H, ADD_L};
    
    assign DB = nWW ? 16'bzzzzzzzz_zzzzzzzz : REG_W;


    always @(posedge WA[0])
        GA <= DB;


    assign SRMR = WA[0] | GLCPU;

    reg [15:0] SRA;
    reg [11:0] SRB;
    wire [12:0] GATED;

    always @(posedge CLK_n8M or negedge SRMR) begin
        if (!SRMR) begin
            SRA <= 16'h0000;
        end else begin
            if (WA[1]) begin
                SRA <= {SRA[14:0], 1'b0};
            end else begin
                SRA <= {2'b00, DB[8], DB[0], DB[9], DB[1], DB[10], DB[2], DB[11], DB[3], DB[12], DB[4], DB[13], DB[5], 2'b00};
            end
        end
    end

    always @(posedge CLK_n4M) begin
        if (GLCPU) begin
            SRB <= {SRB[10:0], 1'b0};
        end else begin
            SRB <= {{5{~GD[7]}}, GD[6:0]};  // Sign-extend
        end
    end

    assign GATED = SRA[15] ? {~GD[7], SRB} : 13'h0000;

    reg [15:0] REG_AL;
    reg [15:0] REG_AC;
    wire [15:0] ADD_MUL;
    wire [11:0] LC;

    assign ADD_MUL = REG_AC + {{4{GATED[12]}}, GATED[11:0]};

    always @(posedge CLK_n8M or negedge LRCLR) begin
        if (!LRCLR) begin
            REG_AL <= 16'h0000;
            REG_AC <= 16'h0000;
        end else begin
            REG_AL <= ADD_MUL;
            REG_AC <= REG_AL;
        end
    end

    // S9:
    // AL15 14 13 OUT1 OUT2 LC      Meaning
    //   0   0  0  0    0   Through Positive value <= 8191, use
    //   0   0  1  1    0   Max     Positive value, cap max
    //   0   1  0  1    0   Max     Positive value, cap max
    //   0   1  1  1    0   Max     Positive value, cap max
    //   1   0  0  0    1   Zero    Negative value, cap min
    //   1   0  1  0    1   Zero    Negative value, cap min
    //   1   1  0  0    1   Zero    Negative value, cap min
    //   1   1  1  0    0   Through Negative value >= -8192, use
    assign S9H_7 = ~REG_AL[15] & |{REG_AL[14:13]};
    assign S9H_9 = REG_AL[15] & ~&{REG_AL[14:13]};
    assign LC = S9H_9 ? 12'h000 : S9H_7 ? 12'hFFF : {~REG_AL[15], REG_AL[12:2]};

    assign LGT = ~WA[4] & ^{WA[3:2]};
    assign RGT = WA[4] & ^{WA[3:2]};

    reg [11:0] RSDL_REG;
    reg [11:0] RSDR_REG;

    always @(posedge LRLATCH)
        RSDL_REG <= LC;
    always @(negedge LRLATCH)
        RSDR_REG <= LC;

    assign RSD = WA[4] ? RSDR_REG : RSDL_REG;

endmodule
