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
keypad4x4 u_key(clk, rst, row, col, code, keydown, scan_clk);

wire[3:0] LED[7:0];
led8 led(scan_clk, rst, LED[0], LED[1], LED[2], LED[3], LED[4], LED[5], LED[6], LED[7], LEDOut, DigitSelect);

///////////////////////////////////

wire[7:0] randq;
LFSR8_11D LFSR8_11D(clk, rst, randq);

///////////////////////////////////
//assign LED[0] = a;
//assign LED[1] = b;
//assign LED[2] = c;
//assign LED[3] = d;
//assign LED[4] = e;
//assign LED[5] = f;
//assign LED[6] = g;
//assign LED[7] = m;

assign LED[0] = score[15:12];
assign LED[1] = score[11:8];
assign LED[2] = score[ 7:4];
assign LED[3] = score[ 3:0];

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
			score <= 16'd0;
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
				if(grid[o1]==grid[o2] & grid[o1]!=0) begin
					grid[o1] <= grid[o1]*2;
					grid[o2] <= 0;
					score <= score + grid[o1]*2;
					q <= 1;
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

reg[2:0]	f,g,h; // loop index 
wire[3:0] o1, o2; // cal index

wire[3:0] down1 = 12-4*f+g;
wire[3:0] down2 = 08-4*f+g;

wire[3:0] up1 = 0+4*f+g;
wire[3:0] up2 = 4+4*f+g;

wire[3:0] left1 = 0+4*g+f;
wire[3:0] left2 = 1+4*g+f;

wire[3:0] righ1 = 3+4*g-f;
wire[3:0] righ2 = 2+4*g-f;

reg[2:0]	key;
// keyboard
assign o1 = 
			key==0 ? righ1 :
			key==1 ? left1 :
			key==2 ? up1   :
			key==3 ? down1 : 0;

assign o2 = 
			key==0 ? righ2 :
			key==1 ? left2 :
			key==2 ? up2   :
			key==3 ? down2 : 0;
			
always @(posedge keydown or negedge rst)
	if(!rst)
		key <= 4;
	else
	if(keydown)
		case(code)
		Key_Right:	key <= 0;
		Key_Left:	key <= 1;
		Key_Up:		key <= 2;
		Key_Down:	key <= 3;
		default: 	key <= 4;
		endcase
		

// bmp from rom
wire[9:0]	rom_address;
wire[31:0] rom_q;
chrom chrom(
  .clock(clk), // input clk
  .address(rom_address), // input [9:0] address from 0-703
  .q(rom_q) // output [31:0] dout
  );

wire data;
wire[3:0] i, ii, j, jj;
wire[13:0] number;
wire[9:0] posx, posy;

assign ii = x/160;
assign jj = y/160;
assign i = ii<4 ? ii : 0;
assign j = jj<4 ? jj : 0;
assign posx = 160*i + 32;
assign posy = 160*j + 32;
assign number = grid[j*4+i];

block block(clk, rst, rom_address, rom_q, posx, posy, x, y, number, data);

localparam 	Color = {4'd15, 4'd15, 4'd15};
		
// video
wire valid;
wire[9:0] x, y;
wire[10:0] h_cnt;
wire[9:0] v_cnt;
vga_800_600 video(clk, rst, hsync, vsync, h_cnt, v_cnt, x, y, valid);
reg[11:0] Pixel_Color;

always @(posedge clk)
	if(valid) begin
		{vga_r[3:0],vga_g[3:0],vga_b[3:0]} <= data>0 ? Color :  12'b0;
	end 
	else {vga_r[3:0],vga_g[3:0],vga_b[3:0]} <= 12'b0;

endmodule
