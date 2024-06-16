module speaker (
    input clk, clk_100HZ, rst,
    input pb_inc, pb_dec,
    input [4:0] combo,
    output mclk, lrck, sclk,
    output audio_sdin
); 

wire [15:0] amplitude;
wire [15:0] audio_left;
wire [15:0] audio_right;
wire [21:0] note_div;

amplitude_set S2 (.clk(clk), .clk_100HZ(clk_100HZ), .rst(rst), .pb_inc(pb_inc), .pb_dec(pb_dec), .amplitude(amplitude));

note_div_gen S3 (.clk(clk), .rst(rst), .combo(combo), .note_div(note_div));

note_gen S4 (.clk(clk), .rst(rst), .note_div(note_div), .amplitude(amplitude),
             .audio_left(audio_left), .audio_right(audio_right));

speaker_control S5 (.clk(clk), .rst(rst), .audio_in_left(audio_left),
                    .audio_in_right(audio_right), .audio_sdin(audio_sdin),
                    .mclk(mclk), .lrck(lrck), .sclk(sclk));

endmodule