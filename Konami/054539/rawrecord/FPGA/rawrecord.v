// Basically an I2S/"MSB aligned" to serial converter
// GPIO_0[3:0] = {TXD, DS, WS, CK}
// Use FTDI cable at 3Mbps and python script to record data, Teraterm is too slow

// Actually not I2S: data isn't shifted one bit related to WS
// Several samples and BGMs start with a negative sample value, which is exactly aligned with WS(LRCK)
// Also, looking at samples synchronized to WS on the scope with persistance set high, it's clear that the data is MSB aligned to WS: there's never any transitions in the top 6 bits
// they're all either 0 or 1's, at any point in any BGM. If we had I2S, there would at least be a transition after the 1st bit from time to time, when the prev word LSB doesn't match the next word's sign bit.
// Always this:
// WS ########X################X########...
// DS XXXXXXXXX######XXXXXXXXXXX######XX...
// Never this:
// WS ########X################X########...
// DS XXXXXXXXXX######XXXXXXXXXXX######X...
//             ^                ^

// If it were real I2S with the LSB of the last word shifted into the new WS state, WS would change and -then- DS would go from 0 to 1 on the next CK edge

// Real I2S:
// CK _#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#
// WS ________________________________################################__________________________________
// DS   151413121110090807060504030201001514131211100908070605040302010015141312111009080706050403020100
// ch   LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

// What comes in the Konami volume/DAC module (presumably, 99% sure):
// CK _#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#
// WS ________________________________################################________________________________
// DS 151413121110090807060504030201001514131211100908070605040302010015141312111009080706050403020100
// ch LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL

// If it is read as I2S, data is shifted left one bit (value * 2) and the LSB is the sign bit of the next word
// Because it appears that amplitude is always quite low (at least on metamrph), where the top 5 bits appear to never be used, reading as I2S and "eating up" the sign bit of the next word
// doesn't cause any issues obvious to the ear because the value MSB (bit #14, on the right of the sign bit) replicates the sign bit
// i.e. min/max values are around +1023/-1024 so $03FF/$FC00
// $03FF then $FC00 read as real I2S would be $07FF $F800:
// 0000 0011 1111 1111    1111 1100 0000 0000
// 0000 0111 1111 1111    1111 1000 0000 000x

// I can't think of any way to be 100% sure that data is "MSB aligned" instead of I2S, except force the soundchip to output loud samples that use the whole 15-bit range and check if wrapping occurs on the dump
// So the dumps assume "MSB aligned" data, but can be converted losslessly to I2S if it's found out they should be (very unlikely !). They're left channel first, big endian, 48kHz stereo.

module rawrecord (
    input  [3:0] KEY,
    input  [1:0] CLOCK_24,
    inout  [35:0] GPIO_0,
	 output [7:0] LEDG,
	 output [9:0] LEDR
);

pll PLL_inst(
	CLOCK_24[0],
	pll_out,			// 48MHz
	locked);

assign LEDG[0] = locked;
assign LEDG[1] = ~|{rst_delay};
assign LEDG[2] = tx_trig;

assign LEDR = vumeter;

uart UART (
	.sys_rst(~KEY[0]),
	.sys_clk(pll_out),
	.sys_clk_en(1'b1),
	.uart_rx(),				// Unused
	.uart_tx(GPIO_0[3]),
	.divisor(16'd1),		// 48000000/(3000000*16) 2Mbaud
	.rx_data(),				// Unused
	.rx_done(),				// Unused
	.tx_data(tx_data[15:8]),
	.tx_trig(tx_trig),
	.tx_done(tx_done)
);

reg [2:0] IIS_SCK_sr;
reg [2:0] IIS_WS_sr;
reg [2:0] IIS_SD_sr;
reg [15:0] data_sr;
reg [15:0] tx_data;
reg tx_trig;
reg tx_state;
//reg channel;
reg prev_channel;
reg [15:0] test_counter;
reg [9:0] vumeter;
reg [7:0] tx_countdown;
reg [23:0] rst_delay;
reg send;

assign GPIO_0[4] = tx_trig;

assign GPIO_0[2:0] = 3'bzzz;	// Inputs

assign IIS_SCK = GPIO_0[0];
assign IIS_WS = GPIO_0[1];
assign IIS_SD = GPIO_0[2];

reg [15:0] div_zero;

// 48000 * 2 * 16 = 1536000 bps = 192000 bytes/s
// 3Mbaud = 2.4Mbps

// 651ns/bit
// 10.416us/word
// 333ns/symbol
// Time for 31 symbols = 2 * 10 for data + 11 margin

assign channel = IIS_WS_sr[2];

always @(posedge pll_out or negedge KEY[0]) begin
	if (!KEY[0]) begin
		IIS_SCK_sr <= 3'd0;
		IIS_WS_sr <= 3'd0;
		IIS_SD_sr <= 3'd0;
		tx_trig <= 1'b0;
		tx_state <= 1'b0;
		test_counter <= 16'd0;
		div_zero <= 16'd0;
		tx_countdown <= 8'd0;
		rst_delay <= 24'hffffff;
		send <= 1'b0;
	end else begin
		IIS_SCK_sr <= {IIS_SCK_sr[1:0], IIS_SCK};	// <-
		IIS_WS_sr <= {IIS_WS_sr[1:0], IIS_WS};		// <-
		IIS_SD_sr <= {IIS_SD_sr[1:0], IIS_SD};		// <-
		
		if (tx_trig)
			tx_trig <= 1'b0;
		
		if (tx_done) begin
			if (tx_state) begin
				tx_countdown <= 8'd4;
			end
		end
		
		if (tx_countdown) begin
			tx_countdown <= tx_countdown - 1'b1;
			if (tx_countdown == 8'd1) begin
				// Second byte
				tx_data <= {tx_data[7:0], 8'd0};
				tx_trig <= 1'b1;
				tx_state <= 1'b0;
			end
		end
		
		/*if (tx_state == 8'd4) begin
			// Second byte
			tx_data <= {tx_data[7:0], 8'd0};
			tx_trig <= 1'b1;
			tx_state <= 1'b0;
		end else
			tx_state <= tx_state + 1'b1;*/
		
		if (IIS_SCK_sr[2:1] == 2'b01) begin
			// SCK rising edge
			if (!rst_delay) begin
				data_sr <= {data_sr[14:0], IIS_SD_sr[2]};	// <-

				// WS     ########________########________
				// send   _________#######################
				// tx     _________________MMMLLL__MMMLLL_
				
				if (channel != prev_channel) begin
					// New channel
					
					// Always start transmitting left channel
					if (!channel)
						send <= 1'b1;
					
					if (send) begin
						tx_data <= data_sr;	//test_counter;	//data_sr;
						tx_state <= 1'b1;		// First byte
						tx_trig <= 1'b1;
						
						vumeter <= data_sr[15] ? ~data_sr[14:5] : data_sr[14:5];	// Absolute value
					end
					
					//test_counter <= test_counter + 1'b1;
				end
				
				prev_channel <= channel;
			end
		end
		
		if (rst_delay)
			rst_delay <= rst_delay - 1'b1;
		
		/*if (div_zero == 16'd499) begin
			div_zero <= 16'd0;
			tx_data <= test_counter;	//data_sr;
			tx_state <= 1'b1;		// First byte
			tx_trig <= 1'b1;
			
			test_counter <= test_counter + 1'b1;
		end else
			div_zero <= div_zero + 1'b1;*/
	
	end
end


endmodule
