module text (
	input clk, rst,
	output reg[9:0]  rom_adr,
	input wire[31:0] rom_data,
	input wire[9:0] posx, posy,
	input wire[9:0] x, y,
	input wire[3:0] char,
	output reg data
);

`include "para_define.v"

reg[9:0]	rom_adress;
reg[4:0] x_cnt;

// decode char to rom address
always @(posedge clk)
	case(char)
		4'd0: rom_adress <= `CHAR_0;
		4'd1: rom_adress <= `CHAR_1;
		4'd2: rom_adress <= `CHAR_2;
		4'd3: rom_adress <= `CHAR_3;
		4'd4: rom_adress <= `CHAR_4;
		4'd5: rom_adress <= `CHAR_5;
		4'd6: rom_adress <= `CHAR_6;
		4'd7: rom_adress <= `CHAR_7;
		4'd8: rom_adress <= `CHAR_8;
		4'd9: rom_adress <= `CHAR_9;
		default: rom_adress <= `CHAR_a;
	endcase
	
always @(posedge clk)
	if(x >= posx && x < posx + `CHAR_WIDETH) begin
		x_cnt <= x_cnt - 1'b1;
		data <= rom_data[x_cnt];
	end
	else
		x_cnt <= `CHAR_WIDETH-1;

always @(posedge clk )
	if(y >= posy && y < posy + `CHAR_HEIGHT) begin
		rom_adr <= rom_adress + (y-posy);
	end
	else
		rom_adr <= `CHAR_a;
		
endmodule
