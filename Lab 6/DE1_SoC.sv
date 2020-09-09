module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, 
					 VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	input PS2_DAT, PS2_CLK;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	parameter BOARD_HEIGHT = 20;
	parameter BOARD_WIDTH = 10;
	
	logic left, right, soft_drop, hard_drop, rotate_cw, rotate_ccw, hold_piece;
	
	logic [4:0] xpos;
	logic [5:0] ypos;
	logic [1:0] rval;
	logic [3:0] pid;
	
	// this instantiation of boardstate is for testing renderer only atm, please change as you see fit
	
	logic boardstate [0:BOARD_HEIGHT - 1][0:BOARD_WIDTH - 1];
	
	/*
	// For testing the board renderer, change as you see fit for valid testing	
	initial begin
		for (int i = 0; i < BOARD_HEIGHT; i++) begin
			for (int j = 0; j < BOARD_WIDTH; j++) begin
				if (((i + j) % 2) == 0)
					boardstate[i][j] = 1'b1;
				else
					boardstate[i][j] = 1'b0;
			end
		end
	end
	*/
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	board_render br (.*);
	
	movement_module mm (.*);
	
	board_state_manager bsm (.*);
	
	/*
	always_ff @(posedge CLOCK_50)
		if (hard_drop)
			for (int i = 0; i < BOARD_HEIGHT; i++) begin
				for (int j = 0; j < BOARD_WIDTH; j++) begin
					boardstate[i][j] = ~boardstate[i][j];
				end
			end
	*/
	
	assign LEDR[9] = left;
	assign LEDR[8] = right;
	assign LEDR[6] = soft_drop;
	assign LEDR[5] = hard_drop;
	assign LEDR[3] = rotate_cw;
	assign LEDR[2] = rotate_ccw;
	assign LEDR[0] = hold_piece;
	
//	keyboard_press_driver kpd (.*);
	
	data2ssd h5 (.en(1'b1), .data_in(pid), .ssdout(HEX5));
	data2ssd h4 (.en(1'b1), .data_in(rval), .ssdout(HEX4));
	data2ssd h3 (.en(1'b1), .data_in(ypos / 10), .ssdout(HEX3));
	data2ssd h2 (.en(1'b1), .data_in(ypos % 10), .ssdout(HEX2));
	data2ssd h1 (.en(1'b1), .data_in(xpos / 10), .ssdout(HEX1));
	data2ssd h0 (.en(1'b1), .data_in(xpos % 10), .ssdout(HEX0));
	
//	data2ssd h1 (.en(makeBreak), .data_in(outCode[7:4]), .ssdout(HEX1));
//	data2ssd h0 (.en(makeBreak), .data_in(outCode[3:0]), .ssdout(HEX0));
	
//	always_ff @(posedge CLOCK_50) begin
//		if (x % 8 == 0 | y % 12 == 0) begin
//			{r, g, b} <= 24'h00_00_00;
//		end else begin
//			{r, g, b} <= 24'h0f_0f_0f;
////			r <= SW[7:0];
////			g <= x[7:0];
////			b <= y[7:0];
//		end
//		
//	end
	
//	assign HEX0 = '1;
//	assign HEX1 = '1;
//	assign HEX2 = '1;
//	assign HEX3 = '1;
//	assign HEX4 = '1;
//	assign HEX5 = '1;
	assign reset = 0;
		
endmodule
