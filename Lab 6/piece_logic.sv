/*
module piece_logic();
	input logic [2:0] piece;
	input logic [1:0] rotation;
	
	output logic [15:0] live_piece;
	
	logic tetromino [6:0][15:0];

	assign live_piece = tetromino[piece];
	
	initial begin
		tetromino[0] = {0, 0, 1, 0,
							 0, 0, 1, 0,
							 0, 0, 1, 0,
							 0, 0, 1, 0};
		tetromino[1] = {0, 0, 1, 0,
							 0, 1, 1, 0,
							 0, 1, 0, 0,
							 0, 0, 0, 0};
		tetromino[2] = {0, 1, 0, 0,
							 0, 1, 1, 0,
							 0, 0, 1, 0,
							 0, 0, 0, 0};
		tetromino[3] = {0, 0, 0, 0,
							 0, 1, 1, 0,
							 0, 1, 1, 0,
							 0, 0, 0, 0};
		tetromino[4] = {0, 0, 1, 0,
							 0, 1, 1, 0,
							 0, 0, 1, 0,
							 0, 0, 0, 0};
		tetromino[5] = {0, 0, 0, 0,
							 0, 1, 1, 0,
							 0, 0, 1, 0,
							 0, 0, 1, 0};
		tetromino[6] = {0, 0, 0, 0,
							 0, 1, 1, 0,
							 0, 1, 0, 0,
							 0, 1, 0, 0};
	end
endmodule
*/