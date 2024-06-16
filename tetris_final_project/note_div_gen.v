`include "global.v"
module note_div_gen (
    input clk,
    input rst,
    input [4:0] combo,
    output [21:0] note_div
);
reg [21:0] note_div_tmp;
reg [30:0] cnt, cnt_next;
reg [4:0] combo_delay;
wire clk_1HZ;

always@*
    if      (combo == 5'd1)  note_div_tmp = 22'd191571;
    else if (combo == 5'd2)  note_div_tmp = 22'd170648;
    else if (combo == 5'd3)  note_div_tmp = 22'd151515;
    else if (combo == 5'd4)  note_div_tmp = 22'd143266;
    else if (combo == 5'd5)  note_div_tmp = 22'd127551;
    else if (combo == 5'd6)  note_div_tmp = 22'd113636;
    else if (combo == 5'd7)  note_div_tmp = 22'd101215;
    else if (combo == 5'd8)  note_div_tmp = 22'd95420;
    else if (combo == 5'd9)  note_div_tmp = 22'd85034;
    else if (combo == 5'd10) note_div_tmp = 22'd75757;
    else if (combo == 5'd11) note_div_tmp = 22'd71633;
    else if (combo == 5'd12) note_div_tmp = 22'd63776;
    else if (combo == 5'd13) note_div_tmp = 22'd56818;
    else if (combo == 5'd14) note_div_tmp = 22'd50607;
    else if (combo == 5'd15) note_div_tmp = 22'd47778;
    else if (combo == 5'd16) note_div_tmp = 22'd45097;
    else                     note_div_tmp = 22'd0;

always@(posedge clk)
if (rst) combo_delay <= 0;
else     combo_delay <= combo;

always@*
if (rst) cnt_next = 0;
else if ((combo - combo_delay) == 1)  cnt_next = 1;
else if (cnt == 100000000)          cnt_next = 0;
else if (cnt)                       cnt_next = cnt + 1;
else                                cnt_next = 0;

always@(posedge clk or posedge rst)
if (rst)    cnt <= 0;
else        cnt <= cnt_next;

assign note_div = (cnt) ? note_div_tmp : 0;


endmodule
