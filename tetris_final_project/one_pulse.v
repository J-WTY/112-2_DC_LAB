module one_pulse (
    clk,
    rst,
    pb_in,
    out_pulse
    );
    input clk;
    input rst;
    input pb_in;
    output out_pulse;
    
    reg pb_in_delay;
    reg out_pulse_next;
    reg out_pulse;
    
    always@(posedge clk)
        if (rst)  pb_in_delay <= 0;
        else      pb_in_delay <= pb_in;
    
    always@*
        out_pulse_next = (~pb_in_delay) & pb_in;
        
    always@(posedge clk)
       if (rst)   out_pulse <= 1'b0;
       else       out_pulse <= out_pulse_next;
       
endmodule
