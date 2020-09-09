/*
 *	Module binary search
 * This module takes in an input value, and performs a binary search for that value
 * If that value is found in the attached ram module, the Found signal is set to true
 * The current memory address is always being returned, and should be printed out only
 * if the number has been found
 * Inputs:
 * 	clk 	-> system clock
 *		reset -> resets the system, by reloading the input and running the calculation again
 * 	start -> while this is true, the binarySearch module will continue to run until it is done
 * 	A		-> number input, the number to search for
 *		mem_loc -> The value stored at the address in ram pointed to by loc
 * Outputs:
 *		loc	-> the current address in memory to read in
 *		Done 	-> The module has finished searching
 * 	Found -> The value A has been found in ram, at the address loc
 */
module binarySearch #(parameter N=32, LOGN=5, W=8) 
	(	input  logic clk, reset, start,
		input  logic [W-1:0] mem_loc,
		input  logic [W-1:0] A,
		output logic [LOGN-1:0] loc,
		output logic Done, Found);

	// define status and control signals
	logic init_reg, look_up, look_down, incr_ctr;
	logic fl_eq_cl, A_eq_B, A_gt_B;
	
	// instantiate control and datapath
	binarySearch_control c_unit (.*);
	binarySearch_datapath #(N, LOGN, W) d_unit (.*);	

endmodule

// for the ram
`timescale 1 ps / 1 ps

/* this testbench shows the binary search module connected to an instance of the ram32
 * it demonstrates searching for all possible input numbers
 */
module binarySearch_testbench();
	parameter T = 20, N = 32, LOGN = 5, W = 8;
	logic clk, reset, start, Done, Found;
	logic [W-1:0] mem_loc, A;
	logic [LOGN-1:0] loc;
	
	binarySearch dut (.*);
	
	logic wren = 0;
	logic [W-1:0] data = 8'bxxxxxxxx;
	ram32x8 ram (.address(loc), .clock(clk), .data, .wren, .q(mem_loc));
	
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; start <= 0; @(posedge clk);
		reset <= 0; @(posedge clk);
		for (int i = 0; i < 2**W; i++) begin
			A <= i; @(posedge clk);
			start <= 1; @(posedge Done);
			@(posedge clk);
			start <= 0;	@(posedge clk);
			@(posedge clk);
		end
	$stop;
	end

endmodule
