module chr_rom_ctrl (

		input clk,

		input [7:0] chr_val,
		
		input [2:0] col,
		input [3:0] row,
		
		output pixel
	);
	
	
	wire [10:0] pixel_addr;
	wire [7:0] char_byte;
	
	assign pixel_addr = ((chr_val - 32) << 4) + row;   //so for the "1", thats 21h, or 33. 33-32 is 1, 
																		//1<<4 is 16, so this should go from 16 to 31, or 10h to 1f
	
	
	(* keep *) wire [7:0] pixel_mask;
	assign pixel_mask = (8'b1 << col);
	
	chr_rom d (
		.address (pixel_addr),
		.clock (clk),
		.q (char_byte)
	);
	
			 
	assign pixel = (char_byte & pixel_mask) >> col; // so if char_byte is 00011000, pixel mask is 00010000, so the first is 00010000
endmodule //chr_rom_ctrl
