module hw1p4 (clk, a, b, c, y);
	input logic clk, a, b, c;
	output logic y;
	logic x;
	
	always_ff @(posedge clk) begin
		x = a & b;
		y = x | c;
	end
endmodule