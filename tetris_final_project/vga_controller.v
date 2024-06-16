`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

module vga_controller (
  input wire pclk,reset,
  output wire valid,
  output reg hsync, vsync,
  output wire [9:0]h_cnt,
  output wire [9:0]v_cnt
);
    
reg [9:0]pixel_cnt;
reg [9:0]line_cnt;
wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;
   
assign HD = 640; // Horizontal visiable area
assign HF = 16; // Horizontal front porch
assign HS = 96; // Horizontal sync pulse
assign HB = 48; // Horizonatl back porch
assign HT = 800;  // Horizontal whole line
assign VD = 480; // Vertical visiable area
assign VF = 10; // Vertical front porch
assign VS = 2; // Vertical sync pulse
assign VB = 33; // Vertical back porch
assign VT = 525; // Vertical whole line
     
// Horizontal counter
always@(posedge pclk)
  if(reset)
    pixel_cnt <= 0;
  else if(pixel_cnt < (HT - 1))    // pixel: 0~799
    pixel_cnt <= pixel_cnt + 1;
  else
    pixel_cnt <= 0;

// Generate Horizontal Sync Pulse
always@(posedge pclk)
  if(reset)
    hsync <= 1'b1;
  else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1))) // between front porsh and sync pulse
    hsync <= 1'b0;
  else
    hsync <= 1'b1; 

// Vertical scan line counter
always@(posedge pclk)
  if(reset)
    line_cnt <= 0;
  else if(pixel_cnt == (HT -1))  // horzontal whole 799
    if(line_cnt < (VT - 1))     // 不是最下面一行
      line_cnt <= line_cnt + 1;
    else                         // 是最下面一行
      line_cnt <= 0;
  else
      line_cnt <= line_cnt;

// Generate Vertical Sync Pulse
always@(posedge pclk)
  if(reset)
    vsync <= 1'b1; 
  else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
    vsync <= 1'b0; 
  else
    vsync <= 1'b1; 

assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;

endmodule