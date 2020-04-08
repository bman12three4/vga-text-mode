module text_mode (
		input clk,
		input clk_ext1,	// External 1 MHz clock

		input cs,			// Chip Select (Active Low)
		input [3:0] rs,	// Register select
		input wren,			// Write enable (Active low)
		inout [7:0] data_bi,	// Data bus

		
		(*keep*) output [3:0] r_vga_o /*synthesis keep */,
		(*keep*) output [3:0] g_vga_o /*synthesis keep */,
		(*keep*) output [3:0] b_vga_o /*synthesis keep */,
		
		output reg v_sync_o,
		output reg h_sync_o
		
	);
	
	wire vga_clk;
	
	wire fclock;
	
	wire [11:0] screen_r_address /*synthesis keep */;
	wire [11:0] screen_w_address;
	
	reg [6:0] screenX/*synthesis noprune */; //These are the 80x25 subacters
	reg [4:0] screenY/*synthesis noprune */;
	
	reg [2:0] subX;	 //These are the 8x16 pixel subacters
	reg [3:0] subY;
	
	reg [9:0] h_pixel;
	reg [9:0] line;
	
	wire [7:0] chr_val;
	wire [7:0] colr_val;
	
	reg [7:0] user_char;
	reg [7:0] user_colr;
	
	wire chipclk;
	assign chipclk = clk_ext1 & ~cs;
	
	wire [7:0] data_in;
	wire [7:0] data_out;
	
	assign data_bi = (wren & chipclk) ? data_out : 8'bZ;
	assign data_in = data_bi;

	reg [7:0] int_reg [15:0]; // 16 8 bit registers
	reg [3:0] curr_addr;		// Current address
	
	wire wren_ms;
	assign wren_ms = (curr_addr == 4'b1) ? ~wren : 1'b0;
	
	wire wren_mc;
	assign wren_mc = (curr_addr == 4'd2) ? ~wren : 1'b0;
	
	assign data_out = (curr_addr == 4'b1) ? chr_val : int_reg[curr_addr];
	
	wire pixel;
	
	assign screen_r_address [6:0] = screenX;
	assign screen_r_address [11:7] = screenY;
	
	assign screen_w_address [6:0] = int_reg[3][6:0];
	assign screen_w_address [11:7] = int_reg[4][4:0];
	
	wire [3:0] r_pixel;
	wire [3:0] g_pixel;
	wire [3:0] b_pixel;
	
	assign r_vga_o = (h_pixel < 640) ? r_pixel : 4'b0000;
	assign g_vga_o = (h_pixel < 640) ? g_pixel : 4'b0000;
	assign b_vga_o = (h_pixel < 640) ? b_pixel : 4'b0000;

	
	fclock z (
		.inclk0 (clk),
		.c0 (fclock)
	);

	
	vga_clk a (
		.inclk0 (clk),
		.c0 (vga_clk)
	);
	
	screen_ram b  (
		.rdaddress (screen_r_address),
		.wraddress (screen_w_address),
		.clock (fclock),
		.data (int_reg[1]),
		.wren (wren_ms),
		.q (chr_val)
	);
	
	color_ram c (
		.rdaddress (screen_r_address),
		.wraddress (screen_w_address),
		.clock (fclock),
		.data (int_reg[2]),
		.wren (wren_mc),
		.q (colr_val)
	);
	
	chr_rom_ctrl d (
		.clk (fclock),
		.chr_val (chr_val),
		.col (subX),
		.row (subY),
		.pixel (pixel)
	);
	
	color_pixel e (
		.pixel (pixel),
		.colr_val (colr_val),
		.red_o (r_pixel),
		.green_o (g_pixel),
		.blue_o (b_pixel)
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