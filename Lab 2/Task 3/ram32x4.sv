/*
 * ram32x4 is a synchronous single port ram with a depth of 32
   and a width of 4, it stores 32 hexdecimal numbers
	It always prints out the currently stored value in the currently
	selected address, and writes over the value in the cell
	if write_enable is high, on the next rising edge of the clock
	inputs: address, clock, data_write, write_enable
	output: data_read -> the data stored at the current address
**/
module ram32x4(addr, clk, data_w, wren, data_r);
	// Basically the same as from the lecture slides...
	input logic [4:0] addr;
	input logic clk;
	input logic [3:0] data_w;
	input logic wren;
	output logic [3:0] data_r;
	
	// 32 depth, 4 width
	logic [3:0] ram [0:31];
	
	always_ff @(posedge clk) begin
		if (wren) begin
			ram[addr] <= data_w;
			data_r <= data_w;
		end
		else begin
			data_r <= ram[addr];
		end
		
	end
endmodule


/*
 * The ram32x4 testbench goes through each address of the ram
 * and writes every possible value to that address
*/
module ram32x4_testbench();
	logic clk, wren;
	logic [4:0] addr;
	logic [3:0] data_w, data_r;
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	ram32x4 dut (.*);
	
	initial begin
		for (int i = 0; i < 32; i++) begin
			// increment the address
			addr = i;
			for (int j = 0; j < 16; j++) begin
				// write all possible vlues of data to that addy
				data_w = j;
				wren = 0; @(posedge clk);
				wren = 1; @(posedge clk);
			end
		end
	$stop;
	end
endmodule
