/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic [10:0] x0, y0, x1, y1, x, y;
	logic done, color, reset, clear;
	logic [6:0] i;
	
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(clear), 
		.x, 
		.y,
		.pixel_color	(color), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
		
	// instantiation of the line drawer module				
	line_drawer lines (.clk(CLOCK_50), .reset, .x0, .y0, .x1, .y1, .x, .y, .done);

	// initialize my DE1_SoC module
	initial begin
		color <= 1'b1;
		clear <= 1'b0;
		reset <= 1'b0;
	end
	
	// SEQUENTIAL LOGIC
	// Using the 6 Hz divided clock
	always_ff @(posedge clk[whichClock]) begin
		// This is my clear function
		// which holds down the reset button of the VGA_Framebuffer
		// and also assigns the drawing color to black.
		if (~KEY[0]) begin
			clear <= ~clear;
			// starts i at the 12 o'clock position
			i <= 47;
		end

		// waits for the line to finish drawing 
		if (done) begin
			// toggle the drawing color
			color <= ~color;
			// then when the color is black, increment i
			if (~color) begin
				i <= i+1;
			end
			// reset the line drawing module, to reload the new x and y values (x_vals[i] and y_vals[i])
			reset <= 1'b1;
		end
		else begin
			// if it's not done yet, then make sure to set the reset to zero
			reset <= 1'b0;
		end
	end
	
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 22; // 6 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .divided_clocks(clk));
	
	// These assignment variables set the origin point of the line to be drawn
	assign x0 = 320;
	assign y0 = 240;
	// As i gets incremented in the main program logic, the end point of the line changes accordingly
	assign x1 = x_vals[i];
	assign y1 = y_vals[i];
	
	// declaration of two logic arrays to hold my x and y endpoints for each frame of the animation
	// these were computed using an external program, and form the edges of a circle
	int x_vals [63:0];
	assign x_vals = '{560, 559, 555, 550, 542, 532, 520, 506, 490, 472, 453, 433, 412, 390, 367, 344, 320, 296, 273, 250, 228, 207, 187, 168, 150, 134, 120, 108, 98, 90, 85, 81, 80, 81, 85, 90, 98, 108, 120, 134, 150, 168, 187, 207, 228, 250, 273, 296, 320, 344, 367, 390, 412, 433, 453, 472, 490, 506, 520, 532, 542, 550, 555, 559};
	int y_vals [63:0];
	assign y_vals = '{240, 216, 193, 170, 148, 127, 107, 88, 70, 54, 40, 28, 18, 10, 5, 1, 0, 1, 5, 10, 18, 28, 40, 54, 70, 88, 107, 127, 148, 170, 193, 216, 240, 264, 287, 310, 332, 353, 373, 392, 410, 426, 440, 452, 462, 470, 475, 479, 480, 479, 475, 470, 462, 452, 440, 426, 410, 392, 373, 353, 332, 310, 287, 264};


endmodule

// Clock Divider module
// Used to output a slower clock when needed
// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	input logic  clock;
	output logic [31:0] divided_clocks = 0;

	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule 
