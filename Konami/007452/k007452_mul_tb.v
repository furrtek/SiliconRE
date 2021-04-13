// Konami 007452 "VRC&DMP"
// Multiplier testbench
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
reg [15:0] RESULT;

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

    for (integer c = 0; c < 32768; c++) begin
        #2 AB_L <= 0;
        DB_OUT <= {1'b0, c[6:0]};
        #2 WR <= 0;
        #2 WR <= 1;
        #2 AB_L <= 1;
        DB_OUT <= c[14:7];
        #2 WR <= 0;
        #2 WR <= 1;
        
        repeat(12) @(negedge CLK);

        AB_L <= 0;
        #2 RD <= 0;
        #1 RESULT[7:0] <= DB;
        #1 RD <= 1;
        AB_L <= 1;
        #1 RD <= 0;
        #1 RESULT[15:8] <= DB;
        #2 RD <= 1;

        if (RESULT != (c[14:7] * c[6:0])) begin
            $display("NOK :( A=%d B=%d RESULT=%d", c[14:7], c[6:0], RESULT);
            $finish;
        end
    end

	$finish;
end

endmodule
