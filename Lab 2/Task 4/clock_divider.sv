// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	input logic  clock;
	output logic [31:0] divided_clocks = 0;

	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule 

// DOES THIS NEED A TESTBENCH???
// when in doubt...
module clock_divider_testbench();
	logic reset, clock;
	logic [31:0] divided_clocks;
	
	clock_divider dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD / 2) clock <= ~clock;
	end
	
	// shows the clock working twice...
	initial begin
		for (int i = 0; i < 64; i++) begin
			@(posedge clock);
		end
	$stop;
	end
endmodule
