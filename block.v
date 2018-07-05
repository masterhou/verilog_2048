module block #(parameter N=4)
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

wire[3:0] i, ch;
wire[9:0] poxx, xx;
reg[3:0] char[4];

assign xx = (x-posx);
assign i = xx[9:5]<N ? xx[9:5] : 0;
assign ch = char[i];
assign poxx = posx + `CHAR_WIDETH*i;
text text(clk, rst, rom_address, rom_data, poxx, posy, x, y, ch, data);

always @(posedge clk)
	case(number)
		0:		{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'ha,4'h0};
		2:		{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'ha,4'h2};
		4:		{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'ha,4'h4};
		8:		{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'ha,4'h8};
		16:	{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'h1,4'h6};
		32:	{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'h3,4'h2};
		64:	{char[0],char[1],char[2],char[3]}<={4'ha,4'ha,4'h6,4'h4};
		128:	{char[0],char[1],char[2],char[3]}<={4'ha,4'h1,4'h2,4'h8};
		256:	{char[0],char[1],char[2],char[3]}<={4'ha,4'h2,4'h5,4'h6};
		512:	{char[0],char[1],char[2],char[3]}<={4'ha,4'h5,4'h1,4'h2};
		1024:	{char[0],char[1],char[2],char[3]}<={4'h1,4'h0,4'h2,4'h4};
		2048:	{char[0],char[1],char[2],char[3]}<={4'h2,4'h0,4'h4,4'h8};
		4096:	{char[0],char[1],char[2],char[3]}<={4'h4,4'h0,4'h9,4'h6};
		8192:	{char[0],char[1],char[2],char[3]}<={4'h8,4'h1,4'h9,4'h2};
		default: ;
	endcase

endmodule