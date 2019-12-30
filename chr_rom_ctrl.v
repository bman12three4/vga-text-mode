module chr_rom_ctrl (

		input clk,

		input [7:0] chr_val,
		
		input [2:0] col,
		input [3:0] row,
		
		output pixel
	);
	
	(* keep *) wire [10:0] pixel_addr;
	(* keep *) wire [7:0] char_byte;
	
	assign pixel_addr = ((chr_val - 32) << 4) + row;   //so for the "1", thats 21h, or 33. 33-32 is 1, 
																		//1<<4 is 16, so this should go from 16 to 31, or 10h to 1f
	
	chr_rom a (
		.address (pixel_addr),
		.clock (clk),
		.q (char_byte)
	);
	
	(* keep *) wire [7:0] pixel_mask;
	
	mux_3to8 b (
		.in (col),
		.out (pixel_mask)
	);
	
	assign pixel = (char_byte & pixel_mask) >> col; // so if char_byte is 00011000, pixel mask is 00010000, so the first is 00010000
																	// col would be 4, 00010000 >> 4 is 1, so on.
endmodule //chr_rom_ctrl

module mux_3to8 (
	input [3:0] in,
	output reg [7:0] out
	);
	
	always @(in)
		case (in)   //case statement. Check all the 8 combinations.
			3'b000 : out = 8'b00000001;
			3'b001 : out = 8'b00000010;
			3'b010 : out = 8'b00000100;
			3'b011 : out = 8'b00001000;
			3'b100 : out = 8'b00010000;
			3'b101 : out = 8'b00100000;
			3'b110 : out = 8'b01000000;
			3'b111 : out = 8'b10000000;
			//To make sure that latches are not created create a default value for output.
			default : out = 8'b00000000; 
		endcase

	
endmodule //mux_3to8