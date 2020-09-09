/* board_render module
	
	The purpose of this module is to interact with the pixel-by-pixel scanning nature to indicate whether or not we want to draw to a given
	pixel given the internal game state
	
	Inputs:
		boardstate - Input of a 2d 1bit array to indicate the state of a tetris board and whether or not a block is populated
		x          - Input of the current residing value of x in the video driver
		y          - Input of the current residing value of y in the video driver
	Outputs:
		r          - Output of 8 bit red value in RGB cluster
		g          - Output of 8 bit green value in RGB cluster
		b          - Output of 8 bit blue value in RGB cluster
*/

module board_render(boardstate, x, y, r, g, b);

	// Parameters for the base game board game
	parameter GAMEBOARD_X_OFFSET = 10'd250; // upperleft x position of board
	parameter GAMEBOARD_Y_OFFSET = 9'd100;  // upperleft y position of board
	parameter BLOCK_HEIGHT = 12;            // How high is the block, must be a multiple of this number or /2
	parameter BLOCK_WIDTH = 8;              // How wide is the block, must be a multiple of this number or /2
	parameter GAMEBOARD_HEIGHT = 20;        // How many blocks high is the tetris well?
	parameter GAMEBOARD_WIDTH = 10;         // How many blocks wide is the tetris well?

	// These values come from the driver as a scanned in pixel value while it updates the screen
	input logic boardstate[GAMEBOARD_HEIGHT][GAMEBOARD_WIDTH];
	input logic [9:0] x;
	input logic [8:0] y;
	
	// Put out to the driver to indicate what color we want the pixel to be
	output logic [7:0] r, g, b;
	
	always_comb begin
		// For graphical updating purposes, check that we are bounded by the gameboard space itself
		if ((x >= GAMEBOARD_X_OFFSET & x <= (GAMEBOARD_X_OFFSET + (BLOCK_WIDTH * GAMEBOARD_WIDTH))) & (y >= GAMEBOARD_Y_OFFSET & y <= (GAMEBOARD_Y_OFFSET + (BLOCK_HEIGHT * GAMEBOARD_HEIGHT)))) begin
			// Check if we need to actually draw this block
			if (boardstate[(y - GAMEBOARD_Y_OFFSET) / BLOCK_HEIGHT][(x - GAMEBOARD_X_OFFSET) / BLOCK_WIDTH] == 1) begin
				// For creating lines between blocks
				if ((x - GAMEBOARD_X_OFFSET) % BLOCK_WIDTH == 0 | (y - GAMEBOARD_Y_OFFSET) % BLOCK_HEIGHT == 0) begin
					{r, g, b} = 24'h00_00_00;
				end else begin
//					{r, g, b} = 24'hff_ff_ff;
					r = 8'h00;
					g = x[7:0];
					b = y[7:0];

				end // if
			end else begin
				{r, g, b} = 24'h00_00_00;
			end // if
		end else begin
			{r, g, b} = 24'h00_00_00;
		end // if
		
	end // always_comb
	
endmodule // board_render

// Basic test bench that goes through a single "screen refresh" to indicate whether a pixel is drawn or not at the current x,y position given the current internal logic
// Look for non 0 values of RGB to indicate whether or not a value was written to

module board_render_testbench();

	// Parameters for the base game board game
	parameter GAMEBOARD_X_OFFSET = 10'd250; // upperleft x position of board
	parameter GAMEBOARD_Y_OFFSET = 9'd100;  // upperleft y position of board
	parameter BLOCK_HEIGHT = 12;            // How high is the block, must be a multiple of this number or /2
	parameter BLOCK_WIDTH = 8;              // How wide is the block, must be a multiple of this number or /2
	parameter GAMEBOARD_HEIGHT = 20;        // How many blocks high is the tetris well?
	parameter GAMEBOARD_WIDTH = 10;         // How many blocks wide is the tetris well?

	// These values come from the driver as a scanned in pixel value while it updates the screen
	logic boardstate[GAMEBOARD_HEIGHT][GAMEBOARD_WIDTH];
	logic [9:0] x;
	logic [8:0] y;
	
	// Put out to the driver to indicate what color we want the pixel to be
	logic [7:0] r, g, b;
	
	board_render dut (.*);
	
	initial begin
		// Initialize a testing boardstate
		for (int i = 0; i < GAMEBOARD_HEIGHT; i++) begin
			for (int j = 0; j < GAMEBOARD_WIDTH; j++) begin
				if (((i + j) % 2) == 0)
					boardstate[i][j] = 1'b1;
				else
					boardstate[i][j] = 1'b0;
			end // for
		end // for
		
		// Iterate over a virtual screen
		for (int i = 0; i < 640; i++) begin
			for (int j = 0; j < 480; j++) begin
				y = j; #50;
			end // for
			x = i;
		end //for
			
		
	end // initial
	
endmodule // board_render_testbench
