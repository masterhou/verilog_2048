module block #(parameter N=4, size=160)
(
	input clk, rst,
	output wire[9:0] rom_address,
	input wire[31:0] rom_data,
	input wire[9:0] posx, posy,
	input wire[9:0] x, y,
	input wire[13:0] number,
	output wire data
);
`include "para_define.v"

//wire[2:0] length = char4==0?(char3==0?(char2==0?1:2):3):4;

wire[3:0] i;
wire[9:0] poxx, xx, yy;
wire[3:0] char;

assign xx = (x-posx);
assign yy = (y-posy);

assign i = xx[9:5];

assign char = 2;
assign poxx = posx - (`CHAR_WIDETH+1)*i;
text text(clk, rst, rom_address, rom_data, poxx, posy, xx, yy, char, data);

endmodule
