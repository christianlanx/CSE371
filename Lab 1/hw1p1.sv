module hw1p1(clk, reset, x, y, s);
	input  logic clk, reset, x, y;
	output logic s;
	logic cout, cin;
	
	assign s = x ^ y ^ cin;
	assign cout = x&y | x&cin | y&cin;
	
	always_ff @(posedge clk) begin
		if (reset)
			cin <= 1'b0;
		cin <= cout;
	end
endmodule

module hw1p1_testbench();
	logic clk, reset, x, y, s;
	
	hw1p1 dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;							@(posedge clk);
		reset <= 0; x <= 0; y <= 0;	@(posedge clk);
												@(posedge clk);
		x <= 1;								@(posedge clk);
		x <= 1;								@(posedge clk);
		x <= 0;								@(posedge clk);
		y <= 1;								@(posedge clk);
		y <= 1;								@(posedge clk);
		y <= 0;								@(posedge clk);
		x <= 1;								@(posedge clk);
		y <= 1;								@(posedge clk);
		x <= 0; y <= 0;					@(posedge clk);
		x <= 1; y <= 1;					@(posedge clk);
		x <= 1; y <= 0;					@(posedge clk);
		x <= 0; y <= 1;					@(posedge clk);
		x <= 1; y <= 1;					@(posedge clk);
												@(posedge clk);
		x <= 0;								@(posedge clk);
		x <= 1;								@(posedge clk);
		y <= 0;								@(posedge clk);
		y <= 1;								@(posedge clk);
		x <= 0; y <= 0;					@(posedge clk);
		$stop;
	end
endmodule