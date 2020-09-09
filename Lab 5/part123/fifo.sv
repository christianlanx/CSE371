module fifo #(parameter DATA_WIDTH=24, ADDR_WIDTH=3)
            (clk, reset, rd, wr, empty, full, w_data, r_data);

	input  logic clk, reset, rd, wr;
	output logic empty, full;
	input  logic [DATA_WIDTH-1:0] w_data;
	output logic [DATA_WIDTH-1:0] r_data;
	
	// signal declarations
	logic [ADDR_WIDTH-1:0] w_addr, r_addr;
	logic w_en;
	
	// enable write only when FIFO is not full
	assign w_en = wr & (~full | rd);
	
	// instantiate FIFO controller and register file
	fifo_ctrl #(DATA_WIDTH, ADDR_WIDTH) c_unit (.*);
	reg_file #(DATA_WIDTH, ADDR_WIDTH) r_unit (.*);
	
endmodule

module fifo_testbench();
	logic clk, reset, rd, wr;
	logic empty, full;
	logic [23:0] w_data;
	logic [23:0] r_data;
	
	fifo dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		rd <= 0; wr <= 0; w_data <= 0; r_data <= 0;
		reset <= 1; @(posedge clk);
		reset <= 0; wr <= 1; w_data = 0;
		@(posedge clk);
		// write some initial data
		for (int i = 1; i < 8; i++) begin
			w_data <= i;
			@(posedge clk);
		end
		rd <= 1;
		for (int i = 8; i < 32; i++) begin
			w_data <= i;
			@(posedge clk);
		end
		
		// try writing while full
		@(posedge clk);
		wr<=0; @(posedge clk);
		
		//read and write while full
		wr <= 1; rd <= 1; w_data = 16'hffff;
		@(posedge clk);
		@(posedge clk);
		
		//read and write while very full
		wr <= 1; rd <= 1; w_data = 16'haaaa;
		@(posedge clk);
		
		
		// read until empty, and then try to read while empty
		rd <= 1; wr <= 0;
		for (int i = 0; i < 16; i++) begin
			@(posedge clk);
		end

		$stop;
	end
endmodule