module text_mode (
		input clk,
		
		(*keep*) output [3:0] r_vga_o /*synthesis keep */,
		(*keep*) output [3:0] g_vga_o /*synthesis keep */,
		(*keep*) output [3:0] b_vga_o /*synthesis keep */,
		
		output reg v_sync_o,
		output reg h_sync_o
		
	);
	
	(* keep *) wire vga_clk;
	
	wire [11:0] screen_address /*synthesis keep */;

	
	reg wren_ms;
	reg wren_mc;
	
	reg [6:0] screenX/*synthesis noprune */; //These are the 80x25 subacters
	reg [4:0] screenY/*synthesis noprune */;
	
	reg [2:0] subX;	 //These are the 9x16 pixel subacters
	reg [3:0] subY;
	
	reg [9:0] h_pixel;
	reg [9:0] line;
	
	wire [7:0] chr_val;
	wire [7:0] colr_val;
	
	wire [3:0] r_pixel;
	wire [3:0] g_pixel;
	wire [3:0] b_pixel;
	
	assign r_pixel [3:2] = colr_val [7:6];
	assign g_pixel [3:2] = colr_val [5:4];
	assign b_pixel [3:2] = colr_val [3:2];
	
	reg [7:0] user_char;
	reg [7:0] user_colr;
	
	(* keep *) wire pixel;
	
	assign screen_address [6:0] = screenX;
	assign screen_address [11:7] = screenY;
	
	assign r_vga_o = (pixel & (h_pixel < 640)) ? r_pixel : 4'b0;
	assign g_vga_o = (pixel & (h_pixel < 640)) ? g_pixel : 4'b0;
	assign b_vga_o = (pixel & (h_pixel < 640)) ? b_pixel : 4'b0;
	
	//assign r_vga_o [0] = (pixel & (h_pixel < 640)), r_vga_o [1] = (pixel & (h_pixel < 640)), r_vga_o [2] = (pixel & (h_pixel < 640)), r_vga_o [3] = (pixel & (h_pixel < 640));
	//assign g_vga_o [0] = (pixel & (h_pixel < 640)), g_vga_o [1] = (pixel & (h_pixel < 640)), g_vga_o [2] = (pixel & (h_pixel < 640)), g_vga_o [3] = (pixel & (h_pixel < 640));
	//assign b_vga_o [0] = (pixel & (h_pixel < 640)), b_vga_o [1] = (pixel & (h_pixel < 640)), b_vga_o [2] = (pixel & (h_pixel < 640)), b_vga_o [3] = (pixel & (h_pixel < 640));

	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b (
		.address (screen_address),
		.clock (clk),
		.data (user_char),
		.wren (wren_ms),
		.q (chr_val)
	);
	
	color_ram c (
		.address (screen_address),
		.clock (clk),
		.data (user_colr),
		.wren (wren_mc),
		.q (colr_val)
	);
	
	chr_rom_ctrl d (
		.clk (clk),
		.chr_val (chr_val),
		.col (subX),
		.row (subY),
		.pixel (pixel)
	);
	
	always @(posedge vga_clk) begin

		if (h_pixel < 639) begin
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