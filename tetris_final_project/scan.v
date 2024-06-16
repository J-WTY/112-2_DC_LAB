module scan(
   input clk,
   input rst,
   input [9:0] score,
   output reg [3:0] ssd_ctl,
   output reg [3:0] out
);

reg [1:0] sel;
reg [14:0] cnt;
reg [16:0] cnt_tmp;

// below is counter
always @*
    cnt_tmp = {sel,cnt} + 1'b1;

always @(posedge clk or posedge rst)
    if (rst) {sel, cnt} <= 17'd0;
    else {sel, cnt} <= cnt_tmp;
//  counter ends

wire [3:0] score3, score2, score1, score0;
assign score3 = score / 1000;
assign score2 = (score % 1000) / 100;
assign score1 = (score % 100) / 10;
assign score0 = (score % 10);
always@*
case(sel)
    2'b00: begin
        ssd_ctl = 4'b1110;
        out = score0;
    end
    2'b01: begin
        ssd_ctl = 4'b1101;
        out = score1;    
    end
    2'b10: begin
        ssd_ctl = 4'b1011;
        out = score2;
    end
    2'b11: begin
        ssd_ctl = 4'b0111;
        out = score3;
    end
    default: begin 
        ssd_ctl = 4'b1111;
        out = score0;
    end
endcase                
endmodule
