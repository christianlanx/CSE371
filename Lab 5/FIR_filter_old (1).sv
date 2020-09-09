/*
 *	FIR_filter module
 * 
 * This module creates a rolling average of the last N data values coming in and outputs the average
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

module FIR_filter #(parameter[23:0] N = 8, SIZE = 24) (clk, reset, in_left, in_right, out_left, out_right);

	input  logic clk, reset;
	input  logic [SIZE-1:0] in_left, in_right;
	output logic [SIZE-1:0] out_left, out_right;

	// Internal register queue
	logic [SIZE-1:0] reg_left [0:N-1];
	logic [SIZE-1:0] reg_right [0:N-1];
	logic [SIZE-1:0] average_l, average_r;
	logic [SIZE-1:0] add_l, sub_l, add_r, sub_r;
	
	
	integer i;
	
	always_ff @(posedge clk) begin
	
		// Set all values of registers to the first value input on reset so average is the same as the initial input momentarily
		if (reset) begin
			for (i = 0; i < N; i++) begin
				reg_left[i] <= in_left;
				reg_right[i] <= in_right;
			end //for
			// Just set average rather than calculate
			average_l <= in_left;
			average_r <= in_right;
			add_l <= in_left / N;
			sub_l <= in_left / N;
			add_r <= in_right / N;
			sub_r <= in_right / N;
		end //if (reset)
		
		else begin
		
			// shift all values 1 to the right
			for (i = N-1; i > 0; i--) begin
				reg_left[i] <= reg_left[i - 1];
				reg_right[i] <= reg_right[i - 1];
			end // for
			
			// bring in initial value
			reg_left[0] <= in_left;
			reg_right[0] <= in_right;
			
			// Determine the new values we will be adding and subtracting from running average
			add_l <= in_left / N;
			sub_l <= reg_left[N-1] / N;
			add_r <= in_right / N;
			sub_r <= reg_right[N-1] / N;
			
			// Calculate new averages
//			average_l = average_l + add_l;
//			average_l = average_l - sub_l;
//			average_r = average_r + add_r;
//			average_r = average_r - sub_r;
			average_l = average_l + add_l - sub_l;
			average_r = average_r + add_r - sub_r;
			
		end // else
		
	end // always_ff
	
	// Output new rolling averages
	assign out_left = average_l; //average_l;
	assign out_right = average_r; //average_r;
	
endmodule // FIR_filter

// Quick test bench to test the functionality of our basic N-1 register wide FIR filter

module FIR_filter_testbench();

	parameter N = 8, SIZE = 24;

	logic clk, reset;
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
		in_left = 24'd100;
		in_right = 24'd100;
		
		// Simulated reset
		reset = 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		for (i = 0; i < 100; i++) begin
			in_left = i * 24'd5; in_right = i * 24'd10; @(posedge clk);
		end //for
	
		$stop;
	end // initial
	

endmodule // FIR_filter_testbench