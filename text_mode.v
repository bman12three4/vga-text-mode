module text_mode (
		input clk,
		
		output reg [3:0] r_vga_o,
		output reg [3:0] g_vga_o,
		output reg [3:0] b_vga_o,
		
		output reg v_sync_o,
		output reg h_sync_o
		
	);
	
	(* keep *) wire vga_clk;
	
	wire [11:0] screen_address /*synthesis keep */;

	
	reg wren_m;
	
	reg [6:0] screenX/*synthesis noprune */; //These are the 80x25 subacters
	reg [4:0] screenY/*synthesis noprune */;
	
	reg [2:0] subX;	 //These are the 9x16 pixel subacters
	reg [3:0] subY;
	
	reg [9:0] h_pixel;
	reg [9:0] line;
	
	(* keep *) wire [7:0] chr_val;
	
	reg [7:0] user_char;
	
	(* keep *) wire pixel;
	
	assign screen_address [6:0] = screenX;
	assign screen_address [11:7] = screenY;

	

	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b (
		.address (screen_address),
		.clock (clk),
		.data (user_char),
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
			screenY <= 0;
			line <= 0;
			subY <= 0;
		end
	end

	

endmodule //text_mode