module text_mode (
		input clk,

		input [7:0] data_sw_i,
		
		input wren_i,
		
		input addr_inc_dir_i,
		input addr_inc_i,
		
		output reg [3:0] r_vga_o,
		output reg [3:0] g_vga_o,
		output reg [3:0] b_vga_o,
		
		output [6:0] addr_hex0_o,
		output [6:0] addr_hex1_o,
		output [6:0] data_hex0_o,
		output [6:0] data_hex1_o,
		
		output [7:0] data_led_o,
		output dir_led_o,
		
		output wren_led_o
	);
	
	wire vga_clk;
	
	reg [10:0] screen_address;
	
	reg [7:0] col;
	reg [7:0] row;
	
	reg [3:0] sub_col;
	reg [3:0] sub_row;
	
	wire [7:0] chr_val;
	
	wire pixel;
	
	assign addr_hex0_o = ~screen_address [6:0];
	assign addr_hex1_o = ~screen_address [10:7];
	
	assign data_led_o = chr_val;
	
	assign wren_led_o = wren_i;
	assign dir_led_o = addr_inc_dir_i;
	
	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b (
		.address (screen_address),
		.clock (vga_clk),
		.data (data_sw_i),
		.wren (wren_i),
		.q (chr_val)
	);
	
	chr_rom_ctrl c (
		.clk (vga_clk),
		.chr_val (chr_val),
		.col (sub_col),
		.row (sub_row),
		.pixel (pixel)
	);
	
	
	always @ (posedge addr_inc_i) begin
		if (addr_inc_dir_i == 1) begin
			screen_address <= screen_address + 1;
		end
		else begin
			screen_address <= screen_address - 1;
		end
	end

	

endmodule //text_mode