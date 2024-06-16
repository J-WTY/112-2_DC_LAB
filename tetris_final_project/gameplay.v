`include "global.v"

module gameplay(
    input clk, rst, clk_25MHz,
    input left, right, down, spin, space,
    input start,
    input [199:0] occupied,
    input del_to_dro,
    input [1:0] state,
    input [9:0] addr_copy_tmp,
    input [3:0] level,
    output [4:0] y1, y2, y3, y4,
    output [2:0] tetris,
    output touch,
    output reg game_over,
    output wire [2:0] get,
    output [7:0] blk0, blk1, blk2, blk3,
    output enable
);


// generate random tetris at the moment del to drop**********************************
randomizer G1 (.clk(clk), .seed(8'b10101010), .del_to_dro(del_to_dro), .tetris(tetris));
//*************************************************************************


// drop clock, high for every 1 second*********************************************
wire drop;
drop_clock_1HZ CLK (.clk(clk), .del_to_dro(del_to_dro), .drop(drop), .state(state), .level(level));
//*************************************************************************


// move control**************************************************************
move_control G2 (.clk(clk), .clk_25MHz(clk_25MHz), .rst(rst), .left(left), .right(right), .down(down), .enable(enable),
                 .del_to_dro(del_to_dro), .spin(spin), .blk0(blk0), .blk1(blk1), .blk2(blk2), .blk3(blk3),
                 .drop(drop), .touch(touch), .tetris(tetris), .occupied(occupied), .state(state), .space(space));
//*************************************************************************


// game over****************************************************************
reg game_over_tmp;
always@*
    if (state == `PRE || state == `END) game_over_tmp = 0;
    else if (occupied[4] || occupied[5] || occupied[6] || occupied[7] || occupied[8])
        game_over_tmp = 1;
    else
        game_over_tmp = 0;
    
always@(posedge clk)
    if (rst)    game_over = 0;
    else        game_over = game_over_tmp;    
//************************************************************************* 

// rows to be eliminate*****************************************************************************************************
wire [4:0] line1, line2, line3, line4;
assign line1 = (blk0 / 10);
assign line2 = (blk1 / 10);
assign line3 = (blk2 / 10);
assign line4 = (blk3 / 10);

assign y1 = (state == `DEL && occupied[(line1 * 10) +: 10] == 10'b1111111111) ? line1 : 30;
assign y2 = (state == `DEL && occupied[(line2 * 10) +: 10] == 10'b1111111111) ? line2 : 30;
assign y3 = (state == `DEL && occupied[(line3 * 10) +: 10] == 10'b1111111111) ? line3 : 30;
assign y4 = (state == `DEL && occupied[(line4 * 10) +: 10] == 10'b1111111111) ? line4 : 30;

//***************************************************************************************************************************
reg [32:0] line_clear, line_clear_tmp;
always@*
    if (rst || state == `PRE)                     line_clear_tmp = 0;
    else if (addr_copy_tmp == 25)                 line_clear_tmp = (1 << y1) | (1 << y2) | (1 << y3) | (1 << y4);
    else if (state == `DEL && addr_copy_tmp > 25) line_clear_tmp = line_clear;
    else                                          line_clear_tmp = 0;
always@(posedge clk_25MHz)
    line_clear <= line_clear_tmp;
    
assign get = line_clear[0] + line_clear[1] + line_clear[2] + line_clear[3] + line_clear[4] + line_clear[5] + line_clear[6] + line_clear[7] + line_clear[8] + line_clear[9] + line_clear[10] + line_clear[11] + line_clear[12] + line_clear[13] + line_clear[14] + line_clear[15] + line_clear[16] + line_clear[17] + line_clear[18] + line_clear[19];        
    

endmodule