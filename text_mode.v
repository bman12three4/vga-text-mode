module text_mode (
		input clk,

		input [7:0] data_sw_i,
		
		input wren_i,
		
		input addr_inc_dir_i,
		input addr_inc_i,
		
		output reg [3:0] r_vga_o,
		output reg [3:0] g_vga_o,
		output reg [3:0] b_vga_o,
		
		output reg v_sync_o,
		output reg h_sync_o,
		
		output [6:0] addr_hex0_o,
		output [6:0] addr_hex1_o,
		output [6:0] addr_hex2_o,
		output [6:0] data_hex_o,
		
		output [7:0] data_led_o,
		output dir_led_o,
		
		output wren_led_o
	);
	
	wire vga_clk;
	
	reg [11:0] screen_address;
	reg [11:0] user_address;

	
	reg wren_m;
	
	reg [6:0] screenX; //These are the 80x25 subacters
	reg [4:0] screenY;
	
	reg [2:0] subX;	 //These are the 9x16 pixel subacters
	reg [3:0] subY;
	
	reg [9:0] h_pixel;
	reg [8:0] line;
	
	(* keep *) wire [7:0] chr_val;
	
	reg [7:0] user_char;
	
	(* keep *) wire pixel;
	
	assign data_led_o = user_char;
	
	assign wren_led_o = wren_m;
	assign dir_led_o = addr_inc_dir_i;
	
	seven_seg addr0 (
		.in (user_address[3:0]),
		.out (addr_hex0_o)
	);
	
	seven_seg addr1 (
		.in (user_address[7:4]),
		.out (addr_hex1_o)
	);
	
	seven_seg addr2 (
		.in (user_address[11:8]),
		.out (addr_hex2_o)
	);
	
	seven_seg data (
		.in (user_char[6:0]),
		.out (data_hex_o)
	);

	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b (
		.address (screen_address),
		.clock (clk),
		.data (data_sw_i),
		.wren (wren_m),
		.q (chr_val)
	);
	
	chr_rom_ctrl c (
		.clk (clk),
		.chr_val (chr_val),
		.col (subX),
		.row (subY),
		.pixel (pixel)
	);
	
	always @(posedge addr_inc_i) begin
		if (addr_inc_dir_i == 1) begin
			user_address <= user_address + 11'b1;
		end
		else begin
			user_address <= user_address - 11'b1;
		end
	end
	
	always @(posedge clk) begin
		if (h_pixel < 640) begin
			wren_m <= 0;
			screen_address [6:0] <= screenX;
			screen_address [11:7] <= screenY;
		end
		else begin
			screen_address <= user_address;
			user_char <= chr_val;
			wren_m <= ~wren_i;
		end
	end
	
	always @(posedge vga_clk) begin

		if (h_pixel < 640) begin
			
			if (pixel == 1) begin
				r_vga_o <= 4'b1111;
				g_vga_o <= 4'b1111;
				b_vga_o <= 4'b1111;
			end
			else begin
				r_vga_o <= 4'b0000;
				g_vga_o <= 4'b0000;
				b_vga_o <= 4'b0000;
			end
			h_pixel <= h_pixel + 10'b1;
			
			if (subX < 7) begin
				subX <= subX + 3'b1;
			end
			else begin
				subX <= 0;
				screenX <= screenX + 7'b1;
			end
		end
		else if (h_pixel < 660) begin
			r_vga_o <= 0;
			r_vga_o <= 0;
			r_vga_o <= 0;
			h_pixel <= h_pixel + 10'b1;
			screenX <= 100;
		end
		else if (h_pixel < 756) begin		
		
			screenX <= 0;
			subX <= 0;
		
			h_sync_o <= 0;
			h_pixel <= h_pixel + 10'b1; 
		end
		else if (h_pixel < 800) begin
			h_sync_o <= 1;
			h_pixel <= h_pixel + 10'b1;
		end
		else begin
			h_pixel <= 0;
		end
	end
	
	always @(posedge h_sync_o) begin
		if (line < 480) begin
			v_sync_o <= 1;
			line <= line + 9'b1;
			
			if (subY < 15) begin
				subY <= subY + 4'b1;
			end
			else begin
				subY <= 0;
				screenY <= screenY + 5'b1;
			end
		end
		else if (line < 494) begin
			v_sync_o <= 0;
			line <= line + 9'b1;
		end
		else if (line < 525) begin
			v_sync_o <= 1;
			line <= line + 9'b1;
		end
		else begin
			line <= 0;
			screenY <= 0;
			subY <= 0;
		end
	end

	

endmodule //text_mode

module seven_seg (
		input [3:0] in,
		output [6:0] out
	);
	
	assign out [0] = (in == 4'h0 || in == 4'h2 || in == 4'h3 || (in >= 4'h5 && in <= 4'hA) || in == 4'hC || in == 4'hE || in == 4'hF) ? 1'b0 : 1'b1;
	assign out [1] = (in <= 4'h4 || (in >= 4'h7 && in <= 4'hA) || in == 4'hD) ? 1'b0 : 1'b1;
	assign out [2] = (in <= 4'h1 || (in >= 4'h3 && in <= 4'hB) || in  == 4'hD) ? 1'b0 : 1'b1;
	assign out [3] = (in == 4'h0 || in == 4'h2 || in == 4'h3 || in == 4'h5 || in == 4'h6 || in == 4'h8 || in == 4'h9 || (in >= 4'hB && in <= 4'hE)) ? 1'b0 : 1'b1;
	assign out [4] = (in == 4'h0 || in == 4'h2 || in == 4'h6 || in == 4'h8 || (in >= 4'hA && in <= 4'hF)) ? 1'b0 : 1'b1;
	assign out [5] = (in == 4'h0 || (in >= 4'h4 && in <= 4'h6) || (in >= 4'h8 && in <= 4'hC) || in >= 4'hE) ? 1'b0 : 1'b1;
	assign out [6] = ((in >= 4'h2 && in <= 4'h6) || (in >= 4'h8 && in <= 4'hB) || in >= 4'hD) ? 1'b0 : 1'b1;
	
endmodule //seven_seg