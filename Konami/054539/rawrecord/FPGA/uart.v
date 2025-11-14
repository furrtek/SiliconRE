// divisor must be == sys_clk/baudrate/16
// rx_done is high during 1 sys_clk

module uart(
	input sys_rst,
	input sys_clk,
	input sys_clk_en,
	
	input uart_rx,
	output reg uart_tx,

	input [15:0] divisor,

	output reg [7:0] rx_data,
	output reg rx_done,
	
	input [7:0] tx_data,
	input tx_trig,
	output reg tx_done
);

// Baudrate*16 generator
reg [15:0] enable16_counter;

wire enable16;
assign enable16 = (enable16_counter == 16'd0);

always @(posedge sys_clk or posedge sys_rst) begin
	if (sys_rst)
		enable16_counter <= divisor - 16'd1;		// Reload
	else begin
		if (sys_clk_en) begin
			if (enable16)
				enable16_counter <= divisor - 16'd1;	// Reload
			else
				enable16_counter <= enable16_counter - 16'd1;	// Count down
		end
	end
end

// Synchronize uart_rx
reg uart_rx1;
reg uart_rx2;

always @(posedge sys_clk) begin
	if (sys_clk_en) begin
		uart_rx1 <= uart_rx;
		uart_rx2 <= uart_rx1;
	end
end

// UART RX Logic
reg rx_busy;
reg [3:0] rx_count16;
reg [3:0] rx_bitcount;
reg [7:0] rx_reg;

always @(posedge sys_clk or posedge sys_rst) begin
	if (sys_rst) begin
		rx_done <= 1'b0;
		rx_busy <= 1'b0;
		rx_count16  <= 4'd0;
		rx_bitcount <= 4'd0;
	end else begin
		if (sys_clk_en) begin
			rx_done <= 1'b0;

			if (enable16) begin
				if (~rx_busy) begin			// Wait for start bit
					if (~uart_rx2) begin 	// Start bit found
						rx_busy <= 1'b1;		// We're now busy
						rx_count16 <= 4'd7;	// Sampling timer reload to mid-bit value
						rx_bitcount <= 4'd0;
					end
				end else begin
					rx_count16 <= rx_count16 + 4'd1;

					if (rx_count16 == 4'd0) begin			// Sample
						rx_bitcount <= rx_bitcount + 4'd1;

						if (rx_bitcount == 4'd0) begin	// Verify start bit
							if (uart_rx2)
								rx_busy <= 1'b0;				// Abort rx if not low
						end else if (rx_bitcount == 4'd9) begin
							rx_busy <= 1'b0;					// Done receving all 10 symbols
							if (uart_rx2) begin 				// Verify stop bit
								rx_data <= rx_reg;
								rx_done <= 1'b1;
							end
							// Ignore RX error
						end else
							rx_reg <= {uart_rx2, rx_reg[7:1]};	// Shift in new bit
					end
				end
			end
		end
	end
end

// UART TX Logic
reg tx_busy;
reg [3:0] tx_count16;
reg [3:0] tx_bitcount;
reg [7:0] tx_reg;

always @(posedge sys_clk or posedge sys_rst) begin
	if (sys_rst) begin
		tx_busy <= 1'b0;
		tx_done <= 1'b0;
		tx_count16 <= 4'd0;
		tx_bitcount <= 4'd0;
		uart_tx <= 1'b1;
	end else begin
		if (sys_clk_en) begin
			if (tx_done)
				tx_done <= 1'b0;
			
			if (tx_trig) begin		// Wait for trigger
				tx_busy <= 1'b1;		// We're now busy
				tx_count16 <= 4'd0;	// Output timer reset
				tx_bitcount <= 4'd0;
				tx_reg <= tx_data;	// Load data into shift register
			end
			
			if (enable16) begin
				if (tx_busy) begin
					if (tx_count16 == 4'd0) begin			// Next symbol
						if (tx_bitcount == 4'd0) begin
							uart_tx <= 1'b0;		// Start bit
						end else if (tx_bitcount == 4'd9) begin
							uart_tx <= 1'b1;		// Stop bit
						end else if (tx_bitcount == 4'd10) begin
							tx_busy <= 1'b0;		// Done sending all 10 symbols
							tx_done <= 1'b1;
						end else begin
							uart_tx <= tx_reg[0];
							tx_reg <= {1'b0, tx_reg[7:1]};
						end
						
						tx_bitcount <= tx_bitcount + 4'd1;
					end
					
					tx_count16 <= tx_count16 + 4'd1;
				end
			end
		end
	end
end

endmodule
