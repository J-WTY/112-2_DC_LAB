`timescale 1ns / 1ps

module note_gen(
    clk,
    rst,
    amplitude,
    note_div,
    audio_left,
    audio_right
    );
    input clk;
    input rst;
    input [15:0] amplitude;
    input [21:0] note_div;
    output [15:0] audio_left, audio_right;
    reg [21:0] cnt, cnt_next;
    reg b, b_next;
      
always@*
    if (cnt == note_div) begin
        cnt_next = 22'b0;
        b_next = ~b;
    end
    else begin
        cnt_next = cnt + 1'b1;
        b_next = b;
    end

always@(posedge clk or posedge rst)
    if (rst)    b <= 1'b0;
    else        b <= b_next;
    
always@(posedge clk or posedge rst)
    if (rst)    cnt <= 22'b0;
    else        cnt <= cnt_next;

assign audio_left = (b == 1'b0) ? amplitude : ~amplitude + 1'b1;
assign audio_right = (b == 1'b0) ? amplitude : ~amplitude + 1'b1;
endmodule
