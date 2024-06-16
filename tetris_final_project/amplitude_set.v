`timescale 1ns / 1ps
module amplitude_set(
    input clk,
    input clk_100HZ,
    input rst,
    input pb_inc,
    input pb_dec,
    output reg [15:0] amplitude
    );
    reg [3:0] volume_next, volume;
    wire deb_in, deb_de;
    wire increase, decrease;
    reg [3:0] increase_tmp, decrease_tmp;
    
debounce UIN  (.clk(clk_100HZ), .rst(rst), .pb_in(pb_inc), .pb_debounced(deb_in));
debounce UDE  (.clk(clk_100HZ), .rst(rst), .pb_in(pb_dec), .pb_debounced(deb_de));
one_pulse OIN (.clk(clk), .rst(rst), .pb_in(deb_in), .out_pulse(increase));
one_pulse ODE (.clk(clk), .rst(rst), .pb_in(deb_de), .out_pulse(decrease));

always@*
    if (volume == 4'd15)    increase_tmp = volume;
    else                    increase_tmp = volume + 1'b1;

always@*
    if (volume == 4'd0)     decrease_tmp = volume;
    else                    decrease_tmp = volume - 1'b1; 

always@*
    if (increase)       volume_next = increase_tmp;
    else if (decrease)  volume_next = decrease_tmp;
    else                volume_next = volume;

always@(negedge clk or posedge rst)
    if (rst)   volume <= 4'b1000;
    else        volume <= volume_next;

always@*    
case(volume)
    4'b0000: amplitude = 16'h0000;
    4'b0001: amplitude = 16'h08FF;
    4'b0010: amplitude = 16'h0FFF;
    4'b0011: amplitude = 16'h16FF;
    4'b0100: amplitude = 16'h1CFF;
    4'b0101: amplitude = 16'h23FF;
    4'b0110: amplitude = 16'h2AFF;
    4'b0111: amplitude = 16'h30FF;
    4'b1000: amplitude = 16'h39FF;
    4'b1001: amplitude = 16'h3FFF;
    4'b1010: amplitude = 16'h45FF;
    4'b1011: amplitude = 16'h4DFF;
    4'b1100: amplitude = 16'h53FF;
    4'b1101: amplitude = 16'h5AFF;
    4'b1110: amplitude = 16'h5CFF;
    4'b1111: amplitude = 16'h5FFF;
    default: amplitude = 1'b0;
endcase          
endmodule
