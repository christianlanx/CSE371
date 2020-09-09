module bitCounter_control (clk, reset, s, Done, A_eq_0, A0, Res_eq_0, Load_A, Incr_Res, R_Shift_A);
	input  logic clk, reset, s;
	output logic Done;
	input  logic A_eq_0, A0;
	output logic Res_eq_0, Load_A, Incr_Res, R_Shift_A;

	// define state names and variables
	enum { S1, S2, S3 } ps, ns; 
	
	// controller logic w/ synchronous reset
	always_ff @(posedge clk)
		if (reset)
			ps <= S1;
		else
			ps <= ns;
	
	// next state logic
	always_comb
		case (ps)
			S1: ns = s ? S2 : S1;
			S2: ns = A_eq_0 ? S3 : S2;
			S3: ns = s ? S3 : S1;
		endcase
		
	// output assignments
	assign Done 		= (ps == S3);
	assign R_Shift_A	= (ps == S2);
	assign Incr_Res	= (ps == S2) & ~A_eq_0 & A0;
	assign Load_A 		= (ps == S1) & (s == 0);
	assign Res_eq_0	= (ps == S1);
	
endmodule