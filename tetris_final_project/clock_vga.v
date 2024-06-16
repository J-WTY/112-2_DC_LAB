module clock_vga(clk1, clk);
input clk;
output clk1;
reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk)   num <= next_num;

assign next_num = num + 1'b1;
assign clk1 = num[1];
endmodule
