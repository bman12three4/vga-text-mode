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
	output [7:0] out
	);
	
	assign out [0] = (in == 3'b000) ? 1'b1 : 1'b0;
	assign out [1] = (in == 3'b001) ? 1'b1 : 1'b0;
	assign out [2] = (in == 3'b010) ? 1'b1 : 1'b0;
	assign out [3] = (in == 3'b011) ? 1'b1 : 1'b0;
	assign out [4] = (in == 3'b100) ? 1'b1 : 1'b0;
	assign out [5] = (in == 3'b101) ? 1'b1 : 1'b0;
	assign out [6] = (in == 3'b110) ? 1'b1 : 1'b0;
	assign out [7] = (in == 3'b111) ? 1'b1 : 1'b0;

	
endmodule //mux_3to8