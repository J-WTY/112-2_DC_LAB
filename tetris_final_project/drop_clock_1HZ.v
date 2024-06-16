`include "global.v"

`timescale 1ns / 1ps
module drop_clock_1HZ (
input clk,
input del_to_dro,
input [1:0] state,
input [3:0] level,
output drop
);
 
reg [26:0] qtmp;
reg [26:0] cnt;
wire [26:0] trig;

assign trig = 100000000 - level * 6000000;
assign drop = (cnt == trig) ? 1 : 0;
 
always@*
    if (state != `DRO)    qtmp = 0;
    else if (cnt == trig) qtmp = 27'd0;
    else                  qtmp = cnt + 1'b1;

always@(posedge clk or posedge del_to_dro)
    if (del_to_dro)    cnt <= 0;
    else               cnt <= qtmp;   

endmodule