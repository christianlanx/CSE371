/* Top-level module for DE1-SoC hardware connections to implement a fullAdder.
 *
 * The inputs are connected to switches (a - SW2, b - SW1, cin - SW0).
 * The outputs are connected to LEDs (sum - LEDR0, cout - LEDR1).
 */
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_0);
	input logic CLOCK_50;		// 50MHz clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [35:0] GPIO_0;
	
	logic [4:0] address;
	logic clock;
	logic [3:0] data;
	logic wren;
	logic [3:0] q;
	
	ram32x4 (.*);
	
	assign wren = SW[9];
	assign address = SW[8:4];
	assign data = SW[3:0];
	assign clock = KEY[0];

	hex_encoder h5 (.bcd({3'b0, address[4]}), .leds(HEX5));
	hex_encoder h4 (.bcd(address[3:0]), .leds(HEX4));
	assign HEX3 = 7'b1111111;
	hex_encoder h2 (.bcd(data), .leds(HEX2));
	assign HEX1 = 7'b1111111;
	hex_encoder h0 (.bcd(q), .leds(HEX0));
	

endmodule  // DE1_SoC

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
	