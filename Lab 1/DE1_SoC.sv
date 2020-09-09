/* Top-level module for DE1-SoC hardware connections to implement a fullAdder.
 *
 * The inputs are connected to switches (a - SW2, b - SW1, cin - SW0).
 * The outputs are connected to LEDs (sum - LEDR0, cout - LEDR1).
 */
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_0);
	input logic CLOCK_50;		// 50MHz clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [35:0] GPIO_0;
	
	logic reset, outer_gate, inner_gate, car_exit, car_enter;
	logic [5:0][4:0] display;
	
	assign reset = SW[0];
	assign outer_gate = ~KEY[1];
	assign inner_gate = ~KEY[0];
	assign GPIO_0[14] = outer_gate;
	assign LEDR[1] = outer_gate;
	assign GPIO_0[16] = inner_gate;
	assign LEDR[0] = inner_gate;
	
	ParkingLotSensor pls (.clk(CLOCK_50), .reset, .outer_gate, .inner_gate, .car_exit, .car_enter);
	CarCounter cc (.clk(CLOCK_50), .reset, .car_exit, .car_enter, .hex_out(display));
	hexEncoder h0 (.bcd(display[0]), .leds(HEX0));
	hexEncoder h1 (.bcd(display[1]), .leds(HEX1));
	hexEncoder h2 (.bcd(display[2]), .leds(HEX2));
	hexEncoder h3 (.bcd(display[3]), .leds(HEX3));
	hexEncoder h4 (.bcd(display[4]), .leds(HEX4));
	hexEncoder h5 (.bcd(display[5]), .leds(HEX5));

endmodule  // DE1_SoC


/* testbench for the DE1_SoC */
module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_0;
	
	logic reset, outer_gate, inner_gate;
	assign SW[0] = reset;
	assign KEY[1] = ~outer_gate;
	assign KEY[0] = ~inner_gate;
	
	DE1_SoC dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	int i;
	
	initial begin
		reset <= 1;												@(posedge CLOCK_50);
		reset <= 0;	outer_gate <= 0; inner_gate <= 0;@(posedge CLOCK_50);
		// initially empty...

		// 25 cars enter the lot
		for (i = 0; i < 25; i++) begin
			outer_gate <= 1;								@(posedge CLOCK_50);
			inner_gate <= 1; 								@(posedge CLOCK_50);
			outer_gate <= 0;								@(posedge CLOCK_50);
			inner_gate <= 0;								@(posedge CLOCK_50);
		end
		
		// 25 cars exit the lot
		for (i = 0; i < 25; i++) begin
			inner_gate <= 1;									@(posedge CLOCK_50);
			outer_gate <= 1;									@(posedge CLOCK_50);
			inner_gate <= 0;									@(posedge CLOCK_50);
			outer_gate <= 0;									@(posedge CLOCK_50);
		end
		$stop;
	end
	
endmodule  // DE1_SoC_testbench
