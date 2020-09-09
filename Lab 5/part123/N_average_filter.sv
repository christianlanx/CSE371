/*
 *	FIR_filter module
 * 
 * This module implements a queue of N registers and passes in predivided values to create a rolling average
 * reg[N-1] on each clock cycle is removed from the average where as the new input divided by N is added
 * 
 * Inputs:
 *		clk			-> System clock
 *		reset 		-> Synchronous reset, returns the module to an initial state where average equals the input momentarily
 *    in_left     -> Input signal for left channel audio data
 *    in_right    -> Input signal for right channel audio data
 *	Outputs:
 *    out_left    -> Output signal for the running average of the last N samples on in_left
 *		out_right 	-> Output signal for the running average of the last N samples on in_right
 */

module N_average_filter #(parameter signed DATA_WIDTH = 24, N = 16, ADDR_WIDTH = 4) (clk, reset, read_ready, data_in, data_out);

	input  logic clk, reset, read_ready;
	input  logic signed [DATA_WIDTH-1:0] data_in;
	output logic signed [DATA_WIDTH-1:0] data_out;

	// Internal register queue
	logic signed [DATA_WIDTH-1:0] w_data, r_data;	
	logic signed [DATA_WIDTH-1:0] sum;
	logic empty, full;
	logic wr, rd;
	integer signed two = 2;

	// fifo buffer
	fifo #(DATA_WIDTH, ADDR_WIDTH) FIFO (.clk, .reset, .wr, .rd, .empty, .full, .w_data(w_data), .r_data(r_data));
	
	always_ff @(posedge clk) begin
		// on reset, set the sum equal to the input data
		if (reset)
			sum <= data_in;
			
		// once the fifo is full, begin calculating the average
		else if (rd)
			sum <= sum + w_data - r_data;
	end // always_ff

	// Get output on the rising clock edge as soon as registers change
	assign w_data = data_in / N;
	assign data_out = sum;
	assign rd = read_ready && full;
	assign wr = read_ready;
		
endmodule // N_averaging filter

// Quick test bench to test the functionality of our basic N-1 register wide FIR filter

module N_average_filter_testbench();
	parameter T = 20;
	parameter signed N = 64, DATA_WIDTH = 24, ADDR_WIDTH = 6;

	logic clk, reset;
	logic signed [23:0] data_in;
	logic signed [23:0] data_out;
	logic read_ready;
	
	N_average_filter #(DATA_WIDTH, ADDR_WIDTH) dut(.*);
	
	// Simulated clock
	initial begin
	clk <= 0;
	forever #(T/2) clk <= ~clk;
	end	// clock initial
	
	integer signed i, noise;
	
	initial begin
		read_ready <= 1'b1;
		data_in <= 24'b0;
		
		// Simulated reset
		reset = 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		for (i = 0; i < 1000; i++) begin
			read_ready <= 1'b0;
			noise = $urandom_range(-2**23, 2**23 - 1);
			data_in = noise[23:0];
			@(posedge clk);
			read_ready <= 1'b1;
			@(posedge clk);
//			in_left = i * 24'd64; in_right = i * 24'd128; @(posedge clk);
		end //for
	
		$stop;
	end // initial
	

endmodule // FIR_filter_testbench