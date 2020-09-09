/*This module loads data into the TRDB LCM screen's control registers 
 * after system reset. 
 * 
 * Inputs:
 *   CLOCK_50 		- FPGA on board 50 MHz clock
 *   CLOCK2_50  	- FPGA on board 2nd 50 MHz clock
 *   KEY 			- FPGA on board pyhsical key switches
 *   FPGA_I2C_SCLK 	- FPGA I2C communication protocol clock
 *   FPGA_I2C_SDAT  - FPGA I2C communication protocol data
 *   AUD_XCK 		- Audio CODEC data
 *   AUD_DACLRCK 	- Audio CODEC data
 *   AUD_ADCLRCK 	- Audio CODEC data
 *   AUD_BCLK 		- Audio CODEC data
 *   AUD_ADCDAT 	- Audio CODEC data
 *
 * Output:
 *   AUD_DACDAT 	- output Audio CODEC data
 */
module DE1_SoC (
	CLOCK_50, 
	CLOCK2_50, 
	KEY, 
	SW,
	FPGA_I2C_SCLK, 
	FPGA_I2C_SDAT, 
	AUD_XCK, 
	AUD_DACLRCK, 
	AUD_ADCLRCK, 
	AUD_BCLK, 
	AUD_ADCDAT, 
	AUD_DACDAT
);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [9:0] SW;
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
   wire [23:0] writedata_left, writedata_right;
	wire [23:0] out_left_FIR, out_right_FIR, best_l_out, best_r_out, fun_l_out, fun_r_out, out_left_real, out_right_real;
	wire [23:0] in_left, in_right;
	wire [23:0] Q;
	
	logic reset, keydb;
	assign reset = ~KEY[0];
	// input sanitization
	/*
	initial begin
		reset <= 0;
		keydb <= 0;
	end
	always_ff @(posedge CLOCK_50) begin
		keydb <= ~KEY[0];
		reset <= keydb;
	end
	*/
	
	assign in_left = read_ready ? readdata_left : 24'b0;
	assign in_right = read_ready ? readdata_right : 24'b0;
	assign writedata_left = write_ready ? out_left_real : 24'b0;
	assign writedata_right = write_ready ? out_right_real: 24'b0;
	assign read = read_ready ? 1'b1 : 1'b0;
	assign write = write_ready ? 1'b1 : 1'b0;
	
	// Instantiate filter for task 2
	FIR_filter filter_1(.clk(CLOCK_50), .reset(~KEY[0]), .read_ready, .in_left(in_left), .in_right(in_right), .out_left(out_left_FIR), .out_right(out_right_FIR));
	// Instantiate filter with N value that produces "Best" result
	N_average_filter #(24, 64, 6) best_l (.clk(CLOCK_50), .reset(reset), .read_ready(read_ready), .data_in(in_left), .data_out(best_l_out));
	//N_average_filter #(24, 64, 6) best_r (.clk(CLOCK_50), .reset(reset), .read_ready(read_ready), .data_in(in_right), .data_out(best_r_out));
	// Instantiate FIR filter that produces "Fun" result
	N_average_filter #(24, 128, 7) fun_l (.clk(CLOCK_50), .reset(reset), .read_ready(read_ready), .data_in(in_left), .data_out(fun_l_out));
	//N_average_filter #(24, 128, 7) fun_r (.clk(CLOCK_50), .reset(reset), .read_ready(read_ready), .data_in(in_right), .data_out(fun_r_out));
	
	// Combinational logic to determine which output we feed to the output of our speakers
	
	always_comb begin
		// No filter
		if (SW[1:0] == 2'b00) begin
			out_left_real = readdata_left;
			out_right_real = readdata_right;
		// N = 8 FIR filter
		end else if (SW[1:0] == 2'b01) begin
			out_left_real = out_left_FIR;
			out_right_real = out_right_FIR;
		// N custom averaging filter
		end else if (SW[1:0] == 2'b10) begin
			out_left_real = best_l_out;
			out_right_real = best_r_out;
		// Put "fun" N here
		end else begin
			out_left_real = fun_l_out;
			out_right_real = fun_r_out;
		end // if
		
	end // always_comb

	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);


endmodule


