module chr_rom_ctrl (

		input clk,

		input [7:0] chr_val,
		
		input [3:0] col,
		input [3:0] row,
		
		output pixel
	);
	
	wire [7:0] m_char_line;
	
	wire [10:0] pixel_addr;
	
	assign char_line = m_char_line;
	
	chr_rom a (
		.address (pixel_addr),
		.clock (clk),
		.q (m_char_col)
	);
	
endmodule //chr_rom_ctrl