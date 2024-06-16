module clock_16HZ (
    clk,
    rst,
    clk_out
    );
    
    input clk;
    input rst;
    output reg clk_out;

    reg clk_tmp;
    reg [25:0] qtmp;              // tmp of counter50M
    reg [25:0] counter;
    
// below is the 125k BCD counter    
always@*
    if (counter == 24'd3124999) begin
        qtmp = 19'd0;
        clk_tmp = ~clk_out;
    end 
    else begin
        qtmp = counter + 1'b1;
        clk_tmp = clk_out;
    end    

always@(posedge clk or posedge rst)
    if (rst)    counter <= 19'd0;
    else        counter <= qtmp;   
    
always@(posedge clk or posedge rst)
    if (rst)    clk_out <= 1'b0;
    else        clk_out <= clk_tmp;                   
    
endmodule