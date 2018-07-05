module game2048(
	input wire clk, rst,
	
	// gamepad 
	input wire[3:0] row,
	output wire[3:0] col,
	
	// vga display
	output reg[3:0] vga_r, vga_g, vga_b,
	output wire hsync, vsync,
	
	// led score display
	output wire[7:0] LEDOut,
	output wire[2:0] DigitSelect,
	output wire[7:0] Light
);

localparam Key_Left=4'h1, Key_Right=4'h3, Key_Up=4'h6, Key_Down=4'h2;
localparam game_init=1, game_rand=2, game_keydwon=3, game_keyup=4, game_cal=5, game_move=6, game_over=3'd7;

reg[1:0] line, dir;
reg[13:0] grid[15:0];
wire[15:0] grid_color;
reg[15:0]  score;

wire[3:0] code;
wire keydown, scan_clk;
keypad4x4 key(clk, rst, row, col, code, keydown, scan_clk);

wire[3:0] LED[7:0];
led8 led(scan_clk, rst, LED[0], LED[1], LED[2], LED[3], LED[4], LED[5], LED[6], LED[7], LEDOut, DigitSelect);

///////////////////////////////////

wire[7:0] randq;
LFSR8_11D LFSR8_11D(clk, rst, randq);

///////////////////////////////////
assign LED[0] = a;
assign LED[1] = b;
assign LED[2] = c;
assign LED[3] = d;
assign LED[4] = e;
assign LED[5] = f;
assign LED[6] = g;
assign LED[7] = m;

reg[3:0] game_state;
reg[4:0]	grid_cnt;
reg	m; // need move 2 times: 1st m=0; 2nd m=1;
reg	q; // any tile moved, will set 1(true)
// game state machine
always @(posedge clk or negedge rst)
	if(!rst) begin
		grid_cnt <= 4'd0;
		game_state <= game_init;
	end
	else if(game_state == game_init) begin
		if(grid_cnt<=4'd15) begin
			grid[grid_cnt] <= 4'd0;
			grid_cnt <= grid_cnt + 1'b1;
		end
		else begin 
			grid[randq[4:1]] <= 4'd2;
			grid_cnt <= 4'd0;
			game_state <= game_rand;
		end
	end
	else if(game_state == game_rand) begin
		if(grid[randq[3:0]]==0) begin
			grid[randq[3:0]] <= 4'd2;
			game_state <= game_keydwon;
		end
	end
	else if(game_state == game_keydwon) begin
		if(keydown && (code==Key_Down||code==Key_Left||code==Key_Right||code==Key_Up)) begin
			game_state <= game_keyup;
		end
	end
	else if(game_state == game_keyup) begin
		if(!keydown) begin
			q <= 0;
			g <= 0;
			m <= 0; // first move
			game_state <= game_move;
		end
	end
	else if(game_state == game_cal) begin
		if(g<4) begin
			if(f<3) begin
				if(grid[o1]==grid[o2]) begin
					grid[o1] <= grid[o1]+grid[o1];
					grid[o2] <= 0;
					if(grid[o2]!=0) q <= 1;
					f <= f+2'd2;
				end
				else begin
					f <= f+2'd1;
				end
			end
			else begin
				f <= 0;
				g <= g+1'd1;
			end
		end
		else begin
			g <= 0;
			game_state <= game_move; // second move
		end
	end
	else if(game_state == game_move) begin
		if(g<4) begin
			if(h<2) begin // bad method
				if(f<3) begin
					if(grid[o1]==0) begin
						grid[o1] <= grid[o2];
						grid[o2] <= 0;
						if(grid[o2]!=0) q <=1;
					end
					f <= f+2'd1;
				end
				else begin
					f <= 0;
					h <= h+2'd1;
				end
			end
			else begin
				h <= 0;
				g <= g+1'd1;
			end
		end
		else begin
			if(m == 1) begin
				if(q == 1)
					game_state <= game_rand; // new loop
				else
					game_state <= game_keydwon; // no move and cal
			end
			else begin
				m <= 1;
				g <= 0;
				game_state <= game_cal;
			end
		end
	end
	else if(game_state == game_over)
		;

reg[3:0]	a,b,c,d,e; // matrix for index a tile
reg[2:0]	f,g,h; // loop index 
wire[3:0] o1, o2; // cal index
assign o1 = a*(b+f*e  )+c*(d+g);
assign o2 = a*(b+f*e+e)+c*(d+g);

// keyboard
always @(posedge keydown or negedge rst)
	if(!rst)
		{a,b,c,d,e} <= {4'd0,4'd0,4'd0,4'd0,4'd0};
	else
	if(keydown)
		case(code)
		Key_Right:	{a,b,c,d,e} <= {-4'd1,4'd1,4'd4,4'd1, 4'd1};
		Key_Left:	{a,b,c,d,e} <= {-4'd1,4'd4,4'd4,4'd1,-4'd1};
		Key_Up:		{a,b,c,d,e} <= { 4'd4,4'd0,4'd1,4'd0, 4'd1};
		Key_Down:	{a,b,c,d,e} <= { 4'd4,4'd3,4'd1,4'd0,-4'd1};
		default: 	{a,b,c,d,e} <= { 4'd0,4'd0,4'd0,4'd0, 4'd0};
		endcase
		

// bmp from rom
wire[9:0]	rom_address;
wire[31:0] rom_q;
chrom chrom(
  .clock(clk), // input clk
  .address(rom_address), // input [9:0] address from 0-703
  .q(rom_q) // output [31:0] dout
  );

wire[9:0] posx, posy;
wire[13:0] grid_b;

wire[3:0] i,j, gi;
wire grid_c;

block block(clk, rst, rom_address, rom_q, posx, posy, x, y, grid_b, grid_c);

assign i = y[9:6];
assign j = x[9:6];
assign posx = (j+1)*160;
assign posy = i*160+35;
assign gi = i*4+j;
assign grid_b = grid[gi];


localparam 	None_Color = {4'd15, 4'd15, 4'd15}, 
				Body_Color = {4'd09, 4'd15, 4'd00}, 
				Brick_Color ={4'd05, 4'd05, 4'd07},  
				Apple_Color ={4'd15, 4'd00, 4'd00};	
		
// video
wire valid;
wire[9:0] x, y;
wire[10:0] h_cnt;
wire[9:0] v_cnt;
vga_800_600 video(clk, rst, hsync, vsync, h_cnt, v_cnt, x, y, valid);
reg[11:0] Pixel_Color;
// every block size is 160 pixel 
always @(posedge clk)
	if(valid) begin
		{vga_r[3:0],vga_g[3:0],vga_b[3:0]} <= grid_c>0 ? Brick_Color :  12'b0;
	end 
	else {vga_r[3:0],vga_g[3:0],vga_b[3:0]} <= 12'b0;

endmodule
