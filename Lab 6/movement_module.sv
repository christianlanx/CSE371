// handles the keyboard inputs and converts them to human readable signals
module movement_module(CLOCK_50, reset, PS2_DAT, PS2_CLK, left, right,
								soft_drop, hard_drop, rotate_cw, rotate_ccw, 
								hold_piece);
	input logic CLOCK_50, reset, PS2_DAT, PS2_CLK;
	output logic left, right, soft_drop, hard_drop, rotate_cw, rotate_ccw, hold_piece;
	
	logic makeBreak, valid;
	logic [7:0] outCode;
	
	keyboard_press_driver kpd (.*);
	
	always_ff @(posedge CLOCK_50)
		case (outCode)
			8'h6b: left <= makeBreak;
			8'h74: right <= makeBreak;
			8'h72: soft_drop <= makeBreak;
			8'h29: hard_drop <= makeBreak;
			8'h1a: rotate_cw <= makeBreak;
			8'h22: rotate_ccw <= makeBreak;
			8'h21: hold_piece <= makeBreak;
		endcase

endmodule