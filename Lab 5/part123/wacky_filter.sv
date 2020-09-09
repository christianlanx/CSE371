

// Quick test bench to test the functionality of our basic N-1 register wide FIR filter
/*
module wacky_filter_testbench();

	parameter signed N = 93, SIZE = 24;

	logic clk, reset;
	logic signed [SIZE-1:0] in_left, in_right;
	logic signed [SIZE-1:0] out_left, out_right;
	logic read_ready;
	parameter T = 20;
	
	wacky_filter #(N, SIZE) dut(.*);
	
	// Simulated clock
	initial begin
	clk <= 0;
	forever #(T/2) clk <= ~clk;
	end	// clock initial
	
	integer signed i, noise_l, noise_r;
	
	initial begin
		read_ready = 1'b1;
		in_left = 24'd0;
		in_right = 24'd0;
		
		// Simulated reset
		reset = 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		for (i = 0; i < 1000; i++) begin
			
			noise_l = $urandom_range(-2**23, 2**23 - 1);
			noise_r = $urandom_range(-2**23, 2**23 - 1);
			
			in_left = noise_l[23:0];
			in_right = noise_r[23:0];
			@(posedge clk);
//			in_left = i * 24'd64; in_right = i * 24'd128; @(posedge clk);
		end //for
	
		$stop;
	end // initial
	

endmodule // wacky_filter_testbench
*/