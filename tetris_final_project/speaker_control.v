module speaker_control(
    clk,
    rst,
    audio_in_left,
    audio_in_right,
    audio_sdin,
    mclk,
    lrck,
    sclk
    );
input clk;
input rst;
input [15:0] audio_in_left;
input [15:0] audio_in_right;
output reg audio_sdin;
output mclk;
output lrck;
output sclk;
    
wire [8:0] clk_tmp;
reg  [8:0] clk_out;
reg [15:0] audio_left, audio_right;

assign mclk = clk_out[1];
assign lrck = clk_out[8];
assign sclk = clk_out[3];

assign clk_tmp = clk_out + 1'b1;

always@(posedge clk or posedge rst)
    if (rst)   clk_out <= 9'd0;
    else        clk_out <= clk_tmp;

always @(posedge sclk or posedge rst)
    if (rst) begin
        audio_left <= 16'd0;
        audio_right <= 16'd0;
    end
    else begin
        audio_left <= audio_in_left;
        audio_right <= audio_in_right;
    end   
always @*
case (clk_out[8:4])
    5'b00000: audio_sdin = audio_right[0];
    5'b00001: audio_sdin = audio_left[15];
    5'b00010: audio_sdin = audio_left[14];
    5'b00011: audio_sdin = audio_left[13];
    5'b00100: audio_sdin = audio_left[12];
    5'b00101: audio_sdin = audio_left[11];
    5'b00110: audio_sdin = audio_left[10];
    5'b00111: audio_sdin = audio_left[9];
    5'b01000: audio_sdin = audio_left[8];
    5'b01001: audio_sdin = audio_left[7];
    5'b01010: audio_sdin = audio_left[6];
    5'b01011: audio_sdin = audio_left[5];
    5'b01100: audio_sdin = audio_left[4];
    5'b01101: audio_sdin = audio_left[3];
    5'b01110: audio_sdin = audio_left[2];
    5'b01111: audio_sdin = audio_left[1];
    5'b10000: audio_sdin = audio_left[0];
    5'b10001: audio_sdin = audio_right[15];
    5'b10010: audio_sdin = audio_right[14];
    5'b10011: audio_sdin = audio_right[13];
    5'b10100: audio_sdin = audio_right[12];
    5'b10101: audio_sdin = audio_right[11];
    5'b10110: audio_sdin = audio_right[10];
    5'b10111: audio_sdin = audio_right[9];
    5'b11000: audio_sdin = audio_right[8];
    5'b11001: audio_sdin = audio_right[7];
    5'b11010: audio_sdin = audio_right[6];
    5'b11011: audio_sdin = audio_right[5];
    5'b11100: audio_sdin = audio_right[4];
    5'b11101: audio_sdin = audio_right[3];
    5'b11110: audio_sdin = audio_right[2];
    5'b11111: audio_sdin = audio_right[1];
    default: audio_sdin = 1'b0;
endcase  
endmodule
