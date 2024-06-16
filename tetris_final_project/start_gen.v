module start_gen (
    input clk, rst,
    input pb_start,
    output start,
    output clk_100HZ
);
wire deb_start;

clock_100HZ S1 (.clk(clk), .rst(rst), .clk_out(clk_100HZ));
debounce S2  (.clk(clk_100HZ), .rst(rst), .pb_in(pb_start), .pb_debounced(deb_start));
one_pulse S3 (.clk(clk), .rst(rst), .pb_in(deb_start), .out_pulse(start));

endmodule