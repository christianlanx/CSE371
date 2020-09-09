module DE1_SoC(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	output logic [9:0] LEDR;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	logic [4:0] count;
	
	logic swdb, swdb1, swdb2; // Debouncing
	
	logic [31:0] clk;
	
	bitCounter main(.clk(CLOCK_50), .reset(~KEY[0]), .s(swdb2), .Done(LEDR[9]), .A(SW[7:0]), .result(count));
	data2ssd   d2s(.data_in(count), .ssdout(HEX0));
	
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
//	assign LEDR[8:0] = 9'b000000000;
		
endmodule

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
		
		SW[9:0] = 10'b000001111;
		KEY[3:0] = 4'b1111;

		for (i = 0; i < 4000; i++) begin
			@(posedge CLOCK_50);
			
		end
		
		SW[9] = 1'b1;
		
		for (i = 0; i < 200000000; i++) begin
			@(posedge CLOCK_50);
		end
		
		// Simulate a reset
/*
		KEY[0] = 1'b0; @(posedge CLOCK_50);
		KEY[0] = 1'b1; @(posedge CLOCK_50);

		               @(posedge CLOCK_50);
		
		
		for (i = 2**4; i < 2**8; i++) begin
			SW[7:0] = i[7:0]; @(posedge CLOCK_50);
			SW[9] = 1'b1;
			//@(posedge LEDR);
			for (j = 0; j < 10; j++) begin
				@(posedge CLOCK_50);
			end
			SW[9] = 1'b0; @(posedge CLOCK_50);
							  @(posedge CLOCK_50);
		end // for
*/
		$stop;
	end // initial
	
endmodule
