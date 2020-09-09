// this is gonna be a board state manager
module board_state_manager
	#(parameter BOARD_HEIGHT=20, parameter BOARD_WIDTH=10)
	(CLOCK_50, reset, left, right, soft_drop, hard_drop, rotate_cw, rotate_ccw, hold_piece, boardstate, xpos, ypos, rval, pid);
	
	input logic CLOCK_50, reset;
	input logic left, right, soft_drop, hard_drop, rotate_cw, rotate_ccw, hold_piece;
	
	output logic boardstate [0:BOARD_HEIGHT - 1][0:BOARD_WIDTH - 1];

	
	// I, Z, S, O, T, L, J
	logic [6:0][15:0] tetrominos = '{16'h2222, 16'h2640, 16'h4620, 16'h0660, 16'h2620, 16'h0622, 16'h0644};
	logic [15:0] t;
	logic [15:0] active_piece;		// after rotation
	logic [1:0] rotation;
	logic [4:0] px, nx;
	logic [5:0] py, ny;
	
	logic [3:0] active;
	
	localparam piece_width = 4;
	localparam piece_height = 4;
	
	assign t = tetrominos[active];
	
	// TIMING
	
	logic [31:0] divided_clocks;
	logic GAME_CLOCK;
	
	clock_divider cdiv (.clock(CLOCK_50), .divided_clocks);
	assign GAME_CLOCK = divided_clocks[20];
	
	// LOCKED PIECES
	
	logic locked_pieces [0:BOARD_HEIGHT + 1][0:BOARD_WIDTH + 3];
	
	logic [3:0][15:0] rotations;
	assign rotations[0] = t;
	assign rotations[1] = {t[12], t[8], t[4], t[0], t[13], t[9], t[5], t[1], t[14], t[10], t[6], t[2], t[15], t[11], t[7], t[3]};
	assign rotations[2] = {t[15], t[14], t[13], t[12], t[11], t[10], t[9], t[8], t[7], t[6], t[5], t[4], t[3], t[2], t[1], t[0]};
	assign rotations[3] = {t[3], t[7], t[11], t[15], t[2], t[6], t[10], t[14], t[1], t[5], t[9], t[13], t[0], t[4], t[8], t[12]};
	
	assign active_piece = rotations[rotation];

	// COLLISION DETECTION
	logic collision_left, collision_right, collision_down, collision_cw, collision_ccw;
	
	always_comb begin
		collision_left = 1'b0;
		collision_right = 1'b0;
		collision_down = 1'b0;
		collision_cw = 1'b0;
		collision_ccw = 1'b0;
		for (int i = 0; i < piece_width; i++) begin
			for (int j = 0; j < piece_height; j++) begin
				if (locked_pieces[i + py][j + 2 + px - 1] && active_piece[i*piece_width + j]) collision_left = 1'b1;
				if (locked_pieces[i + py][j + 2 + px + 1] && active_piece[i*piece_width + j]) collision_right = 1'b1;
				if (locked_pieces[i + py + 1][j + 2 + px] && active_piece[i*piece_width + j]) collision_down = 1'b1;
				if (locked_pieces[i + py][j + 2 + px] && rotations[rotation+1][i*piece_width + j]) collision_cw = 1'b1;
				if (locked_pieces[i + py][j + 2 + px] && rotations[rotation-1][i*piece_width + j]) collision_ccw = 1'b1;
			end
		end
	end
	
// INITIALIZE THE GAME STATE
	
	initial begin
		for (int i = 0; i <= BOARD_HEIGHT + 1; i++) begin
			for (int j = 0; j <= BOARD_WIDTH + 3; j++) begin
				locked_pieces[i][j] = (j == 2 || j == 11 || (i == 19 && j > 1 && j < 12));
			end
		end
	end
	
//	always_ff @(posedge CLOCK_50) begin
	always_ff @(posedge GAME_CLOCK) begin	
		if (reset) begin
			px <= 5'b00101;
			py <= 6'b000000;
			active <= 0;
			rotation <= 0;
		end
		
		for (int i = 0; i < BOARD_HEIGHT; i++) begin
			for (int j = 0; j < BOARD_WIDTH; j++) begin
				if (i >= py && i < py + piece_height && j >= px && j < px + piece_width) 
					boardstate[i][j] <= locked_pieces[i][j+2] + active_piece[(i-py)*piece_width + (j-px)];
				else
					boardstate[i][j] <= locked_pieces[i][j+2];
			end
		end
		
		if (left && ~right) px <= (collision_left) ? px : px - 1;
		else if (~left && right) px <= (collision_right) ? px : px + 1;
		if (soft_drop && ~hard_drop) py <= (collision_down) ? py : py + 1;
		else if (~soft_drop && hard_drop) py <= py - 1;
		if (rotate_cw && ~rotate_ccw) rotation <= (collision_cw) ? rotation : rotation + 1;
		else if (~rotate_cw && rotate_ccw) rotation <= (collision_ccw) ? rotation : rotation - 1;
		if (hold_piece) active <= (active == 6) ? 0 : active + 1;
		
		//if (left && ~right) px <= (collision_left) ? px : px - 1;
		//if (~left && right) px <= (collision_right) ? px : px + 1;
	end
	
// DEBUG ZONE
	output logic [4:0] xpos;
	output logic [5:0] ypos;
	output logic [1:0] rval;
	output logic [3:0] pid;
	assign rval = rotation;
	assign xpos = px;
	assign ypos = py;
	assign pid = active;
	
endmodule


// Simple testbench so I can take a peek inside and see what's what
module board_state_manager_testbench();
	parameter T = 20;
	
	logic CLOCK_50, reset, left, right, soft_drop, hard_drop, rotate_cw, rotate_ccw, hold_piece;
	logic boardstate [0:19][0:9];
	logic [4:0] xpos;
	logic [5:0] ypos;
	logic [1:0] rval;
	logic [3:0] pid;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(T/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	board_state_manager dut (.*);
	
	initial begin
		left <= 0;
		right <= 0;
		soft_drop <= 0;
		hard_drop <= 0;
		rotate_cw <= 0;
		rotate_ccw <= 0;
		hold_piece <= 0;
		
		reset <= 1; @(posedge CLOCK_50);
		reset <= 0;
		
		for (int i = 0; i < 10; i++)
			@(posedge CLOCK_50);
	
		$stop;
	end
	
endmodule
	