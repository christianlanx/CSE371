/* Top-level module for DE1-SoC hardware connections to implement a ram module
 *
 * INPUTS:	SW[9]			-> 	Write Enable
				SW[8:4]		->		Address
				SW[3:0]		-> 	Data to be written to the address
				KEY[0]		-> 	Clock
				
	Outputs:	HEX5			-> 	Displays the most significant bit of the address
				HEX4			->		Displays the rest of the address
				HEX3			->		blank
				HEX2			->		Displays the data to be written
				HEX1			->		Displays the current value stored at the address
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW);
	// The usual board I/O
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	
	// declare some internal logic for passing parameters between modules
	// and to instantiate module with .* notation 
	logic [4:0] addr;
	logic clk;
	logic [3:0] data_w;
	logic wren;
	logic [3:0] data_r;
	
	// assign logic values to specified board I/O
	assign wren = SW[9];
	assign addr = SW[8:4];
	assign data_w = SW[3:0];
	assign clk = KEY[0];

	// instantiate a ram module
	ram32x4 ram (.*);

	// assign the hex encoders to display the specified outputs
	hex_encoder h5 (.bcd({3'b0, addr[4]}), .leds(HEX5));
	hex_encoder h4 (.bcd(addr[3:0]), .leds(HEX4));
	assign HEX3 = 7'b1111111;
	hex_encoder h2 (.bcd(data_w), .leds(HEX2));
	assign HEX1 = 7'b1111111;
	hex_encoder h0 (.bcd(data_r), .leds(HEX0));
endmodule  // DE1_SoC

/*
 * DE1_SoC_testbench
 * This testbench shows the function of the DE1_SoC with an instantiation
 * of the the ram32x4 System Verilog module. This testbench shows
 * stepping through each address of the memory, controlled by flicking
 * the switches
 * It then writes all possible values to a particular address in memory
 * Goes to a different address, then comes back to demonstrate that the
 * values are still there
**/
module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	// Logic values to emulate the ram module, for ease of testing
	logic wren;
	logic [4:0] address;
	logic [3:0] data;
	logic clk;
	
	// assigning these ram module interfaces to hardware
	// which the DE1_SoC then assigns to the ram module interfaces...
	assign SW[9] = wren;
	assign SW[8:4] = address;
	assign SW[3:0] = data;
	assign KEY[0] = clk;
	
	DE1_SoC dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		wren = 0;
		data = 0;
		// step through each address
		for (int i = 0; i < 32; i++) begin
			address = i; @(posedge clk);
		end
		// write each value to the address;
		for (int i = 0; i < 16; i++) begin
			data = i; @(posedge clk);
			wren = 1; @(posedge clk);
			wren = 0; @(posedge clk);
		end
		// go to a different address then come back
		address = 0; @(posedge clk);
		address = 16; @(posedge clk);
		$stop;
	end
endmodule