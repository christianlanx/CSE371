module bitCounter (clk, reset, s, Done, A, result);
	input  logic clk, reset, s;
	output logic Done;
	input  logic [7:0] A;
	output logic [4:0] result;
						
	// define status and control signals
	logic A_eq_0, A0;
	logic Load_A, Res_eq_0, Incr_Res, R_Shift_A;
	
	// instantiate control and datapath
	bitCounter_control c_unit (.*);
	bitCounter_datapath d_unit (.*);
	
endmodule

module bitCounter_testbench();

	// define parameters (input width and clock period)
	parameter W = 8, T = 20;
	
	// define module port connections
	logic clk;
	logic [7:0] A;
	logic reset, s, Done;
	logic [4:0] result;
	
	bitCounter dut (.*);
	
	//create simulated clock
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end	// clock initial
	
	integer i;
	
	initial begin
		reset <= 1; s <= 0; 	@(posedge clk);
		reset <= 0;				@(posedge clk);
		
		for (i = 0; i < 2**W; i++) begin
			s <= 0; A <= i;   @(posedge clk);
			s <= 1;         	@(posedge clk);
			@(posedge Done);
			s <= 0; 				@(posedge clk);
		end
		
		@(posedge clk);
		$stop;
	end	// initial

endmodule
