`include "global.v"

module KeyDecoder (
    input clk, rst,
    input [511:0] key_down,
    input [1:0] state,
    output space,
    output left, right, down, spin
);

wire left_tmp, right_tmp, down_tmp, spin_tmp, space_tmp;
wire clk_4HZ, clk_16HZ;

clock_16HZ K16 (.clk(clk), .rst(rst), .clk_out(clk_16HZ));

one_pulse SPI (.clk(clk), .rst(rst), .pb_in(key_down[`KEY_ROT]),   .out_pulse(spin_tmp));
one_pulse SPA (.clk(clk), .rst(rst), .pb_in(key_down[`KEY_SPACE]), .out_pulse(space_tmp));
one_pulse LEF (.clk(clk), .rst(rst), .pb_in(key_down[`KEY_LEFT]),  .out_pulse(left_tmp));
one_pulse RIG (.clk(clk), .rst(rst), .pb_in(key_down[`KEY_RIGHT]), .out_pulse(right_tmp));
one_pulse DOW (.clk(clk), .rst(rst), .pb_in(down_tmp),  .out_pulse(down));

assign left = (state == `DRO) ? left_tmp : 0;
assign right = (state == `DRO) ? right_tmp : 0;
assign down_tmp = (state == `DRO) & clk_16HZ & key_down[`KEY_DOWN];
assign spin = (state == `DRO) ? spin_tmp : 0;
assign space = (state == `DRO) ? space_tmp : 0;

endmodule    