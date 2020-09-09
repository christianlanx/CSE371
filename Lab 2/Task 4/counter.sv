/*	COUNTER
 *	This module has a width parameter
 * It just counts up every clock edge
 * Unless the reset button is pressed, then it will go back to zero
 * PARAMS:	width		-> the width of the binary number to output
	INPUTS:	clk		-> the clock
				reset		-> reset button
	OUTPUTS:	count		-> a binary number, as wide as width
								it just keeps going up...
**/
module counter #(parameter WIDTH=5) (clk, reset, count);
	input logic  clk, reset;
	output logic [WIDTH-1:0] count;
	
	// internal logic array to store the value of the count
	logic [WIDTH-1:0] logic_count;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			// go back to zero
			logic_count <= 0;
		end
		else begin
			// go up
			logic_count <= logic_count + 1;
		end
	end
	
	// combinational logic to assign the output to the inner logic
	assign count = logic_count;
endmodule


/* counter_testbench
 * DESCRIPTION:	This module tests the counter by having it run
 * 					through it's complete cycle at least twice
**/
module counter_testbench();
	logic clk, reset;
	logic [4:0] count;
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	counter dut (.*);
	
	initial begin
		// initialize the values
		reset <= 1;				@(posedge clk);
		reset <= 0;
		// go through the full range two times
		// it will roll over once it gets to 32
		for (int i = 0; i < 64; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule
