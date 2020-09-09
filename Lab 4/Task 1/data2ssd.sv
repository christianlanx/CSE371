/*
	Takes assorted data to convert to an output payload for seven-segment displays
	
	Input:
	data_in    - Binary value of data_in to be conerted to HEX# displays
	
	Output:
	ssdout     - Seven segment display output
	
*/
//
//`timescale 1 ps / 1 ps

module data2ssd(data_in, ssdout);

	input logic [4:0] data_in;
	output logic [6:0] ssdout;
	
	reg [6:0]int_ssdout;
	
	// Array to store all of the characters used on the seven segment display
parameter bit [6:0] SSD_ARRAY[0:15] = '{7'b1000000, 7'b1111001, 7'b0100100, 7'b0110000, 7'b0011001,
												    7'b0010010, 7'b0000010, 7'b1111000, 7'b0000000, 7'b0011000,
												    7'b0001000, 7'b0000011, 7'b1000110, 7'b0100001, 7'b0000110,
													 7'b0001110};
													 
	// Combinational logic to determine the output array of what we want on the hex display
	always_comb begin
	
		int_ssdout = SSD_ARRAY[data_in];
	
	end // always_comb
	
	assign ssdout = int_ssdout;
	
endmodule // count2ssd

// Quick testbench to determine the output ssd array is correct for all valid inputs from the top level module
module data2ssd_testbench();
	
	logic [4:0] data_in;
	logic [6:0] ssdout;
	
	int i;
	
	data2ssd dut(.*);
	
	initial begin 
		// Visually confirm ssdout payload is correct
		for (i = 0; i < 2**4; i++) begin
			data_in = i; #100;
		end // for

	end // initial

endmodule // data2ssd_testbench
