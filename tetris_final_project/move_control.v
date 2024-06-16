`include "global.v"

module move_control (
    input clk, del_to_dro, rst, clk_25MHz,
    input left, right, down, drop, spin, space,
    input [2:0] tetris,
    input [1:0] state,
    output reg [7:0] blk0, blk1, blk2, blk3,
    input [199:0] occupied,
    output touch,
    output enable
);
reg [4:0] x, y, x_next, y_next, x_ntmp, y_ntmp;
reg del_to_dro_delay;

reg space_ctl, space_ctl_next;

always@*
if (rst || del_to_dro || state == `PRE)     space_ctl_next = 0;
else if (space)                             space_ctl_next = 1;
else if (space_ctl)                         space_ctl_next = 1;
else                                        space_ctl_next = 0;

always@(posedge clk)
    space_ctl <= space_ctl_next;
// buttom blocks*************************************************************************
wire touch_without_lock_delay, touch_tmp;
assign touch_without_lock_delay =  (occupied[blk0+4'd10] || occupied[blk1+4'd10] || occupied[blk2+4'd10] || occupied[blk3+4'd10] || (blk0 / 10 == 19) || (blk1 / 10 == 19) || (blk2 / 10 == 19) || (blk3 / 10 == 19)) ? 1 : 0;

reg [30:0] cnt, cnt_next;
always@*
if (rst || state == `PRE)                       cnt_next = 0;
else if (touch_without_lock_delay == 0)         cnt_next = 0;
else if (touch_without_lock_delay && cnt == 0)  cnt_next = 1;
else if (cnt != 0 && cnt != 100000000)          cnt_next = cnt + 1;

else if (cnt == 100000000)                      cnt_next = cnt;
else                                            cnt_next = 0;

always@(posedge clk)
    cnt <= cnt_next;
assign touch_tmp = (((cnt == 100000000) && touch_without_lock_delay) || (space_ctl && touch_without_lock_delay)) ? 1 : 0;
one_pulse TOU (.clk(clk_25MHz), .rst(rst), .pb_in(touch_tmp),   .out_pulse(touch));
//************************************************************************************

reg [1:0] rot_next, rot;


always@(posedge clk)
    if (rst)        del_to_dro_delay <= 0;
    else            del_to_dro_delay <= del_to_dro;

always@*
    if (spin || del_to_dro_delay)  rot_next = rot + 1'b1;
    else                           rot_next = rot;
  
always@(posedge clk)
    if (del_to_dro)    rot <= 2'b0;
    else               rot <= rot_next;

always@*
if (drop || down || space_ctl)   y_ntmp = y + 1;
else                y_ntmp = y;

always@*
if (right)          x_ntmp = x + 1;
else if (left)      x_ntmp = x - 1;
else                x_ntmp = x;

reg [7:0] blk0_ntmp, blk1_ntmp, blk2_ntmp, blk3_ntmp;
reg [7:0] blk0_next, blk1_next, blk2_next, blk3_next;

wire enable_collision;
reg  enable_boundary;

assign enable = enable_collision && enable_boundary;
assign enable_collision = ~(occupied[blk0_ntmp] || occupied[blk1_ntmp] || occupied[blk2_ntmp] || occupied[blk3_ntmp]);

always@*
if (left && (blk0 % 10 == 0))
    enable_boundary = 0;
else if (right && (blk3 % 10 == 9))
    enable_boundary = 0;
else if ((drop || down) && ((blk0 / 10 == 19) || (blk1 / 10 == 19) || (blk2 / 10 == 19) || (blk3 / 10 == 19)))
    enable_boundary = 0;
else if (spin && (blk0 % 10 > 5) && (blk3_ntmp % 10 < 5))
    enable_boundary = 0;
else if (spin && (blk0_ntmp / 10 == 20) || (blk1_ntmp / 10 == 20) || (blk2_ntmp / 10 == 20) || (blk3_ntmp / 10 == 20))
    enable_boundary = 0; 
else
    enable_boundary = 1;

always@*
if (~enable) begin
    blk0_next = blk0;
    blk1_next = blk1;
    blk2_next = blk2;
    blk3_next = blk3;
    x_next = x;
    y_next = y;
end
else begin
    blk0_next = blk0_ntmp;
    blk1_next = blk1_ntmp;
    blk2_next = blk2_ntmp;
    blk3_next = blk3_ntmp;
    x_next = x_ntmp;
    y_next = y_ntmp;
end

always@(posedge clk)
if (state == `PRE) begin
    blk0 <= 199;
    blk1 <= 199;
    blk2 <= 199;
    blk3 <= 199;
end
else begin
    blk0 <= blk0_next;
    blk1 <= blk1_next;
    blk2 <= blk2_next;
    blk3 <= blk3_next;
end

always@(posedge clk)
if (del_to_dro) begin
    x <= 5'd3;
    y <= 5'd0;
end
else begin
    x <= x_next;
    y <= y_next;
end

wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
assign p0 = 10 * y + x;
assign p1 = 10 * y + x + 1;
assign p2 = 10 * y + x + 2;
assign p3 = 10 * (y + 1) + x;
assign p4 = 10 * (y + 1) + x + 1;
assign p5 = 10 * (y + 1) + x + 2;
assign p6 = 10 * (y + 2) + x;
assign p7 = 10 * (y + 2) + x + 1;
assign p8 = 10 * (y + 2) + x + 2;

always@*
if (spin || del_to_dro_delay)
case(tetris)
    `Z_BLOCK: begin
        if (rot == 0 || rot == 2) begin
            blk0_ntmp = p0;
            blk1_ntmp = p1;
            blk2_ntmp = p4; 
            blk3_ntmp = p5;
        end
        else begin
            blk0_ntmp = p3;
            blk1_ntmp = p6;
            blk2_ntmp = p1;
            blk3_ntmp = p4;
        end
    end
    `J_BLOCK: begin
        if (rot == 0) begin
            blk0_ntmp = p0;
            blk1_ntmp = p3;
            blk2_ntmp = p4;
            blk3_ntmp = p5;
        end
        else if(rot == 1) begin
            blk0_ntmp = p0;
            blk1_ntmp = p3;
            blk2_ntmp = p6;
            blk3_ntmp = p1;
        end
        else if (rot == 2) begin
            blk0_ntmp = p0;
            blk1_ntmp = p1;
            blk2_ntmp = p2;
            blk3_ntmp = p5;
        end
        else begin
            blk0_ntmp = p6;
            blk1_ntmp = p4;
            blk2_ntmp = p7;
            blk3_ntmp = p1;
        end
        
    end
    `O_BLOCK: begin
        blk0_ntmp = p0;
        blk1_ntmp = p1;
        blk2_ntmp = p3;
        blk3_ntmp = p4;
    end
    `S_BLOCK: begin
        if (rot == 0 || rot == 2) begin
            blk0_ntmp = p3;
            blk1_ntmp = p4;
            blk2_ntmp = p1;
            blk3_ntmp = p2;
        end
        else begin
            blk0_ntmp = p0;
            blk1_ntmp = p3;
            blk2_ntmp = p4;
            blk3_ntmp = p7;
        end
    end
    `I_BLOCK: begin
        if (rot == 0 || rot == 2) begin
            blk0_ntmp = p0;
            blk1_ntmp = p1;
            blk2_ntmp = p2;
            blk3_ntmp = p0 + 3;
        end
        else begin
            blk0_ntmp = p0;
            blk1_ntmp = p3;
            blk2_ntmp = p6;
            blk3_ntmp = 10 * (y + 3) + x;
        end
    end
    `L_BLOCK: begin
        if (rot == 0) begin
            blk0_ntmp = p3;
            blk1_ntmp = p4;
            blk2_ntmp = p5;
            blk3_ntmp = p2;
        end
        else if(rot == 1) begin
            blk0_ntmp = p0;
            blk1_ntmp = p3;
            blk2_ntmp = p6;
            blk3_ntmp = p7;
        end
        else if (rot == 2) begin
            blk0_ntmp = p0;
            blk1_ntmp = p1;
            blk2_ntmp = p3;
            blk3_ntmp = p2;
        end
        else begin
            blk0_ntmp = p0;
            blk1_ntmp = p1;
            blk2_ntmp = p4;
            blk3_ntmp = p7;
        end
    end
    `T_BLOCK: begin
        if (rot == 0) begin
            blk0_ntmp = p3;
            blk1_ntmp = p1;
            blk2_ntmp = p4;
            blk3_ntmp = p5;
        end
        else if(rot == 1) begin
            blk0_ntmp = p1;
            blk1_ntmp = p4;
            blk2_ntmp = p7;
            blk3_ntmp = p5;
        end
        else if (rot == 2) begin
            blk0_ntmp = p3;
            blk1_ntmp = p4;
            blk2_ntmp = p7;
            blk3_ntmp = p5;
        end
        else begin
            blk0_ntmp = p3;
            blk1_ntmp = p1;
            blk2_ntmp = p4;
            blk3_ntmp = p7;
        end
    end
    default: begin
        blk0_ntmp = 0;
        blk1_ntmp = 0;
        blk2_ntmp = 0;
        blk3_ntmp = 0;
    end
    endcase
else if (drop) begin
    blk0_ntmp = blk0 + 4'd10;
    blk1_ntmp = blk1 + 4'd10;
    blk2_ntmp = blk2 + 4'd10;
    blk3_ntmp = blk3 + 4'd10;
end
else if (right) begin
    blk0_ntmp = blk0 + 1;
    blk1_ntmp = blk1 + 1;
    blk2_ntmp = blk2 + 1;
    blk3_ntmp = blk3 + 1;              
end               
else if (left) begin
    blk0_ntmp = blk0 - 1;
    blk1_ntmp = blk1 - 1;
    blk2_ntmp = blk2 - 1;
    blk3_ntmp = blk3 - 1;
end
else if (down || space_ctl) begin
    blk0_ntmp = blk0 + 10;
    blk1_ntmp = blk1 + 10;
    blk2_ntmp = blk2 + 10;
    blk3_ntmp = blk3 + 10;
end
else begin
     blk0_ntmp = blk0;
     blk1_ntmp = blk1;
     blk2_ntmp = blk2;
     blk3_ntmp = blk3;
end
endmodule


