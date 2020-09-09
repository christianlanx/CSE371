/*
	This module takes input of car exit and car enter signals
	And outputs a series of binary numbers, which are interpreted by a hex encoder
	
	When the number of cars in the lot is zero, it outputs 'CLEAR0'
	When there are 25 cars in the lot, it outputs 'FULL25'
	This design does not respond if a car enters and the lot is full, or if a car exits
	while the lot is empty. 
*/
module CarCounter(clk, reset, car_exit, car_enter, hex_out);
	input logic clk, reset, car_exit, car_enter;
	output logic [5:0][4:0] hex_out;
	
	logic [4:0] count;
	
	always_comb begin
		// 25
		if (count == 5'b11001)
			hex_out = {{5'b10000}, {5'b10001}, {5'b01100}, {5'b01100}, {5'b00010}, {5'b00101}};
		// 0
		else if (count == 5'b00000)
			hex_out = {{5'b01010}, {5'b01100}, {5'b01101}, {5'b01110}, {5'b01111}, {5'b00000}};
		// less than 10
		else if (count < 5'b01010)
			hex_out = {{5'b10010}, {5'b10010}, {5'b10010}, {5'b10010}, {5'b10010}, {count}};
		// less than 20
		else if (count < 5'b10100)
			hex_out = {{5'b10010}, {5'b10010}, {5'b10010}, {5'b10010}, {5'b00001}, {count - 5'b01010}};
		// between 20 and 25
		else
			hex_out = {{5'b10010}, {5'b10010}, {5'b10010}, {5'b10010}, {5'b00010}, {count - 5'b10100}};
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			count <= 5'b00000;
		else
			if (car_enter & (count < 5'b11001))
				count += 1'b1;
			else if (car_exit & (count > 5'b00000))
				count -= 1'b1;
	end
endmodule

/*
	This module takes a 5'b input, and converts it to a 7 segment display output
	According to the table of values here defined
*/
module hexEncoder(bcd, leds);
	input logic [4:0] bcd;
	output logic [6:0] leds;
	always_comb begin
			case (bcd)
				// 43210				  6543210
				5'b00000: leds = 7'b1000000;	// 0
				5'b00001: leds = 7'b1111001;	// 1
				5'b00010: leds = 7'b0100100;	// 2
				5'b00011: leds = 7'b0110000;	// 3
				5'b00100: leds = 7'b0011001;	// 4
				5'b00101: leds = 7'b0010010;	// 5
				5'b00110: leds = 7'b0000010;	// 6
				5'b00111: leds = 7'b1111000;	// 7
				5'b01000: leds = 7'b0000000;	// 8
				5'b01001: leds = 7'b0010000;	// 9
				5'b01010: leds = 7'b1000110;	// C
				5'b01100: leds = 7'b1000111;  // L
				5'b01101: leds = 7'b0000110;	// E
				5'b01110: leds = 7'b0001000;	// A
				5'b01111: leds = 7'b0101111;	// R
				5'b10000: leds = 7'b0001110;	// F
				5'b10001: leds = 7'b1000001;	// U
				5'b10010: leds = 7'b1111111;	// BLANK
				default:	 leds = 7'b1111111;	// also blank...
		endcase
	end
endmodule


module CarCounter_testbench();
	logic clk, reset, car_exit, car_enter;
	logic [5:0][4:0] hex_out;
	int i;
	
	CarCounter dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;											@(posedge clk);
		reset <= 0;	car_exit <= 0; car_enter <= 0;@(posedge clk);
		// initially empty...


		// 25 cars enter the lot
		for (i = 0; i < 25; i++) begin
			car_enter <= 1;								@(posedge clk);
			car_enter <= 0; 								@(posedge clk);
		end
		
		// 25 cars exit the lot
		for (i = 0; i < 25; i++) begin
			car_exit <= 1;									@(posedge clk);
			car_exit <= 0;									@(posedge clk);
		end
		$stop;
	end
endmodule
		
		
		