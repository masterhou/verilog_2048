module block #(parameter posx=0, posy=0, N=4, size=160)
(
	input clk, rst,
	output wire[9:0] rom_address,
	input wire[31:0] rom_data,
	input wire[9:0] x, y,
	input wire[15:0] number,
	output wire q,
	output wire qqq
);
`include "para_define.v"

//wire[2:0] length = char4==0?(char3==0?(char2==0?1:2):3):4;

wire[9:0] poxx[N-1:0];
wire[3:0] char[N-1:0]; 
wire[9:0] rom_adr[N-1:0];

assign rom_address = rom_adr[cnt];

assign qqq = (x >= posx-size+`CHAR_WIDETH && x < posx+`CHAR_WIDETH) && (y >= posy && y < posy + `CHAR_HEIGHT);

wire[N-1:0] qq;
wire[N-1:0] data;
assign q = data>0;

genvar i;
generate
	for(i=0; i<N; i=i+1)
	begin : B
		assign char[i] = number/(4'd10**i)% 4'd10;
		assign poxx[i] = posx - (`CHAR_WIDETH+1)*i;
		text text(clk, rst, rom_adr[i], rom_data, poxx[i], posy, x, y, char[i], data[i], qq[i]);
	end
	
endgenerate

reg[N-1:0] cnt;
always @(x) begin
	case(qq)
		8'b0000001: cnt <= 3'd0; 
		8'b0000010: cnt <= 3'd1; 
		8'b0000100: cnt <= 3'd2; 
		8'b0001000: cnt <= 3'd3; 
//		8'b0010000: cnt <= 4; 
//		8'b0100000: cnt <= 5; 
//		8'b1000000: cnt <= 6;
	endcase
end

endmodule
