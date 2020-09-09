/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- asserts true when the algorithm has finished drawing the line
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
	// input and output wires, as specified above
	input logic clk, reset;
	input logic [10:0]	x0, y0, x1, y1;
	output logic [10:0]	x, y;
	output logic done;
	
	/*
	 * You'll need to create some registers to keep track of things
	 * such as error and direction
	 * Example: */
	logic [10:0] del_x, del_y, delta_x, delta_y, my_x, my_x1, my_y, my_y1, error;//, err_next;
	// these are two single bit logical registers which are used to keep track of whether the changes in x and y are positive or negative
	logic pos_del_x, pos_del_y;
	
	// this is some initial decision making logic to determine how the algorithm shall be run
	// pos_del_x and pos_del_y determine the overall direction that the line is to be drawn in
	assign pos_del_x = x1 > x0;
	assign pos_del_y = y1 > y0;
	// del_x and del_y use a ternary conditional operater to take the absolute value of the change in x and the change in y, from the given x and y inputs
	assign del_x = (pos_del_x) ? x1 - x0 : x0 - x1;
	assign del_y = (pos_del_y) ? y1 - y0 : y0 - y1;
	
	// SEQUENTIAL LOGIC
	always_ff @(posedge clk) begin
		// my module loads the initial values on reset
		// I May change this later...
		if (reset) begin
			// in the case that the line is steep
			if (del_y > del_x) begin
				// assign my x0 to the lesser of y1 and y0
				my_x <= (y0 > y1) ? y1 : y0;
				// assign my x1 to the greater of y1 and y0
				my_x1 <= (y0 > y1) ? y0 : y1;
				// assign my y0 to the lesser of x1 and x0
				my_y <= (y0 > y1) ? x1 : x0;
				// assign my y1 to the greater of x1 and x0
				my_y1 <= (y0 > y1) ? x0 : x1;
				// assign the register delta_x for the algo to del_y
				delta_x <= (del_y);
				// likewise for the algorithms delta_y
				delta_y <= (del_x);
				// define the error value = -(delta_x)/2
				error <= (del_y / 2) * -1;
				// also assign the output x to the lesser of y1 and y0 (my x0)
				x <= (y0 > y1) ? x1 : x0;
				// assign the output y to my y0
				y <= (y0 > y1) ? y1 : y0;
			end
			// otherwise if the line is not steep
			else begin
				// assign my x to the lesser of x1 and x0
				my_x <= (x0 > x1) ? x1 : x0;
				// assign my x1 to the greater of x1 and x0
				my_x1 <= (x0 > x1) ? x0 : x1;
				// assign my y0 to the lesser of y1 and y0
				my_y <= (x0 > x1) ? y1 : y0;
				// assign my y1 to the greater of y1 and y0
				my_y1 <= (x0 > x1) ? y0 : y1;
				// set the program delta_x value to the stored del_x
				delta_x <= (del_x);
				// set the algorithm delta_y value to the stored del_y
				delta_y <= (del_y);
				// set the error, as defined in the algorithm
				error <= (del_x / 2) * -1;
				// also tie the output x to the lesser of x1 and x0 (my x0)
				x <= (x0 > x1) ? x1 : x0;
				// and tie the output y to the lesser of y1 and y0 (my y0)
				y <= (x0 > x1) ? y1 : y0;
			end
			// make sure that done is initialized to zero
			done <= 0;
		end
		
		else begin
			// if not done
			if (~done) begin
				// increment my x
				my_x <= my_x + 1;
				// if the line is steep, assign the output x to my_y0, else my_x0
				x <= (del_y > del_x) ? my_y : my_x;
				// if the line is steep, assign the output y to my_x0, else my_y0
				y <= (del_y > del_x) ? my_x : my_y;
				// This little nugget checks to see if the error plus delta_y is negative
				// I got around the use of an extra register by utilizing bit shifting
				if (((error+delta_y)>>10)&1'b1) begin
					// if so, error += delta_y
					error <= error + delta_y;
				end 
				else begin
					// if error is greater than zero, we add or subtract from y, based on whether or not the line is going up or down
					my_y <= (my_y < my_y1) ? my_y + 1 : my_y - 1;
					// and assign error = error + delta_y - delta_x
					error <= error + delta_y - delta_x;					
				end
				// once my_x has finished counting up, we can say that this algorithm is concluded
				// since for every x there is only one y
				if (my_x == my_x1) begin
					done <= 1;
				end
					
			end
			
		end
		
	end
	
endmodule //line_drawer

/*
 * LINE DRAWER TESTBENCH
 * This module is a simple testbench for the line drawer module
 * It initializes a line drawer and draws a series of lines, demonstrating different behaviors of the Line Drawing Algorithm
 * It draws horizontal lines, vertical lines, diagonal lines with a slope of one, diagonal lines that are steep and diagonal lines that are shallow
 * Additionally, it also draws lines from one point to another, and then in reverse order, to show that the line drawing algorithm will prefer to go
 * From right to left, or from top to bottom for a steep line
**/
module line_drawer_testbench();
	logic clk, reset, done;
	logic [10:0] x0, y0, x1, y1, x, y;
	
	line_drawer dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		// (0, 0) to (10, 0)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 0;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		
		// (10, 0) to (0, 0)
		reset <= 1;
		x0 <= 10; y0 <= 0; x1 <= 0; y1 <= 0;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (0, 0) to (0, 10)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 0; y1 <= 10;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (0, 10) to (0, 0)
		reset <= 1;
		x0 <= 0; y0 <= 10; x1 <= 0; y1 <= 0;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (0, 0) to (10, 10)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 10;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (10, 10) to (0, 0)
		reset <= 1;
		x0 <= 10; y0 <= 10; x1 <= 0; y1 <= 0;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (0, 10) to (10, 0)
		reset <= 1;
		x0 <= 0; y0 <= 10; x1 <= 10; y1 <= 0;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (10, 0) to (0, 10)
		reset <= 1;
		x0 <= 10; y0 <= 0; x1 <= 0; y1 <= 10;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 10; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		// (0, 0) to (10, 20)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 20;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 20; i++) begin
			@(posedge clk);
		end
		@(posedge clk);		
		
		// (0, 0) to (20, 10)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 20; y1 <= 10;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 20; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
	
		// (0, 0) to (10, 33)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 33;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 33; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
	
		// (0, 0) to (33, 10)
		reset <= 1;
		x0 <= 0; y0 <= 0; x1 <= 33; y1 <= 10;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		for (int i = 0; i <= 33; i++) begin
			@(posedge clk);
		end
		@(posedge clk);
		
		
		$stop;
	end
endmodule
