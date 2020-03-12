module color_pixel (
		input pixel,
		input [7:0] colr_val,
		
		output [3:0] red_o,
		output [3:0] green_o,
		output [3:0] blue_o
	);
	
	wire [3:0] r_fgnd;
	wire [3:0] g_fgnd;
	wire [3:0] b_fgnd;
	
	assign r_fgnd [3] = colr_val [6];
	assign g_fgnd [3] = colr_val [5];
	assign b_fgnd [3] = colr_val [4];
	
	assign r_fgnd [2:0] = (colr_val [7] & r_fgnd [3]) ? 3'b111 : 3'b000;
	assign g_fgnd [2:0] = (colr_val [7] & g_fgnd [3]) ? 3'b111 : 3'b000;
	assign b_fgnd [2:0] = (colr_val [7] & b_fgnd [3]) ? 3'b111 : 3'b000;
	
	wire [3:0] r_bkgnd;
	wire [3:0] g_bkgnd;
	wire [3:0] b_bkgnd;
	
	assign r_bkgnd [3] = colr_val [2];
	assign g_bkgnd [3] = colr_val [1];
	assign b_bkgnd [3] = colr_val [0];
	
	assign r_bkgnd [2:0] = (colr_val [3] & r_bkgnd [3]) ? 3'b111 : 3'b000;
	assign g_bkgnd [2:0] = (colr_val [3] & g_bkgnd [3]) ? 3'b111 : 3'b000;
	assign b_bkgnd [2:0] = (colr_val [3] & b_bkgnd [3]) ? 3'b111 : 3'b000;
	
	assign red_o = pixel ? r_fgnd : r_bkgnd;
	assign green_o = pixel ? g_fgnd : g_bkgnd;
	assign blue_o = pixel ? b_fgnd : b_bkgnd;
	
endmodule 