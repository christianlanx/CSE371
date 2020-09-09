/*
 *	Module DE1_SoC
 * This module is a driver for the binary Search module
 * It instantiates the binary search, as well as a 32x8 ram, loaded with a mif file
 * and connects the output of the binary search to the hexdecimal displays
 * and the inputs of the binary search to the keys and switches of the DE1_SoC board
 * This module uses a modified 7 segment encoder, which has an enable bit, which is
 * connected to the 'Found' output of the binary search.
 * Inputs:
 *		CLOCK_50, KEY, SW
 * OUTPUTs:
 *	
 */
module DE1_SoC(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	output logic [9:0] LEDR;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	// logic registers
	logic [4:0] loc;	// connects the address output of binary search to the hex displays
	logic [7:0] mem_loc;	// connects the data output of the ram to the binary search
	logic Found; // Used to enable the hex display to print the ram address
	logic swdb, swdb1, swdb2; // Used to eliminate metastability on the switch input
	
	// input sanitization
	always_ff @(posedge CLOCK_50) begin
		swdb1 <= SW[9];
		swdb2 <= swdb1;
	end
	
	// module instantiation
	binarySearch 	bs 	(.clk(CLOCK_50), .reset(~KEY[0]), .start(swdb2), .mem_loc, .A(SW[7:0]), .loc, .Done(), .Found);
	ram32x8 			ram 	(.address(loc), .clock(CLOCK_50), .data(), .wren(1'b0), .q(mem_loc));
	data2ssd 		d2s0  (.en(Found), .data_in(loc[3:0]), .ssdout(HEX0));
	data2ssd			d2s1	(.en(Found), .data_in(loc[4]), .ssdout(HEX1));
	
	// assignments
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	assign LEDR[9] = Found;
	
endmodule

/*
 *	This module is a testbench for the DE1_Soc which contains
 * a binary search, ram, and hex encoder modules
 * The testbench shows a demo type operation, by loading some values
 * and resetting multiple times
 */
module DE1_SoC_testbench();

	logic CLOCK_50;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	logic [9:0] LEDR;
	logic [6:0] HEX0;
	logic [6:0] HEX1;
	logic [6:0] HEX2;
	logic [6:0] HEX3;
	logic [6:0] HEX4;
	logic [6:0] HEX5;
	
	integer i, j;
	
	DE1_SoC dut(.*);
	
	// Simulated clock
	parameter period = 20;
	initial begin
		CLOCK_50 <= 0;
		forever
			#(period/2)
			CLOCK_50 <= ~CLOCK_50;
	end // initial

	initial begin

		// Initial board settings
		
		SW[9:0] = 10'b0;
		KEY[3:0] = 4'b1111;
		KEY[3] <= 1; @(posedge CLOCK_50);
		KEY[3] <= 0; @(posedge CLOCK_50);
		for (i = 0; i < 4000; i++) begin
			@(posedge LEDR[9]);
			
		end
		
		SW[9] = 1'b1;
		
		for (i = 0; i < 200000000; i++) begin
			@(posedge CLOCK_50);
		end
		
		$stop;
	end // initial
	
endmodule
