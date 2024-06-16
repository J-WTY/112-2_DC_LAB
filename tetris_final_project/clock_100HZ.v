module clock_100HZ(
    clk,
    rst,
    clk_out
    );
    
    input clk;
    input rst;
    output reg clk_out;

    reg clk_tmp;
    reg [18:0] qtmp;              // tmp of counter50M
    reg [18:0] counter500k;
    
// below is the 50M BCD counter    
always@*
    if (counter500k == 19'd499999) begin
        qtmp = 19'd0;
        clk_tmp = ~clk_out;
    end 
    else begin
        qtmp = counter500k + 1'b1;
        clk_tmp = clk_out;
    end    

always@(posedge clk or posedge rst)
    if (rst)    counter500k <= 19'd0;
    else        counter500k <= qtmp;   
    
always@(posedge clk or posedge rst)
    if (rst)    clk_out <= 1'b0;
    else        clk_out <= clk_tmp;                   
    
endmodule