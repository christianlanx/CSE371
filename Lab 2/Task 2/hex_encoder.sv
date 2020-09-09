/**
	This module takes in a 4 digit binary number and outputs
	the associated hexdecimal digit, encoded for a
	seven-segment display.
**/

module hex_encoder(bcd, leds);
	input logic [3:0] bcd;
	output logic [6:0] leds;
	
	always_comb begin
		case(bcd)
			// 3210				 6543210
			4'b0000: leds = 7'b1000000;	//0
			4'b0001:	leds = 7'b1111001;	//1
			4'b0010:	leds = 7'b0100100;	//2
			4'b0011: leds = 7'b0110000;	//3
			4'b0100: leds = 7'b0011001;	//4
			4'b0101: leds = 7'b0010010;	//5
			4'b0110: leds = 7'b0000010;	//6
			4'b0111: leds = 7'b1111000;	//7
			4'b1000: leds = 7'b0000000;	//8
			4'b1001: leds = 7'b0010000;	//9
			4'b1010: leds = 7'b0001000;	//A
			4'b1011: leds = 7'b0000011;	//b
			4'b1100:	leds = 7'b1000110;	//C
			4'b1101: leds = 7'b0100001;	//d
			4'b1110: leds = 7'b0000110;	//E
			4'b1111: leds = 7'b0001110;	//F
		endcase
	end
endmodule


/**
	This is a testbench for the hex encoder module
	It shows the output of every input value
**/
module hex_encoder_testbench();
	logic [3:0] bcd;
	logic [6:0] leds;
	
	hex_encoder dur (.*);
	
	initial begin
		for (int i = 0; i < 16; i++) begin
			bcd = i; #10;
		end
		$stop;
	end
endmodule
