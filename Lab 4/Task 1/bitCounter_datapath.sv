module bitCounter_datapath (clk, reset, A, Res_eq_0, Load_A, Incr_Res, R_Shift_A, A_eq_0, A0, result);
	input  logic clk, reset;
	input  logic [7:0] A;
	input  logic Res_eq_0, Load_A, Incr_Res, R_Shift_A;
	output logic A_eq_0, A0;
	output logic [4:0] result;
	
	// internal datapath signals and registers
	// can't think of any right now
	logic [7:0] A_reg;
	
	// datapath logic
	always_ff @(posedge clk) begin
		if (Load_A) begin
			A_reg <= A;
			result <= 0;
		end
		if (R_Shift_A) 		A_reg <= A_reg >> 1;
		if (Res_eq_0)			result <= 5'b00000;
		if (Incr_Res)			result <= result + 1'b1;
	end
	
	// output assignments
	assign A_eq_0 				= (A_reg == 0);
	assign A0					= A_reg[0];
endmodule
