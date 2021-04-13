// Konami 007452 "VRC&DMP"
// Divider testbench
// furrtek 2021

module tb();

parameter tck = 2; ///< clock period

reg CLK;
reg [2:0] AB_L;
reg [15:12] AB_H;
reg CS12, SLTS, RD, WR, RES, K8;
reg [1:0] SEL;
wire [7:0] DB;
reg [7:0] DB_OUT;
wire [6:1] Y;
wire OE1, OE2;
reg [31:0] RESULT;
reg [15:0] INA;
reg [15:0] INB;
reg PREV_INB;

k007452_top dut(
    AB_L,
    AB_H,
    CS12, SLTS, RD, WR, CLK, RES, K8,
    SEL,
    DB,
    Y,
    OE1, OE2
);

always #(tck/2) CLK <= ~CLK;

initial begin
	//$dumpfile("k007452.vcd");
	//$dumpvars(-1, dut);
end

assign DB = RD ? DB_OUT : 8'bzzzzzzzz;

initial begin
    RD <= 1;
    WR <= 1;
	CLK <= 0;
	RES <= 1;
	SLTS <= 1;

	#10 RES <= 0;
	#10 RES <= 1;
    #10

    for (integer c = 1; c < 65536; c++) begin
        // Dividing by zero gives quotient=FFFF remainder=0000
    	INA <= c[7:0];
    	INB <= c[15:8];
        #4 AB_L <= 2;
        DB_OUT <= INA[15:8];
        #2 WR <= 0;
        #2 WR <= 1;
        #2 AB_L <= 3;
        DB_OUT <= INA[7:0];
        #2 WR <= 0;
        #2 WR <= 1;
        #2 AB_L <= 4;
        DB_OUT <= INB[15:8];
        #2 WR <= 0;
        #2 WR <= 1;
        #2 AB_L <= 5;
        DB_OUT <= INB[7:0];
        #2 WR <= 0;
        #2 WR <= 1;
        
        repeat(34) @(negedge CLK);

        AB_L <= 5;
        #2 RD <= 0;
        #1 RESULT[31:24] <= DB;
        #1 RD <= 1;
        AB_L <= 4;
        #1 RD <= 0;
        #1 RESULT[23:16] <= DB;
        #2 RD <= 1;
        AB_L <= 3;
        #1 RD <= 0;
        #1 RESULT[15:8] <= DB;
        #2 RD <= 1;
        AB_L <= 2;
        #1 RD <= 0;
        #1 RESULT[7:0] <= DB;
        #2 RD <= 1;

        if ((RESULT[31:16] != (INB / INA)) || (RESULT[15:0] != (INB % INA))) begin
            $display("NOK :( INB=%H INA=%H RESULT=%H", INB, INA, RESULT);
            $finish;
        end
        
        if (INB[2] != PREV_INB)
            $display("%H00xx/00FF00FF ok", INB);
        PREV_INB <= INB[2];
    end

    $finish;
end

endmodule
