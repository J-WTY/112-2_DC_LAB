`include "global.v"

module tetris (
    input clk, rst,
    input pb_start,
    input pb_inc, pb_dec,
    inout PS2_DATA,
    inout PS2_CLK,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync,
    output mclk,
    output lrck,
    output sclk,
    output audio_sdin,
    output [7:0] ssd_out,
    output [3:0] ssd_ctl,
    output reg [15:0] level_display
);

wire [1:0] state;
wire del_to_dro_25MHz, del_to_dro_100MHz;

// keyboard information****************************************************************************************************************
wire [511:0] key_down;
KeyboardDecoder U1 ( .key_down(key_down), .last_change(last_change), .key_valid(key_valid), .PS2_DATA(PS2_DATA), .PS2_CLK(PS2_CLK), .rst(rst), .clk(clk));
//*************************************************************************************************************************************


// function decoder***********************************************************************************************************************
wire space, left, right, down, spin;
KeyDecoder U2 (.clk(clk), .rst(rst), .key_down(key_down), .state(state), .space(space), .left(left), .right(right), .down(down), .spin(spin));
//*************************************************************************************************************************************


// start signal****************************************************************************************************************************
wire start;
wire clk_100HZ;
start_gen U3 (.clk(clk), .rst(rst), .pb_start(pb_start), .start(start), .clk_100HZ(clk_100HZ));
//*************************************************************************************************************************************


// finite state machine for the system**********************************************************************************************************
wire game_over, touch;
FSM_cond U4 (.clk(clk), .rst(rst), .start(start), .del_to_dro(del_to_dro_100MHz), .touch(touch), .game_over(game_over), .state(state));
//*************************************************************************************************************************************


// game play, main function*****************************************************************************************************************
wire [7:0] blk0, blk1, blk2, blk3;
wire [4:0] y1, y2, y3, y4;
wire [2:0] tetris;
reg [199:0] occupied = 200'b0;
wire [2:0] get;
reg [9:0]  addr_copy_tmp;
wire clk_25MHz;
reg [3:0] level;
wire enable;
gameplay U5(.clk(clk), .clk_25MHz(clk_25MHz), .rst(rst), .left(left), .right(right), .down(down), .spin(spin), 
            .start(start), .occupied(occupied), .del_to_dro(del_to_dro_100MHz), .state(state), .y1(y1), .y2(y2), 
            .y3(y3), .y4(y4), .touch(touch), .game_over(game_over), .blk0(blk0), .blk1(blk1), .blk2(blk2), .blk3(blk3),
            .get(get), .tetris(tetris), .addr_copy_tmp(addr_copy_tmp), .level(level), .space(space), .enable(enable));
            
wire clk_100HZ_one;
one_pulse U13 (.clk(clk), .rst(rst), .pb_in(clk_100HZ), .out_pulse(clk_100HZ_one));

reg [7:0] gray0, gray1, gray2, gray3, gray0_next, gray1_next, gray2_next, gray3_next;
always@*
if (clk_100HZ_one) begin
    gray0_next = blk0;
    gray1_next = blk1;
    gray2_next = blk2;
    gray3_next = blk3;
end
else if (occupied[gray0 + 4'd10] || occupied[gray1 + 4'd10] || occupied[gray2 + 4'd10] || occupied[gray3 + 4'd10]
        || (gray0 / 10 == 19) || (gray1 / 10 == 19) || (gray2 / 10 == 19) || (gray3 / 10 == 19)) begin
    gray0_next = gray0;
    gray1_next = gray1;
    gray2_next = gray2;
    gray3_next = gray3;
end
else begin
    gray0_next = gray0 + 10;
    gray1_next = gray1 + 10;
    gray2_next = gray2 + 10;
    gray3_next = gray3 + 10;
end

always@(posedge clk or posedge rst)
    if (rst) begin
        gray0 <= 230;
        gray1 <= 230;
        gray2 <= 230;
        gray3 <= 230;
    end else begin
        gray0 <= gray0_next;
        gray1 <= gray1_next;
        gray2 <= gray2_next;
        gray3 <= gray3_next;
    end
//*************************************************************************************************************************************


// clock for vga**************************************************************************************************************************
clock_vga U6 (.clk(clk), .clk1(clk_25MHz));
//*************************************************************************************************************************************


// vga controller**************************************************************************************************************************
wire [9:0] h_cnt, v_cnt;
wire valid;
vga_controller U7 (.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), .valid(valid), .h_cnt(h_cnt), .v_cnt(v_cnt));
//*************************************************************************************************************************************


// main ram and address********************************************************************************************************************
reg [7:0] addr_main, addr_main_del;
wire [7:0] addr_main_dro;
reg [3:0] data_main;
wire [3:0] dout_main;
reg wea_main;
always@*
    if (state == `DEL) addr_main = addr_main_del;
    else               addr_main = addr_main_dro;
    
blk_mem_gen_main U8 (.clka(clk_25MHz), .wea(wea_main), .addra(addr_main), .dina(data_main), .douta(dout_main));
//**************************************************************************************************************************************

//ram copy*******************************************************************************************************************************
reg  [7:0] addr_copy;
reg [9:0] next;
wire [3:0] dout_copy;
reg [3:0] data_copy;
reg wea_copy;
blk_mem_gen_copy U9 (.clka(clk_25MHz), .wea(wea_copy), .addra(addr_copy), .dina(data_copy), .douta(dout_copy));
//**************************************************************************************************************************************


// display of VGA, addr_main_dro*************************************************************************************************************
reg [3:0] rgb;
always@*
if (~valid)                                                                                                            rgb = `NON;
else if (v_cnt <= 64 || v_cnt >= 64+320+16)                                                                            rgb = `NON;      // outside boundary
else if (h_cnt <= 224 || h_cnt >= 224 + 160 + 32)                                                                      rgb = `NON;      // outside boundary
else if ((h_cnt >= 224 && h_cnt <= 224 + 16) || (h_cnt >= 224 + 16 + 160 && h_cnt <= 224 + 16 + 160 + 16))             rgb = `WHITE;    // vertical boundary
else if (v_cnt >= 64 + 320 && v_cnt <= 64 + 320 + 16)                                                                  rgb = `WHITE;    // lower boundary
else if (state == `PRE)                                                                                                rgb = `NON;
else if ((state[1] ^ state[0]) && (addr_main_dro == blk0) || (addr_main_dro == blk1) || (addr_main_dro == blk2) || (addr_main_dro == blk3))     rgb = tetris; // inside
else if ((state[1] ^ state[0]) && (addr_main_dro == gray0) || (addr_main_dro == gray1) || (addr_main_dro == gray2) || (addr_main_dro == gray3)) rgb = `GRAY;

else                                                                                                                   rgb = dout_main;

assign addr_main_dro = (((h_cnt - 224 - 16) >> 4) + 10 * ((v_cnt - 64) >> 4)) % (10 * 20);
//**************************************************************************************************************************************


//addr_main_del*************************************************************************************************************************
reg [7:0] main_next;
always@*
if (addr_main_del == 201)       main_next = 0;
else if (addr_copy_tmp < 202)   main_next = 0;
else                            main_next = addr_main_del + 1;

always@(posedge clk_25MHz)
    if (rst)    addr_main_del <= 0;
    else        addr_main_del <= main_next;
//**************************************************************************************************************************************


//wea_main******************************************************************************************************************************
always@*
if (state == `PRE)                                                               wea_main = 1;
else if (state != `DEL)                                                          wea_main = 0;
else if (addr_copy_tmp >= 200 && addr_copy_tmp <= 399)                           wea_main = 1;
else if (addr_copy_tmp == 400 && (addr_main_del == 198 || addr_main_del == 199)) wea_main = 1;
else                                                                             wea_main = 0;
//**************************************************************************************************************************************

//data_main******************************************************************************************************************************
always@*
if (state == `PRE)                  data_main = 0;
else if (state != `DEL)             data_main = 0;
else if (addr_main_del < get * 10)  data_main = `NON;
else                                data_main = dout_copy;
//**************************************************************************************************************************************


//addr_copy_tmp, addr_copy****************************************************************************************************************
always@*
    if (state == `PRE)              next = addr_copy_tmp + 1;
    else if (state != `DEL)         next = 0;
    else if (addr_copy_tmp == 600)  next = 0;
    else if (addr_copy_tmp == 400)
        if (addr_main_del == 2)     next = addr_copy_tmp + 1;
        else                        next = addr_copy_tmp; 
    else if ((addr_main_del == get * 10 - 1) && get != 0 && addr_copy_tmp >= 200 && addr_copy_tmp < 400) next = addr_main_del + 203 - (get * 10);
    else if (addr_main_del == 199 && addr_copy_tmp < 400)  next = 400;
    else if ((((addr_copy + 1) / 10) == y1 || ((addr_copy + 1) / 10) == y2 || ((addr_copy + 1) / 10) == y3 || ((addr_copy + 1) / 10) == y4) && 
            (((addr_copy + 11) / 10) == y1 || ((addr_copy + 11) / 10) == y2 || ((addr_copy + 11) / 10) == y3 || ((addr_copy + 11) / 10) == y4) &&
            (((addr_copy + 21) / 10) == y1 || ((addr_copy + 21) / 10) == y2 || ((addr_copy + 21) / 10) == y3 || ((addr_copy + 21) / 10) == y4) &&
            (((addr_copy + 31) / 10) == y1 || ((addr_copy + 31) / 10) == y2 || ((addr_copy + 31) / 10) == y3 || ((addr_copy + 31) / 10) == y4) && addr_copy_tmp > 200 && addr_copy_tmp < 401)
        next = addr_copy_tmp + 41;
    else if ((((addr_copy + 1) / 10) == y1 || ((addr_copy + 1) / 10) == y2 || ((addr_copy + 1) / 10) == y3 || ((addr_copy + 1) / 10) == y4) && 
            (((addr_copy + 11) / 10) == y1 || ((addr_copy + 11) / 10) == y2 || ((addr_copy + 11) / 10) == y3 || ((addr_copy + 11) / 10) == y4) &&
            (((addr_copy + 21) / 10) == y1 || ((addr_copy + 21) / 10) == y2 || ((addr_copy + 21) / 10) == y3 || ((addr_copy + 21) / 10) == y4) && addr_copy_tmp > 200 && addr_copy_tmp < 401)
        next = addr_copy_tmp + 31;
    else if ((((addr_copy + 1) / 10) == y1 || ((addr_copy + 1) / 10) == y2 || ((addr_copy + 1) / 10) == y3 || ((addr_copy + 1) / 10) == y4) && 
            (((addr_copy + 11) / 10) == y1 || ((addr_copy + 11) / 10) == y2 || ((addr_copy + 11) / 10) == y3 || ((addr_copy + 11) / 10) == y4) && addr_copy_tmp > 200 && addr_copy_tmp < 401)
        next = addr_copy_tmp + 21;
    else if ((((addr_copy + 1) / 10) == y1 || ((addr_copy + 1) / 10) == y2 || ((addr_copy + 1) / 10) == y3 || ((addr_copy + 1) / 10) == y4) &&  addr_copy_tmp > 200 && addr_copy_tmp < 401)       
        next = addr_copy_tmp + 11;      
    else                           next = addr_copy_tmp + 1;    

always@(posedge clk_25MHz)
    if (rst)                        addr_copy_tmp <= 0;
    else                            addr_copy_tmp <= next;
    
always@*
    if (addr_copy_tmp >= 200 && addr_copy_tmp < 400)        addr_copy = addr_copy_tmp - 200;
    else if (addr_copy_tmp >= 400 && addr_copy_tmp < 600)   addr_copy = addr_copy_tmp - 400;
    else                                                    addr_copy = addr_copy_tmp;
    
assign del_to_dro_25MHz = (addr_copy_tmp == 600 && state == `DEL) ? 1 : 0;
one_pulse DEL (.clk(clk), .rst(rst), .pb_in(del_to_dro_25MHz), .out_pulse(del_to_dro_100MHz));
//***************************************************************************************************************************************


// wea_copy*******************************************************************************************************************************
always@*
    if (state == `PRE)          wea_copy = 1;
    else if (state != `DEL)     wea_copy = 0;
    else if (addr_copy_tmp == blk0 || addr_copy_tmp == blk1 || addr_copy_tmp == blk2 || addr_copy_tmp == blk3) wea_copy = 1;
    else if (addr_copy_tmp >= 400 && addr_copy_tmp <= 599)  wea_copy = 1;
    else                            wea_copy = 0;
//***************************************************************************************************************************************


//data_copy********************************************************************************************************************************
always@*
if (state != `DEL)              data_copy = 0;
else if (addr_copy_tmp < 400)   data_copy = tetris;
else                            data_copy = dout_main;
//****************************************************************************************************************************************


// occupied*********************************************************************************************************************************
reg [199:0] occupied_tmp;
always@*
    if (touch)
        occupied_tmp = occupied | (1 << blk0) | (1 << blk1) | (1 << blk2) | (1 << blk3);
    else if (state == `PRE)
        occupied_tmp = 0;
    else if (addr_copy_tmp >= 400 && addr_copy_tmp <= 598) begin
        if (occupied[addr_main_del - 2] && dout_main == 0)
           occupied_tmp = occupied ^ (1 << (addr_main_del - 2));
        else if (occupied[addr_main_del - 2] == 0 && dout_main != 0)
            occupied_tmp = occupied | (1 << (addr_main_del-2));
        else 
            occupied_tmp = occupied;
    end
    else
        occupied_tmp = occupied;

always@(posedge clk_25MHz)
    if (rst) occupied <= 200'b0;
    else     occupied <= occupied_tmp;
//****************************************************************************************************************************************


// vga color********************************************************************************************************************************
always@*
    if (rgb == `NON)    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
    else if (rgb == 1)  {vgaRed, vgaGreen, vgaBlue} = `RED;
    else if (rgb == 2)  {vgaRed, vgaGreen, vgaBlue} = `ORANGE;
    else if (rgb == 3)  {vgaRed, vgaGreen, vgaBlue} = `YELLOW;
    else if (rgb == 4)  {vgaRed, vgaGreen, vgaBlue} = `LIME;
    else if (rgb == 5)  {vgaRed, vgaGreen, vgaBlue} = `CYAN;
    else if (rgb == 6)  {vgaRed, vgaGreen, vgaBlue} = `BLUE;
    else if (rgb == 7)  {vgaRed, vgaGreen, vgaBlue} = `PURPLE;
    else if (rgb == 8)  {vgaRed, vgaGreen, vgaBlue} = `GREY;
    else if (rgb == 9)  {vgaRed, vgaGreen, vgaBlue} = `WHITTE;
    else                {vgaRed, vgaGreen, vgaBlue} = 12'hFFF;

reg [9:0] score, score_tmp;

always@*
    if (score >= 160)    level = 15;
    else                 level = score / 10;

    always@*
        if (state != `PRE)
         case(level)
            4'd0: level_display = 16'b0000000000000001;
            4'd1: level_display = 16'b0000000000000010;
            4'd2: level_display = 16'b0000000000000100;
            4'd3: level_display = 16'b0000000000001000;
            4'd4: level_display = 16'b0000000000010000;
            4'd5: level_display = 16'b0000000000100000;
            4'd6: level_display = 16'b0000000001000000;
            4'd7: level_display = 16'b0000000010000000;
            4'd8: level_display = 16'b0000000100000000;
            4'd9: level_display = 16'b0000001000000000;
            4'd10: level_display = 16'b0000010000000000;
            4'd11: level_display = 16'b0000100000000000;
            4'd12: level_display = 16'b0001000000000000;
            4'd13: level_display = 16'b0010000000000000;
            4'd14: level_display = 16'b0100000000000000;
            4'd15: level_display = 16'b1000000000000000;
         endcase
        else
            level_display = 0;

always@*
if (state == `PRE) score_tmp = 0;
else if (addr_copy_tmp == 100 && state == `DEL) score_tmp = score + get;
else                score_tmp = score;

always@(posedge clk_25MHz or posedge rst)
    if (rst)    score <= 0;
    else        score <= score_tmp;


reg [4:0] combo, combo_tmp;
always@*
if (state == `PRE)  combo_tmp = 0;
else if (addr_copy_tmp == 50 && state == `DEL)
    if (get == 0)   combo_tmp = 0;
    else            combo_tmp = combo + 1;
else                combo_tmp = combo;

always@(posedge clk_25MHz or posedge rst)
    if (rst)        combo <= 0;
    else            combo <= combo_tmp;




wire [3:0] out;
scan U10 (.clk(clk), .rst(rst), .score(score), .ssd_ctl(ssd_ctl), .out(out));
ssd_decoder U11 (.out(out), .ssd_out(ssd_out));
speaker U12 (.clk(clk), .clk_100HZ(clk_100HZ), .rst(rst), .pb_inc(pb_inc), .pb_dec(pb_dec), .combo(combo),
            .mclk(mclk), .lrck(lrck), .sclk(sclk), .audio_sdin(audio_sdin));
endmodule