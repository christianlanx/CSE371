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

module FIR_filter #(parameter[23:0] N = 64, SIZE = 24) (clk, reset, in_left, in_right, out_left, out_right, read_ready);

	input  logic clk, reset;
	input  logic [SIZE-1:0] in_left, in_right;
	input  logic read_ready;
	output logic [SIZE-1:0] out_left, out_right;

	// Internal register queue
	logic [SIZE-1:0] reg_left [0:N-1];
	logic [SIZE-1:0] reg_right [0:N-1];
	
	logic [SIZE-1:0] sum_l, sum_r;
	
	integer i;
	
	always_ff @(posedge clk) begin
	
		// Set all values of registers to the input / N on reset so average is the same as the initial input momentarily
		if (reset) begin
			for (i = 0; i < N; i++) begin
				reg_left[i] <= in_left / N;
				reg_right[i] <= in_right / N;
				sum_l <= in_left;
				sum_r <= in_right;
			end //for
		end //if (reset)
		
		else if (read_ready) begin
		
			// shift all values 1 to the right
			for (i = N-1; i > 0; i--) begin
				reg_left[i] <= reg_left[i - 1];
				reg_right[i] <= reg_right[i - 1];
			end // for
			
			// bring in initial value
			reg_left[0] <= (in_left / N);
			reg_right[0] <= (in_right / N);
			
			// set new value for outputs by substracting last queue value divided (already divided by N) and adding input divided by N
			sum_l <= sum_l + (in_left / N) - reg_left[N - 1];
			sum_r <= sum_r + (in_right / N) - reg_right[N - 1];
			
		end // else

	end // always_ff


	// Get output on the rising clock edge as soon as registers change
	
	assign out_left = sum_l;
	assign out_right = sum_r;
		
endmodule // FIR_filter

// Quick test bench to test the functionality of our basic N-1 register wide FIR filter

module FIR_filter_testbench();

	parameter N = 64, SIZE = 24;

	logic clk, reset, read_ready;
	logic [SIZE-1:0] in_left, in_right;
	logic [SIZE-1:0] out_left, out_right;

	parameter T = 20;
	
	FIR_filter dut(.*);
	
	// Simulated clock
	initial begin
	clk <= 0;
	forever #(T/2) clk <= ~clk;
	end	// clock initial
	
	integer i;
	
	initial begin
		read_ready <= 1;
		in_left = 24'd128;
		in_right = 24'd128;
		
		// Simulated reset
		reset = 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		for (i = 0; i < 1000; i++) begin
			in_left = i * 24'd64; in_right = i * 24'd128; @(posedge clk);
		end //for
	
		$stop;
	end // initial
	

endmodule // FIR_filter_testbench