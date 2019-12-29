module chr_rom_ctrl (

		input clk,

		input [7:0] chr_val,
		
		input [2:0] col,
		input [3:0] row,
		
		output pixel
	);
	
	wire [10:0] pixel_addr;
	wire [7:0] char_byte;
	
	assign pixel_addr = ((chr_val - 32) << 4) + row;
	
	chr_rom a (
		.address (pixel_addr),
		.clock (clk),
		.q (char_byte)
	);
	
	wire [7:0] pixel_mask;
	
	mux_3to8 b (
		.in (col),
		.out (pixel_mask)
	);
	
	assign pixel = char_byte & pixel_mask;
	
endmodule //chr_rom_ctrl

module mux_3to8 (
	input [3:0] in,
	output [7:0] out
	);
	
	assign out[0] = (in == 3'd0) ? 1'b0 : 1'b1;
	assign out[1] = (in == 3'd1) ? 1'b0 : 1'b1;
	assign out[2] = (in == 3'd2) ? 1'b0 : 1'b1;
	assign out[3] = (in == 3'd3) ? 1'b0 : 1'b1;
	assign out[4] = (in == 3'd4) ? 1'b0 : 1'b1;
	assign out[5] = (in == 3'd5) ? 1'b0 : 1'b1;
	assign out[6] = (in == 3'd6) ? 1'b0 : 1'b1;
	assign out[7] = (in == 3'd7) ? 1'b0 : 1'b1;
	
	
endmodule //mux_3to8