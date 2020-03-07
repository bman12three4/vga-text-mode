module text_mode (
		input clk,
		input clk_ext1,	// External 1 MHz clock

		input cs,			// Chip Select (Active Low)
		input [3:0] rs,	// Register select
		input wren,			// Write enable (Active low)
		input [7:0] data_in,	// Data bus

		
		(*keep*) output [3:0] r_vga_o /*synthesis keep */,
		(*keep*) output [3:0] g_vga_o /*synthesis keep */,
		(*keep*) output [3:0] b_vga_o /*synthesis keep */,
		
		output reg v_sync_o,
		output reg h_sync_o
		
	);
	
	(* keep *) wire vga_clk;
	
	wire [7:0] screen_address /*synthesis keep */;

	
	reg [6:0] screenX/*synthesis noprune */; //These are the 80x25 subacters
	reg [4:0] screenY/*synthesis noprune */;
	
	reg [2:0] subX;	 //These are the 9x16 pixel subacters
	reg [3:0] subY;
	
	reg [9:0] h_pixel;
	reg [9:0] line;
	
	(* keep *) wire [7:0] chr_val;
	
	reg [7:0] user_char;
	
	wire chipclk;
	
	assign chipclk = clk_ext1 & ~cs;
	
	reg [7:0] int_reg [3:0]; // 16 8 bit registers
	
	reg [3:0] curr_addr;		// Current address
	
	wire [7:0] ram_out;
	
	wire ram_wren;
	
	assign ram_wren = (curr_addr == 4'b1) ? 1'b1 : 1'b0;

	
	(* keep *) wire pixel;
	
	assign screen_address [6:0] = screenX;
	assign screen_address [7] = screenY;
	
	assign r_vga_o [0] = (pixel & (h_pixel < 640)), r_vga_o [1] = (pixel & (h_pixel < 640)), r_vga_o [2] = (pixel & (h_pixel < 640)), r_vga_o [3] = (pixel & (h_pixel < 640));
	assign g_vga_o [0] = (pixel & (h_pixel < 640)), g_vga_o [1] = (pixel & (h_pixel < 640)), g_vga_o [2] = (pixel & (h_pixel < 640)), g_vga_o [3] = (pixel & (h_pixel < 640));
	assign b_vga_o [0] = (pixel & (h_pixel < 640)), b_vga_o [1] = (pixel & (h_pixel < 640)), b_vga_o [2] = (pixel & (h_pixel < 640)), b_vga_o [3] = (pixel & (h_pixel < 640));

	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b  (
		.rdaddress (screen_address),
		.wraddress (int_reg[0]),
		.clock (clk),
		.data (int_reg[1]),
		.wren (ram_wren),
		.q (chr_val)
	);
	
	chr_rom_ctrl c (
		.clk (clk),
		.chr_val (chr_val),
		.col (subX),
		.row (subY),
		.pixel (pixel)
	);
	
	always @ (posedge chipclk) begin
			curr_addr = rs;
	end
	
	always @ (negedge chipclk) begin		// Main code should run here, after data has been recieved
			int_reg[curr_addr] = data_in;
	end
	
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