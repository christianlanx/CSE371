/*
 * Module binarySearch datapath
 * Datapath logic for binary search module
 * inputs:
 *		mem_ptr		-> value of the ram at the address referenced by the pointer
 *		init_reg		-> tells the datapath to load initial values for register a, program counter and pointer *		load_B		-> load register B with the value stored in mem[ptr]
 *		look_up		-> set the ceiling register equal to pointer
 * 	look_down	-> set the floor register equal to the pointer + 1;
 *	outputs:
 *		pointer		-> current memory address
 *		fl_eq_cl		-> lets the control know that the floor has reached the ceiling, value not found
 *		A_eq_B		-> register a equals register b, a match has been found
 *		A_gt_B		-> register a is greater than the value stored in register b
 */
 module binarySearch_datapath #(parameter N = 32, LOGN = 5, W = 8)
	(input  logic clk,
	input  logic [W-1:0] mem_loc, A,
	input  logic init_reg, look_up, look_down,
	output logic [LOGN-1:0] loc,
	output logic fl_eq_cl, A_eq_B, A_gt_B);
	
	//internal datapath signals and registers
	logic [W-1:0] 		A_reg;// input value
	logic [LOGN-1:0]	flr;	// floor -> lower bound of active memory region
	logic [LOGN-1:0]	ceil;	// ceiling -> upper bound of active memory region
	
	// datapath logic
	always_ff @(posedge clk) begin
		if (init_reg) begin
			A_reg <= A;
			flr <= 0;
			ceil <= N-1;
		end	// if init_reg
		if (look_up)	flr 	<= loc + 1;
		if (look_down)	ceil	<= loc;
	end	// always_ff
	
	//output assignments
	assign loc = (ceil + flr) / 2;
	assign fl_eq_cl = (flr == ceil);
	assign A_eq_B = (A_reg == mem_loc);
	assign A_gt_B = (A_reg > mem_loc);
endmodule

module binarySearch_datapath_testbench();
	parameter T = 20, N = 32, LOGN = 5, W = 8;
	logic clk, init_reg, look_up, look_down;
	logic [W-1:0] mem_loc, A;
	logic [LOGN-1:0] loc;
	logic fl_eq_cl, A_eq_B, A_gt_B;
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end
	
	binarySearch_datapath dut (.*);
	
	initial begin
		// initialize the external inputs
		look_up <= 0; look_down <= 0;
		A <= 0; mem_loc <= 0; init_reg <= 0; @(posedge clk);
		@(posedge clk);
		// show what happens when the init_reg signal is asserted
		init_reg <= 1; @(posedge clk);
		init_reg <= 0; @(posedge clk);
		// show fl_eq_ptr raises the floor
		look_up <= 1; @(posedge clk);
		look_up <= 0; @(posedge clk);
		// show cl_eq_ptr moves the ceiling down
		look_down <= 1; @(posedge clk);
		look_down <= 0; @(posedge clk);
		// finally, show A_gt_B
		A <= 2;	@(posedge clk);
		$stop;
	end // initial
endmodule
