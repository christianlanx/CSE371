/* Top-level module for DE1-SoC hardware connections to implement a
 * 32x4, 2-port RAM module, which can be written to any address, and
 * cycles through the read addresses about once per second
 * 
 *	The inputs:
 *		SW[9] - write enable
 *		SW[8:4] - write address
 *		SW[3:0] - write data
 *		KEY[0] - reset
 * The outputs: 
 * 	H5 and H4 print write address
 * 	H3 and H2 print read address
 *		H1 prints the data to write
 *		H0 prints the read data from the RAM
 */
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW);
	// The usual inputs and outputs
	input logic CLOCK_50;		// 50 MHz Clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 24; // 1.5 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .divided_clocks(clk));
	
	// These two logic arrays are used for purposes of input synchronization
	logic [9:0] SW1, SW2;
	//logic [3:0] KEY1, KEY2;
	
	// The following code synchronizes the switch and key inputs
	always_ff @(posedge CLOCK_50) begin
		SW1 <= SW;
		SW2 <= SW1;
	end
	
	/*
	always_ff @(posedge clk[whichClock]) begin
		KEY1 <= KEY;
		KEY2 <= KEY1;
	end
	*/
	
	// Logic values for module initialization
	logic wren;
	logic [4:0] rdaddress;
	logic [4:0] wraddress;
	logic [3:0] data;
	logic [3:0] q;
	logic clock;
	logic reset;
	
	// Assigns logic values to hardware I/O, for convenience
	assign wren = SW2[9];
	assign wraddress = SW2[8:4];
	assign data = SW2[3:0];
	assign clock = CLOCK_50;
	assign reset = ~KEY[0];
	
	// create a 32x4, 2-port ram
	ram32x4port2 ram (.*);
	
	// create a 5 bit counter, which outputs to rdaddress
	counter c (.clk(clk[whichClock]), .reset, .count(rdaddress));
	
	// A series of hex_encoders to control each of the HEX displays
	hex_encoder h5 (.bcd({3'b0, wraddress[4]}), 	.leds(HEX5));
	hex_encoder h4 (.bcd(wraddress[3:0]), 			.leds(HEX4));
	hex_encoder h3 (.bcd({3'b0, rdaddress[4]}),	.leds(HEX3));
	hex_encoder h2 (.bcd(rdaddress[3:0]), 			.leds(HEX2));
	hex_encoder h1 (.bcd(data), 						.leds(HEX1));
	hex_encoder h0 (.bcd(q), 							.leds(HEX0));	
endmodule  // DE1_SoC

`timescale 1 ps / 1 ps

// DE1_SoC_testbench
// this testbench instantiates a DE1_SoC module
// First, it just sits there for a minute to show the read address
// doing its thing
// then it assigns a value to address zero, waits a bit
// then hits the reset button to go back to read address zero
module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	logic wren;
	logic [4:0] rdaddress;
	logic [4:0] wraddress;
	logic [3:0] data;
	logic [3:0] q;
	logic clk;
	logic reset;
	
	// Assigns logic values to hardware I/O, for convenience
	assign SW[9] = wren;
	assign SW[8:4] = wraddress;
	assign SW[3:0] = data;
	assign CLOCK_50 = clk;
	assign KEY[0] = reset;
	
	DE1_SoC dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0;
		wren = 0;
		wraddress = 0;
		data = 0;
		// im not sure how long to wait...
		for (int i = 0; i < 64000000; i++) begin
			@(posedge clk);
		end
		wren = 1; data = 4'b0010; @(posedge clk);
		wren = 0; reset = 1; @(posedge clk);
		$stop;
	end
endmodule