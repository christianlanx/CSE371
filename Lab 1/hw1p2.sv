module hw1p2(clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	typedef enum logic[3:0] {A, B, C, D, E} state;
	state ps, ns;
	
	//state logic
	always_comb begin
		case (ps)
			A: if (in) begin
					ns = B;
					out = 1'b1;
				end
				else begin
					ns = A;
					out = 1'b0;
				end
			B: if (in) begin
					ns = C;
					out = 1'b0;
				end
				else begin
					ns = D;
					out = 1'b0;
				end
			C: if (in) begin
					ns = D;
					out = 1'b1;
				end
				else begin
					ns = A;
					out = 1'b0;
				end
			D: if (in) begin
					ns = E;
					out = 1'b1;
				end
				else begin
					ns = D;
					out = 1'b1;
				end
			E: if (in) begin
					ns = B;
					out = 1'b1;
				end
				else begin
					ns = C;
					out = 1'b0;
				end
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= A;
		else
			ps <= ns;
	end
endmodule

module hw1p2_testbench();
	logic clk, reset, in, out;
	
	hw1p2 dut(.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;					@(posedge clk);
		reset <= 0; in <= 0;		@(posedge clk);
										@(posedge clk);
		in <= 1;						@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		in <= 0;						@(posedge clk);
										@(posedge clk);
		in <= 1;						@(posedge clk);
		in <= 0;						@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		$stop;
	end								
endmodule