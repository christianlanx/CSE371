module noise_filter #(parameter N = 8) (clk, reset, in_left, in_right, out_left, out_right);
	input logic clk, reset;
	input logic  [23:0] in_left, in_right;
	output logic [23:0] out_left, out_right;
	
	logic [23:0] reg_l [0:N-2];
	logic [23:0] reg_r [0:N-2];
	logic [23:0] reg_l_out, reg_r_out;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			for (int i = N-2; i >= 0; i--) begin
				reg_l[i] <= in_left;
				reg_r[i] <= in_right;
			end	// for
		end	// if reset
		else begin
			for (int i = N-2; i > 0; i--) begin
				reg_l[i] <= reg_l[i-1];
				reg_r[i] <= reg_r[i-1];
			end	// for 
			reg_l[0] <= in_left;
			reg_r[0] <= in_right;
			out_left <= reg_l_out;
			out_right <= reg_r_out;
		end	// else
	end	// always ff
	
	
	always @(*) begin
		reg_l_out = 0;
		reg_r_out = 0;
		for (int i = 0; i <= N-2; i++) begin
			reg_l_out = reg_l_out + reg_l[i] / N;
			reg_r_out = reg_r_out + reg_r[i] / N;
		end
	end	// always
endmodule

module noise_filter_testbench();

	parameter N=8, T=20;
	
	logic clk, reset;
	logic [23:0] in_left, in_right, out_left, out_right;
	
	noise_filter #(N) dut (.*);
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end	// initial
	
	initial begin
		in_left <= 8; in_right <= 8; reset <= 1; @(posedge clk);
		in_left <= 0; in_right <= 0; reset <= 0; @(posedge clk);
		for (int i = 0; i < N-2; i++) begin
			@(posedge clk);
		end	// for
		$stop;
	end	// initial
	
endmodule
