/*
 * This module is an instantiation of the ram32x4 library module
 * It has the same inputs and outputs as ram32x4
 * INPUTS: 	address 	->	memory address
 * 			clock		->	the clock
 * 			data		-> data to be written to the address
 *				wren		-> write enable, allow the data to be written 
 *	OUTPUTS:	q			-> data stored in the address
**/
module ram32by4(address, clock, data,	wren,	q);
	input	[4:0]  address;
	input	  clock;
	input	[3:0]  data;
	input	  wren;
	output	[3:0]  q;
	
	ram32x4 ram (.*);
endmodule

`timescale 1 ps / 1 ps

/*
 * RAM32by4 TESTBENCH
 * This testbench demonstrates stepping through each address
 * then writing each value to a specific address
 * Then going to a different address and coming back to see
 * the same value is still there.
**/
module ram32by4_testbench();
	logic [4:0] address;
	logic clock, wren;
	logic [3:0] data, q;
	
	parameter CLOCK_PERIOD = 100;
	
	ram32by4 dut (.*);
	
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD / 2) clock <= ~clock;
	end
	
	initial begin
		wren = 0;
		data = 0;
		for (int i = 0; i < 32; i++) begin
			address = i; @(posedge clock);
		end
		for (int i = 0; i < 16; i++) begin
			data = i; 	@(posedge clock);
			wren = 1; 	@(posedge clock);
			wren = 0; 	@(posedge clock);
		end
		address = 0; 	@(posedge clock);
							@(posedge clock);
		address = 16; 	@(posedge clock);
							@(posedge clock);
	$stop;
	end
endmodule
