module chr_rom_ctrl (

		input clk,

		input [7:0] chr_val,
		
		input [2:0] col,
		input [3:0] row,
		
		input [7:0] pixel_mask,
		
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
	
			 
	assign pixel = (char_byte & pixel_mask) >> col; // so if char_byte is 00011000, pixel mask is 00010000, so the first is 00010000
																	// col would be 4, 00010000 >> 4 is 1, so on.
endmodule //chr_rom_ctrl