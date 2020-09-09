/*
 *	Module binarySearch_control
 * This module is the control logic for the binary search algorithmic hardware
 * Inputs:
 *		clk			-> System clock
 *		reset 		-> Synchronous reset, returns the module to idle state
 *		start 		-> Start signal, triggers the initialization of registers and moves the module into the main algorithmic loop
 *		A_eq_B		-> Input signal that tells if the a register equals the b register (a match has been found)
 *		A_gt_B		-> Input signal that tells if the value in the a register is greater than b, this determines the path of the algorithm
 *		fl_eq_cl		-> The value was not found in the memory
 *	Outputs:
 *		init_reg		-> Output signal that tells the datapath to load in initial values for all registers
 *		Found			-> Output signal that communicates that a match has been found
 *		Done			-> Output signal that communicates that the algorithm has finished
 *		look_up		-> tell the datapath to set the new floor value equal to the current midpoint
 *		look_down		-> tell the datapath to set the new ceiling to the current midpoint
 */
module binarySearch_control
	(input  logic clk, reset, start, 
	 input  logic fl_eq_cl, A_eq_B, A_gt_B,
	 output logic init_reg, Found, Done, look_up, look_down);
	
	// define state names and variables
	enum { S_idle, S_comp, S_load, S_done } ps, ns;
	
	// controller logic with synchronous reset
	always_ff @(posedge clk)
		if (reset)
			ps <= S_idle;
		else
			ps <= ns;
			
	// next state logic
	always_comb
		case (ps)
			S_idle:	ns = start ? S_load : S_idle;
			S_load:	ns = S_comp;
			S_comp:	ns = (fl_eq_cl | A_eq_B) ? S_done : S_load;
			S_done:	ns = start ? S_done : S_idle;
		endcase
	
	// output assignments
		assign Done 		= (ps == S_done);
		assign init_reg 	= (ps == S_idle);
		assign Found		= (ps == S_done) & A_eq_B;
		assign look_up		= (ps == S_comp) & A_gt_B;
		assign look_down  = (ps == S_comp) & ~A_eq_B & ~A_gt_B;
		
endmodule


// This testbench simulates a demo scenario, where different paths through the logic are shown
// such as idling, looking up and down, and waiting while done and found and not found
module binarySearch_control_testbench();
	parameter T = 20;
	
	logic clk, reset, start;
	logic fl_eq_cl, A_eq_B, A_gt_B;
	logic init_reg, Found, Done, look_up, look_down;
	
	binarySearch_control dut (.*);
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end // initial
	
	initial begin
		// show reset behavior, load up the module
		reset <= 1; start <= 0;
		fl_eq_cl <= 0; A_eq_B <= 0; A_gt_B <= 0; @(posedge clk);
		reset <= 0;
		// show holding the S_idle state
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		// show starting
		start <= 1; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		// show exit
		fl_eq_cl <= 1; @(posedge clk);
		
		// show done & not found
		@(posedge clk);
		@(posedge clk);
		
		// show back to idle
		start <= 0; fl_eq_cl <= 0; @(posedge clk);
		start <= 1;	@(posedge clk);
		
		// show looking up
		A_gt_B <= 1; @(posedge clk);
		@(posedge clk);
		
		// show exit w/ found
		A_eq_B <= 1; A_gt_B <= 0; @(posedge clk);
		@(posedge clk);
		
		// show done & found 
		@(posedge clk);
		@(posedge clk);
		
		// reset
		reset <= 1; start <= 1; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule

	